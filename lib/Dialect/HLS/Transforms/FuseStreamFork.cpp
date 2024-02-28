//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tensor/Transforms/Transforms.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ForwardFuseStreamForkOp : public OpRewritePattern<hls::StreamForkOp> {
  using OpRewritePattern<hls::StreamForkOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamForkOp streamFork,
                                PatternRewriter &rewriter) const override {

    return success();
  }
};
} // namespace

namespace {
struct FuseStreamFork : public FuseStreamForkBase<FuseStreamFork> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ForwardFuseStreamForkOp>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createFuseStreamForkPass() {
  return std::make_unique<FuseStreamFork>();
}