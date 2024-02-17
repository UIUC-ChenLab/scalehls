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
struct ScalarizeStreamOp : public OpRewritePattern<hls::StreamOp> {
  using OpRewritePattern<hls::StreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamOp channel,
                                PatternRewriter &rewriter) const override {
    return failure();
  }
};
} // namespace

namespace {
struct ScalarizeStreamReadOp : public OpRewritePattern<hls::StreamReadOp> {
  using OpRewritePattern<hls::StreamReadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamReadOp read,
                                PatternRewriter &rewriter) const override {
    return failure();
  }
};
} // namespace

namespace {
struct ScalarizeStreamWriteOp : public OpRewritePattern<hls::StreamWriteOp> {
  using OpRewritePattern<hls::StreamWriteOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamWriteOp write,
                                PatternRewriter &rewriter) const override {
    return failure();
  }
};
} // namespace

namespace {
struct ScalarizeStreamExpandShapeOp
    : public OpRewritePattern<hls::StreamExpandShapeOp> {
  using OpRewritePattern<hls::StreamExpandShapeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamExpandShapeOp expandShape,
                                PatternRewriter &rewriter) const override {
    return failure();
  }
};
} // namespace

namespace {
struct ScalarizeStreamCollapseShapeOp
    : public OpRewritePattern<hls::StreamCollapseShapeOp> {
  using OpRewritePattern<hls::StreamCollapseShapeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamCollapseShapeOp collapseShape,
                                PatternRewriter &rewriter) const override {
    return failure();
  }
};
} // namespace

namespace {
struct ScalarizeStream : public ScalarizeStreamBase<ScalarizeStream> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ScalarizeStreamOp>(context);
    patterns.add<ScalarizeStreamReadOp>(context);
    patterns.add<ScalarizeStreamWriteOp>(context);
    patterns.add<ScalarizeStreamExpandShapeOp>(context);
    patterns.add<ScalarizeStreamCollapseShapeOp>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScalarizeStreamPass() {
  return std::make_unique<ScalarizeStream>();
}