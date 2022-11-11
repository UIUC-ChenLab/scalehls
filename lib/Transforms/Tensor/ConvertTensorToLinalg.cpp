//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/TosaToArith/TosaToArith.h"
#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Transforms/DialectConversion.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
// TODO: This is a temporary solution for experiment purpose.
struct RemoveRescaleOp : public OpRewritePattern<tosa::ApplyScaleOp> {
  using OpRewritePattern<tosa::ApplyScaleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::ApplyScaleOp scale,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOp(scale, scale.getValue());
    return success();
  }
};
} // namespace

namespace {
struct ConvertTensorToLinalg
    : public ConvertTensorToLinalgBase<ConvertTensorToLinalg> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    ConversionTarget target(*context);
    target.addIllegalOp<tensor::PadOp, tosa::RescaleOp>();
    target.addLegalOp<linalg::GenericOp, linalg::YieldOp, tensor::EmptyOp,
                      linalg::FillOp, arith::ConstantOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<linalg::PadOpTransformationPattern>(context);
    patterns.add<RemoveRescaleOp>(context);
    // tosa::populateTosaRescaleToArithConversionPatterns(&patterns, true);

    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertTensorToLinalgPass() {
  return std::make_unique<ConvertTensorToLinalg>();
}
