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
/// This pattern will convert a tensor.empty op to an fdf.tensor_init op.
struct ConvertTensorEmptyOp : public OpRewritePattern<tensor::EmptyOp> {
  using OpRewritePattern<tensor::EmptyOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(tensor::EmptyOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<hls::TensorInitOp>(op, op.getType());
    return success();
  }
};
} // namespace

namespace {
/// This pattern will convert a linalg.fill op to an fdf.tensor_init op with
/// initial value.
struct ConvertLinalgFillOp : public OpRewritePattern<linalg::FillOp> {
  using OpRewritePattern<linalg::FillOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::FillOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<hls::TensorInitOp>(op, op.result().getType(),
                                                   op.value());
    return success();
  }
};
} // namespace

namespace {
struct CreateTensorInit : public CreateTensorInitBase<CreateTensorInit> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto builder = OpBuilder(context);

    // Convert linalg ops to FDF ops.
    ConversionTarget target(*context);
    target.addIllegalOp<tensor::EmptyOp, tensor::DimOp, tensor::RankOp,
                        linalg::FillOp>();
    target.addLegalOp<hls::TensorInitOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertLinalgFillOp>(context);
    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();

    // Ensure each TensorInitOp is only used once.
    for (auto tensorInit :
         llvm::make_early_inc_range(func.getOps<hls::TensorInitOp>())) {
      for (auto &use : llvm::make_early_inc_range(tensorInit->getUses())) {
        builder.setInsertionPoint(use.getOwner());
        auto newTensorInit =
            cast<hls::TensorInitOp>(builder.clone(*tensorInit));
        use.set(newTensorInit);
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createCreateTensorInitPass() {
  return std::make_unique<CreateTensorInit>();
}
