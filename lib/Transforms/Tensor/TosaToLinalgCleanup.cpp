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
/// From the semantics point of view, reshape should not introduce a redundant
/// memref copy. However, in HLS, a reinterpret-like statement will obstruct the
/// array partition of the on-chip memory. Therefore, we convert reshape to
/// explict linalg generic operation in this lowering.
struct ReshapeOpRewritePattern : public OpRewritePattern<tosa::ReshapeOp> {
  using OpRewritePattern<tosa::ReshapeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::ReshapeOp reshape,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPoint(reshape);
    auto inputType = reshape.getInput1().getType().cast<TensorType>();
    auto outputType = reshape.getType();

    // A helper to get the memory access map.
    auto getIndexMap = [&](TensorType type) {
      unsigned rank = type.getRank();
      SmallVector<AffineExpr, 4> exprs(rank, rewriter.getAffineDimExpr(0));

      for (unsigned dim = 0; dim < rank; ++dim)
        for (unsigned idx = 0; idx < dim; ++idx)
          exprs[idx] = exprs[idx].floorDiv(type.getDimSize(dim));

      for (unsigned idx = 0; idx < rank; ++idx) {
        auto &expr = exprs[idx];
        if (auto constantExpr = expr.dyn_cast<AffineDimExpr>())
          if (outputType.getNumElements() <= type.getDimSize(idx))
            continue;
        expr = expr % type.getDimSize(idx);
      }
      return AffineMap::get(/*dimCount=*/1, 0, exprs, rewriter.getContext());
    };

    // Create linalg init tensor and generic operation.
    auto init = rewriter.create<linalg::InitTensorOp>(
        reshape.getLoc(), outputType.getShape(), outputType.getElementType());
    auto generic = rewriter.replaceOpWithNewOp<linalg::GenericOp>(
        reshape, TypeRange(outputType), ValueRange(reshape.getInput1()),
        ValueRange(init.result()),
        SmallVector<AffineMap>(
            {getIndexMap(inputType), getIndexMap(outputType)}),
        SmallVector<StringRef>({"parallel"}));

    // Create the body of generic operation that directly yield the input
    // argument as result.
    auto entry = rewriter.createBlock(&generic.getBodyRegion());
    auto arg = entry->addArgument(inputType.getElementType(), reshape.getLoc());
    entry->addArgument(outputType.getElementType(), reshape.getLoc());

    rewriter.setInsertionPointToEnd(entry);
    rewriter.create<linalg::YieldOp>(reshape.getLoc(), arg);
    return success();
  }
};
} // namespace

namespace {
struct RescaleRemovePattern : public OpRewritePattern<tosa::ApplyScaleOp> {
  using OpRewritePattern<tosa::ApplyScaleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::ApplyScaleOp scale,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOp(scale, scale.getValue());
    return success();
  }
};
} // namespace

namespace {
struct TosaToLinalgCleanup
    : public TosaToLinalgCleanupBase<TosaToLinalgCleanup> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    ConversionTarget target(*context);
    target.addIllegalOp<tensor::PadOp, tosa::ReshapeOp, tosa::RescaleOp>();
    target.addLegalOp<linalg::GenericOp, linalg::YieldOp, linalg::InitTensorOp,
                      linalg::FillOp, arith::ConstantOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ReshapeOpRewritePattern>(context);
    patterns.add<linalg::PadOpTransformationPattern>(context);
    patterns.add<RescaleRemovePattern>(context);
    // mlir::tosa::populateTosaRescaleToArithConversionPatterns(&patterns,
    // true);

    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createTosaToLinalgCleanupPass() {
  return std::make_unique<TosaToLinalgCleanup>();
}
