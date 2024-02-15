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
struct LowerTensorToStreamConversionOp
    : public OpRewritePattern<hls::TensorToStreamOp> {
  using OpRewritePattern<hls::TensorToStreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TensorToStreamOp toStream,
                                PatternRewriter &rewriter) const override {

    return failure();
  }
};
} // namespace

namespace {
struct LowerStreamToTensorConversionOp
    : public OpRewritePattern<hls::StreamToTensorOp> {
  using OpRewritePattern<hls::StreamToTensorOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamToTensorOp toStream,
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
    patterns.add<LowerTensorToStreamConversionOp>(context);
    patterns.add<LowerStreamToTensorConversionOp>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScalarizeStreamPass() {
  return std::make_unique<ScalarizeStream>();
}