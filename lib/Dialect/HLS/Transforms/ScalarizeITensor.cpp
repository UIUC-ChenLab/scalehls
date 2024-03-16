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

static ITensorType getScalarITensorType(ITensorType iTensor) {
  if (auto shapedElement = iTensor.getShapedElementType()) {
    SmallVector<int64_t> scalarIterTripCounts(iTensor.getIterTripCounts());
    scalarIterTripCounts.append(shapedElement.getShape().begin(),
                                shapedElement.getShape().end());

    SmallVector<int64_t> scalarIterSteps(iTensor.getIterSteps());
    scalarIterSteps.append(shapedElement.getRank(), 1);

    SmallVector<AffineExpr> scalarIterExprs;
    for (auto [dim, expr] :
         llvm::enumerate(iTensor.getIterMap().getResults())) {
      auto newExpr = expr + getAffineDimExpr(iTensor.getIterRank() + dim,
                                             iTensor.getContext());
      scalarIterExprs.push_back(newExpr);
    }

    auto scalarIterMap =
        AffineMap::get(iTensor.getIterRank() + shapedElement.getRank(), 0,
                       scalarIterExprs, iTensor.getContext());
    return ITensorType::get(shapedElement.getElementType(),
                            scalarIterTripCounts, scalarIterSteps,
                            scalarIterMap, iTensor.getDepth());
  }
  return iTensor;
}

namespace {
struct ScalarizeITensorOp : public OpRewritePattern<hls::ITensorInitOp> {
  using OpRewritePattern<hls::ITensorInitOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorInitOp channel,
                                PatternRewriter &rewriter) const override {
    auto iTensorType = channel.getType();
    if (!iTensorType.hasShapedElementType())
      return failure();

    channel.getResult().setType(getScalarITensorType(iTensorType));
    rewriter.setInsertionPointAfter(channel);
    auto cast = rewriter.create<hls::ITensorCastOp>(channel.getLoc(),
                                                    iTensorType, channel);
    rewriter.replaceAllUsesExcept(channel, cast.getResult(), cast);
    return success();
  }
};
} // namespace

namespace {
struct ScalarizeITensorReadOp : public OpRewritePattern<hls::ITensorReadOp> {
  using OpRewritePattern<hls::ITensorReadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorReadOp read,
                                PatternRewriter &rewriter) const override {
    auto iTensorType = read.getSource().getType();
    if (!iTensorType.hasShapedElementType())
      return failure();

    auto loc = read.getLoc();
    rewriter.setInsertionPointAfterValue(read.getSource());
    auto cast = rewriter.create<hls::ITensorCastOp>(
        loc, getScalarITensorType(iTensorType), read.getSource());

    rewriter.setInsertionPoint(read);
    auto elementType = iTensorType.getShapedElementType();
    auto init = read.getInit();
    if (!init)
      init = rewriter.create<hls::TensorInitOp>(loc, elementType);
    auto [ivs, result, iterArg] = constructLoops(
        elementType.getShape(), SmallVector<int64_t>(elementType.getRank(), 1),
        loc, rewriter, init);

    auto scalarRead = rewriter.create<hls::ITensorReadOp>(
        loc, elementType.getElementType(), cast);
    auto insert = rewriter.create<tensor::InsertOp>(loc, scalarRead.getResult(),
                                                    iterArg, ivs);
    rewriter.create<scf::YieldOp>(loc, insert.getResult());

    rewriter.replaceOp(read, result);
    return success();
  }
};
} // namespace

namespace {
struct ScalarizeITensorWriteOp : public OpRewritePattern<hls::ITensorWriteOp> {
  using OpRewritePattern<hls::ITensorWriteOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorWriteOp write,
                                PatternRewriter &rewriter) const override {
    auto iTensorType = write.getResult().getType();
    if (!iTensorType.hasShapedElementType())
      return failure();

    auto loc = write.getLoc();
    auto scalarITensorType = getScalarITensorType(iTensorType);
    rewriter.setInsertionPointAfterValue(write.getDest());
    auto cast = rewriter.create<hls::ITensorCastOp>(loc, scalarITensorType,
                                                    write.getDest());

    rewriter.setInsertionPoint(write);
    auto elementType = iTensorType.getShapedElementType();
    auto [ivs, result, iterArg] = constructLoops(
        elementType.getShape(), SmallVector<int64_t>(elementType.getRank(), 1),
        loc, rewriter, cast);

    auto extract =
        rewriter.create<tensor::ExtractOp>(loc, write.getValue(), ivs);
    auto scalarWrite = rewriter.create<hls::ITensorWriteOp>(
        loc, scalarITensorType, extract.getResult(), iterArg);
    rewriter.create<scf::YieldOp>(loc, scalarWrite.getResult());

    rewriter.setInsertionPointAfterValue(result);
    auto castBack =
        rewriter.create<hls::ITensorCastOp>(loc, iTensorType, result);
    rewriter.replaceOp(write, castBack);
    return success();
  }
};
} // namespace

