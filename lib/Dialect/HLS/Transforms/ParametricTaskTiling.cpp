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
struct ParametricTaskTilingPattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp op,
                                PatternRewriter &rewriter) const override {
    return success();
  }
};
} // namespace

namespace {
struct ParametricTaskTiling
    : public ParametricTaskTilingBase<ParametricTaskTiling> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ParametricTaskTilingPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::hls::createParametricTaskTilingPass(unsigned defaultTileFactor) {
  return std::make_unique<ParametricTaskTiling>();
}
