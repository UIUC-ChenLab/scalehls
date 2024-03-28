//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/Utils/Utils.h"
#include "mlir/IR/AffineMap.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_PREPROCESS
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
/// This pattern will convert a tensor.empty op to an fdf.tensor_init op.
struct ConvertTensorEmptyToTensorInit
    : public OpRewritePattern<tensor::EmptyOp> {
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
struct ConvertLinalgFillOpToTensorInit
    : public OpRewritePattern<linalg::FillOp> {
  using OpRewritePattern<linalg::FillOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::FillOp op,
                                PatternRewriter &rewriter) const override {
    if (auto constantOp = op.value().getDefiningOp<arith::ConstantOp>()) {
      rewriter.replaceOpWithNewOp<hls::TensorInitOp>(op, op.result().getType(),
                                                     constantOp.getValue());
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
/// This pattern will convert a linalg.generic op to an fdf.tensor_init op with
/// initial value if applicable.
struct PreprocessLinalgGenericOp : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::GenericOp op,
                                PatternRewriter &rewriter) const override {
    // We can convert the generaic operation to a tensor init operation only
    // when the generic operation is elementwise and only contains a single
    // yield operation.
    auto yield = dyn_cast<linalg::YieldOp>(op.front());
    if (!yield || !linalg::isElementwise(op))
      return failure();

    bool hasChanged = false;
    for (auto [yieldedValue, result, init] :
         llvm::zip(yield.getValues(), op.getResults(), op.getDpsInits())) {
      if (result.use_empty())
        continue;

      if (auto constantOp = yieldedValue.getDefiningOp<arith::ConstantOp>()) {
        // If the yielded value is a constant scalar, we create a tensor init
        // operation with the constant as the initial value.
        auto tensorInit = rewriter.create<hls::TensorInitOp>(
            op.getLoc(), result.getType(), constantOp.getValue());
        rewriter.replaceAllUsesWith(result, tensorInit);
        hasChanged = true;

      } else if (auto yieldedArg = dyn_cast<BlockArgument>(yieldedValue)) {
        // If the yielded value is from a constant tensor, we replace the
        // original result with the constant tensor if applicable.
        auto inputTensor = op.getMatchingOpOperand(yieldedArg);
        auto inputMap = op.getMatchingIndexingMap(inputTensor);
        auto resultMap = op.getIndexingMapMatchingResult(result);

        if (inputMap == resultMap) {
          rewriter.replaceAllUsesWith(result, inputTensor->get());
          hasChanged = true;
        }
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct Preprocess : public hls::impl::PreprocessBase<Preprocess> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyToTensorInit>(context);
    patterns.add<ConvertLinalgFillOpToTensorInit>(context);
    patterns.add<PreprocessLinalgGenericOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