static SmallVector<Attribute> getScalarIterationReassociation(
    ArrayRef<ReassociationIndices> iterationIndicesArray,
    ArrayRef<ReassociationIndices> shapeIndicesArray,
    PatternRewriter &rewriter) {
  SmallVector<ReassociationIndices, 4> scalarIterationIndicesArray(
      iterationIndicesArray);
  auto rank = iterationIndicesArray.back().back() + 1;
  for (auto shapeIndices : shapeIndicesArray) {
    ReassociationIndices scalarIterationIndices;
    for (auto shapeIndex : shapeIndices)
      scalarIterationIndices.push_back(shapeIndex + rank);
    scalarIterationIndicesArray.push_back(scalarIterationIndices);
  }
  return llvm::map_to_vector(scalarIterationIndicesArray, [&](auto indices) {
    return Attribute(rewriter.getI64ArrayAttr(indices));
  });
}

namespace {
struct ScalarizeITensorReassociateOp
    : public OpRewritePattern<hls::ITensorReassociateOp> {
  using OpRewritePattern<hls::ITensorReassociateOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorReassociateOp op,
                                PatternRewriter &rewriter) const override {
    auto sourceType = op.getSource().getType();
    auto resultType = op.getResult().getType();
    if (!sourceType.hasShapedElementType() ||
        !resultType.hasShapedElementType())
      return failure();

    auto loc = op.getLoc();
    auto inputCast = rewriter.create<hls::ITensorCastOp>(
        loc, getScalarITensorType(sourceType), op.getSource());

    auto scalarIterationReassociation =
        rewriter.getArrayAttr(getScalarIterationReassociation(
            op.getIterationReassociationIndices(),
            op.getShapeReassociationIndices(), rewriter));
    auto scalarOp = rewriter.create<hls::ITensorReassociateOp>(
        loc, getScalarITensorType(resultType), inputCast, op.getExpandShape(),
        op.getShapeReassociation(), op.getExpandIteration(),
        scalarIterationReassociation);

    rewriter.replaceOpWithNewOp<hls::ITensorCastOp>(op, resultType, scalarOp);
    return success();
  }
};
} // namespace

namespace {
struct ScalarizeForOp : public OpRewritePattern<scf::ForOp> {
  using OpRewritePattern<scf::ForOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(scf::ForOp op,
                                PatternRewriter &rewriter) const override {
    auto yieldOp = cast<scf::YieldOp>(op.getBody()->getTerminator());
    bool hasChanged = false;

    for (auto [initArg, iterArg, yieldedValue, result] :
         llvm::zip(op.getInitArgs(), op.getRegionIterArgs(),
                   op.getYieldedValues(), op.getResults())) {
      auto iTensorType = dyn_cast<ITensorType>(result.getType());
      if (iTensorType && iTensorType.hasShapedElementType()) {
        hasChanged = true;
        auto scalarITensorType = getScalarITensorType(iTensorType);

        // Cast the initial argument's type.
        rewriter.setInsertionPoint(op);
        auto initArgCast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), scalarITensorType, initArg);
        rewriter.replaceUsesWithIf(
            initArg, initArgCast,
            [&](OpOperand &operand) { return operand.getOwner() == op; });

        // Cast the iteration argument's type.
        rewriter.setInsertionPointToStart(op.getBody());
        auto iterArgCast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), iTensorType, iterArg);
        rewriter.replaceAllUsesExcept(iterArg, iterArgCast, iterArgCast);
        iterArg.setType(scalarITensorType);

        // Cast the yeilded value's type.
        rewriter.setInsertionPoint(yieldOp);
        auto yieldedValueCast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), scalarITensorType, yieldedValue);
        rewriter.replaceUsesWithIf(
            yieldedValue, yieldedValueCast,
            [&](OpOperand &operand) { return operand.getOwner() == yieldOp; });

        // Cast the loop result's type.
        rewriter.setInsertionPointAfter(op);
        auto resultCast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), iTensorType, result);
        rewriter.replaceAllUsesExcept(result, resultCast, resultCast);
        result.setType(scalarITensorType);
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
template <typename OpTy>
struct ScalarizeScheduleOrTaskOp : public OpRewritePattern<OpTy> {
  using OpRewritePattern<OpTy>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpTy op,
                                PatternRewriter &rewriter) const override {
    auto yieldOp = op.getYieldOp();
    bool hasChanged = false;

    for (auto [yieldedValue, result] :
         llvm::zip(yieldOp.getOperands(), op.getResults())) {
      auto iTensorType = dyn_cast<ITensorType>(result.getType());
      if (iTensorType && iTensorType.hasShapedElementType()) {
        hasChanged = true;
        auto scalarITensorType = getScalarITensorType(iTensorType);

        rewriter.setInsertionPoint(yieldOp);
        auto cast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), scalarITensorType, yieldedValue);
        rewriter.replaceUsesWithIf(yieldedValue, cast, [&](OpOperand &operand) {
          return operand.getOwner() == yieldOp;
        });

        rewriter.setInsertionPointAfter(op);
        auto castBack = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), iTensorType, result);
        rewriter.replaceAllUsesExcept(result, castBack, castBack);
        result.setType(scalarITensorType);
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct ScalarizeITensor : public ScalarizeITensorBase<ScalarizeITensor> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ScalarizeITensorOp>(context);
    patterns.add<ScalarizeITensorReadOp>(context);
    patterns.add<ScalarizeITensorWriteOp>(context);
    patterns.add<ScalarizeITensorReassociateOp>(context);
    patterns.add<ScalarizeForOp>(context);
    patterns.add<ScalarizeScheduleOrTaskOp<hls::ScheduleOp>>(context);
    patterns.add<ScalarizeScheduleOrTaskOp<hls::TaskOp>>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScalarizeITensorPass() {
  return std::make_unique<ScalarizeITensor>();
}