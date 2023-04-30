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
struct EliminateYieldedBuffer : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    for (auto [yieldedValue, opResult] :
         llvm::zip(op.getYieldOp().getOperands(), op.getResults())) {
      auto buffer = yieldedValue.template getDefiningOp<BufferOp>();
      if (!buffer)
        continue;

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
    patterns.add<EliminateYieldedBuffer<DispatchOp>>(context);
    patterns.add<EliminateYieldedBuffer<TaskOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createEliminateBufferYieldPass() {
  return std::make_unique<EliminateBufferYield>();
}
