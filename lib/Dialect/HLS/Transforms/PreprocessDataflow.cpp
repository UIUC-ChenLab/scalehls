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
        // original result with the transposed tensor if applicable.
        auto inputTensor = op.getMatchingOpOperand(yieldedArg);
        auto inputMap = op.getMatchingIndexingMap(inputTensor);
        auto resultMap = op.getIndexingMapMatchingResult(result);

        if (inputMap == resultMap) {
          rewriter.replaceAllUsesWith(result, inputTensor->get());
          hasChanged = true;
        }
        // else if (inputMap.isPermutation()) {
        //   auto permutation = llvm::map_to_vector(
        //       inversePermutation(inputMap).compose(resultMap).getResults(),
        //       [](AffineExpr expr) {
        //         return (int64_t)cast<AffineDimExpr>(expr).getPosition();
        //       });
        //   auto transTensor = rewriter.create<linalg::TransposeOp>(
        //       op.getLoc(), inputTensor->get(), init, permutation);
        //   rewriter.replaceAllUsesWith(result, transTensor.getResult());
        //   hasChanged = true;
        // }
      }
    }
    return success(hasChanged);
  }
};
} // namespace

static SmallVector<AffineExpr> getLowRankTensorIndexingExprs(
    const SmallVectorImpl<mlir::ReassociationIndices> &reassociationIndices,
    RankedTensorType highRankTensorType, PatternRewriter &rewriter) {
  SmallVector<AffineExpr> exprs;
  for (auto indices : reassociationIndices) {
    auto localExpr = rewriter.getAffineDimExpr(indices.front());
    for (auto index : llvm::drop_begin(indices)) {
      localExpr = localExpr * highRankTensorType.getDimSize(index);
      localExpr = localExpr + rewriter.getAffineDimExpr(index);
    }
    exprs.push_back(localExpr);
  }
  return exprs;
}

template <typename OpTy>
static linalg::GenericOp
generateReshapeLinalgGenericOp(OpTy reshapeOp, AffineMap inputMap,
                               AffineMap outputMap, PatternRewriter &rewriter) {
  assert(inputMap.getNumDims() == outputMap.getNumDims() &&
         "input/output map mismatch in number of dimensions");

  auto init = rewriter.template create<hls::TensorInitOp>(
      reshapeOp.getLoc(), reshapeOp.getResultType());
  auto generic = rewriter.template create<linalg::GenericOp>(
      reshapeOp.getLoc(), reshapeOp.getResultType(), reshapeOp.getOperand(),
      init.getResult(), SmallVector<AffineMap>({inputMap, outputMap}),
      SmallVector<utils::IteratorType>(inputMap.getNumDims(),
                                       utils::IteratorType::parallel));

  auto genericBlock = rewriter.createBlock(&generic.getRegion());
  genericBlock->addArguments(
      {reshapeOp.getSrcType().getElementType(),
       init.getType().getElementType()},
      {reshapeOp.getSrc().getLoc(), init.getResult().getLoc()});
  rewriter.setInsertionPointToStart(genericBlock);
  rewriter.template create<linalg::YieldOp>(reshapeOp.getLoc(),
                                            genericBlock->getArgument(0));
  return generic;
}

namespace {
/// This pattern will convert a tensor.expand_shape op to linalg.generic op.
struct ConvertTensorExpandShapeOp
    : public OpRewritePattern<tensor::ExpandShapeOp> {
  using OpRewritePattern<tensor::ExpandShapeOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(tensor::ExpandShapeOp op,
                                PatternRewriter &rewriter) const override {
    auto inputExprs = getLowRankTensorIndexingExprs(
        op.getReassociationIndices(), op.getResultType(), rewriter);

    // Generate the indexing maps for the linalg.generic op.
    auto numLoops = op.getResultType().getRank();
    auto inputMap =
        AffineMap::get(numLoops, 0, inputExprs, rewriter.getContext());
    auto outputMap = rewriter.getMultiDimIdentityMap(numLoops);
    auto generic =
        generateReshapeLinalgGenericOp(op, inputMap, outputMap, rewriter);

    // Replace the uses of the tensor.expand_shape op.
    rewriter.replaceAllUsesWith(op, generic.getResult(0));
    return success();
  }
};
} // namespace

namespace {
/// This pattern will convert a tensor.collapse op to linalg.generic op.
struct ConvertTensorCollapseShapeOp
    : public OpRewritePattern<tensor::CollapseShapeOp> {
  using OpRewritePattern<tensor::CollapseShapeOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(tensor::CollapseShapeOp op,
                                PatternRewriter &rewriter) const override {
    auto outputExprs = getLowRankTensorIndexingExprs(
        op.getReassociationIndices(), op.getSrcType(), rewriter);

    // Generate the indexing maps for the linalg.generic op.
    auto numLoops = op.getSrcType().getRank();
    auto inputMap = rewriter.getMultiDimIdentityMap(numLoops);
    auto outputMap =
        AffineMap::get(numLoops, 0, outputExprs, rewriter.getContext());
    auto generic =
        generateReshapeLinalgGenericOp(op, inputMap, outputMap, rewriter);

    // Replace the uses of the tensor.collapse_shape op.
    rewriter.replaceAllUsesWith(op, generic.getResult(0));
    return success();
  }
};
} // namespace

namespace {
struct PreprocessDataflow : public PreprocessDataflowBase<PreprocessDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto builder = OpBuilder(context);

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertLinalgFillOp>(context);
    patterns.add<ConvertLinalgGenericOp>(context);
    patterns.add<ConvertTensorExpandShapeOp>(context);
    patterns.add<ConvertTensorCollapseShapeOp>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

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

std::unique_ptr<Pass> scalehls::hls::createPreprocessDataflowPass() {
  return std::make_unique<PreprocessDataflow>();
}
