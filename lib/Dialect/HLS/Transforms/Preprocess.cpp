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
/// This pattern will convert a linalg.generic op to an fdf.tensor_init op with
/// initial value if applicable.
struct ConvertLinalgGenericOp : public OpRewritePattern<linalg::GenericOp> {
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

      if (yieldedValue.getDefiningOp<arith::ConstantOp>()) {
        // If the yielded value is a constant scalar, we create a tensor init
        // operation with the constant as the initial value.
        auto tensorInit = rewriter.create<hls::TensorInitOp>(
            op.getLoc(), result.getType(), yieldedValue);
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
struct Preprocess : public PreprocessBase<Preprocess> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertLinalgFillOp>(context);
    patterns.add<ConvertLinalgGenericOp>(context);
    hls::TensorInitOp::getCanonicalizationPatterns(patterns, context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    auto b = OpBuilder(context);
    func.walk([&](Operation *op) {
      b.setInsertionPointAfter(op);
      for (auto result :
           llvm::make_filter_range(op->getResults(), [&](Value v) {
             return isa<RankedTensorType>(v.getType());
           })) {
        SmallVector<OpOperand *> uses = llvm::map_to_vector(
            result.getUses(), [&](OpOperand &use) { return &use; });
        auto forkTypes = SmallVector<Type>(uses.size(), result.getType());
        auto forkOp =
            b.create<hls::TensorForkOp>(op->getLoc(), forkTypes, result);
        for (auto [use, fork] : llvm::zip(uses, forkOp.getResults()))
          use->set(fork);
      }
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createPreprocessPass() {
  return std::make_unique<Preprocess>();
}
