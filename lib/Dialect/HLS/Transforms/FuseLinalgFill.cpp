//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Utils.h"
#include "mlir/Dialect/Linalg/Utils/Utils.h"
#include "mlir/IR/AffineMap.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_FUSELINALGFILL
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
struct ConvertGenericOpToFillOp : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::GenericOp op,
                                PatternRewriter &rewriter) const override {
    // We can fold a generaic operation only when the generic operation is
    // elementwise and only contains a single yield operation.
    auto yield = dyn_cast<linalg::YieldOp>(op.front());
    if (!yield || !linalg::isElementwise(op))
      return failure();

    bool hasChanged = false;
    for (auto [yieldedValue, result, init] :
         llvm::zip(yield.getValues(), op.getResults(), op.getDpsInits())) {
      if (result.use_empty())
        continue;

      if (auto constantOp = yieldedValue.getDefiningOp<arith::ConstantOp>()) {
        // If the yielded value is a constant scalar, we create a linalg fill to
        // replace the linalg generic op.
        auto fill = rewriter.create<linalg::FillOp>(
            op.getLoc(), result.getType(), constantOp.getResult(), init);
        rewriter.replaceAllUsesWith(result, fill.getResult(0));
        hasChanged = true;
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct FoldGenericOp : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::GenericOp op,
                                PatternRewriter &rewriter) const override {
    // We can fold a generaic operation only when the generic operation is
    // elementwise and only contains a single yield operation.
    auto yield = dyn_cast<linalg::YieldOp>(op.front());
    if (!yield || !linalg::isElementwise(op))
      return failure();

    bool hasChanged = false;
    for (auto [yieldedValue, result, init] :
         llvm::zip(yield.getValues(), op.getResults(), op.getDpsInits())) {
      if (result.use_empty())
        continue;

      if (auto yieldedArg = dyn_cast<BlockArgument>(yieldedValue)) {
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
struct FuseFillOpIntoGenericOp : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::GenericOp op,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    for (auto [initOperand, outputArg] :
         llvm::zip(op.getDpsInitsMutable(), op.getRegionOutputArgs())) {
      auto fill = initOperand.get().getDefiningOp<linalg::FillOp>();
      if (!fill)
        continue;

      auto resultIdx = cast<OpResult>(initOperand.get()).getResultNumber();
      auto constantOp =
          fill.getDpsInputs()[resultIdx].getDefiningOp<arith::ConstantOp>();
      if (!constantOp)
        continue;

      auto loc = op.getLoc();
      rewriter.setInsertionPointToStart(op.getBody());
      auto constantZeroOp = rewriter.create<arith::ConstantIndexOp>(loc, 0);
      Value condition;
      for (auto [dim, iteratorType] :
           llvm::enumerate(op.getIteratorTypesArray())) {
        if (linalg::isParallelIterator(iteratorType))
          continue;
        auto indexOp = rewriter.create<linalg::IndexOp>(loc, dim);
        auto eqOp = rewriter.create<arith::CmpIOp>(
            loc, arith::CmpIPredicate::eq, indexOp, constantZeroOp);
        if (!condition)
          condition = eqOp;
        else
          condition = rewriter.create<arith::AndIOp>(loc, condition, eqOp);
      }

      auto selectOp = rewriter.create<arith::SelectOp>(
          loc, outputArg.getType(), condition, constantOp, outputArg);
      rewriter.replaceAllUsesExcept(outputArg, selectOp, selectOp);

      rewriter.startOpModification(op);
      initOperand.set(fill.getDpsInits()[resultIdx]);
      rewriter.finalizeOpModification(op);
      hasChanged = true;
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct FuseLinalgFill : public hls::impl::FuseLinalgFillBase<FuseLinalgFill> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertGenericOpToFillOp>(context);
    patterns.add<FoldGenericOp>(context);
    patterns.add<FuseFillOpIntoGenericOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
