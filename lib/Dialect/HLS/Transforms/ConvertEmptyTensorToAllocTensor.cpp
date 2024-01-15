//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
/// This pattern will convert a tensor.empty op to an fdf.alloc_tensor op.
struct ConvertTensorEmptyOp : public OpRewritePattern<tensor::EmptyOp> {
  using OpRewritePattern<tensor::EmptyOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(tensor::EmptyOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<hls::AllocTensorOp>(op, op.getType());
    return success();
  }
};
} // namespace

namespace {
/// This pattern will convert a linalg.fill op to an fdf.alloc_tensor op with
/// initial value.
struct ConvertLinalgFillOp : public OpRewritePattern<linalg::FillOp> {
  using OpRewritePattern<linalg::FillOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::FillOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<hls::AllocTensorOp>(op, op.getType(0),
                                                    op.value());
    return success();
  }
};
} // namespace

namespace {
struct ConvertEmptyTensorToAllocTensor
    : public ConvertEmptyTensorToAllocTensorBase<
          ConvertEmptyTensorToAllocTensor> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto builder = OpBuilder(context);

    // Convert linalg ops to FDF ops.
    ConversionTarget target(*context);
    target.addIllegalOp<tensor::EmptyOp, tensor::DimOp, tensor::RankOp,
                        linalg::FillOp>();
    target.addLegalOp<hls::AllocTensorOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertLinalgFillOp>(context);
    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();

    // Ensure each AllocTensorOp is only used once.
    for (auto allocTensor :
         llvm::make_early_inc_range(func.getOps<hls::AllocTensorOp>())) {
      for (auto &use : llvm::make_early_inc_range(allocTensor->getUses())) {
        builder.setInsertionPoint(use.getOwner());
        auto newAllocTensor =
            cast<hls::AllocTensorOp>(builder.clone(*allocTensor));
        use.set(newAllocTensor);
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::hls::createConvertEmptyTensorToAllocTensorPass() {
  return std::make_unique<ConvertEmptyTensorToAllocTensor>();
}
