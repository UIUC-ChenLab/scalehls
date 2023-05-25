//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
template <typename OpType>
struct EliminateBufferYieldPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    auto yield = op.getYieldOp();
    bool hasChanged = false;

    // For now, we always generate an explicit copy to handle view-like
    // operations. This is not efficient but it's safe.
    for (auto &operand : yield->getOpOperands())
      if (auto view =
              operand.get().template getDefiningOp<ViewLikeOpInterface>()) {
        rewriter.setInsertionPoint(yield);
        auto buffer = rewriter.template create<BufferOp>(
            op.getLoc(), operand.get().getType());
        rewriter.template create<memref::CopyOp>(op.getLoc(), operand.get(),
                                                 buffer);
        operand.set(buffer);
      }

    // Eliminat each yielded buffer.
    for (auto [yieldedValue, opResult] :
         llvm::zip(yield.getOperands(), op.getResults()))
      if (auto buffer = yieldedValue.template getDefiningOp<BufferOp>()) {
        // It's always safe to move the buffer to higher level hierarchy.
        if (op->isAncestor(buffer))
          buffer->moveBefore(op);

        rewriter.replaceAllUsesWith(opResult, buffer);
        hasChanged = true;
      }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct EliminateBufferYield
    : public EliminateBufferYieldBase<EliminateBufferYield> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<EliminateBufferYieldPattern<DispatchOp>>(context);
    patterns.add<EliminateBufferYieldPattern<TaskOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createEliminateBufferYieldPass() {
  return std::make_unique<EliminateBufferYield>();
}
