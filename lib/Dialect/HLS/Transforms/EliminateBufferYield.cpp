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
    for (auto &buffer : op.getYieldOp()->getOpOperands())
      if (buffer.get().getType().template isa<MemRefType>() &&
          buffer.get().getParentRegion()->isProperAncestor(&op.getBody())) {
        rewriter.replaceAllUsesWith(op.getResult(buffer.getOperandNumber()),
                                    buffer.get());
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
