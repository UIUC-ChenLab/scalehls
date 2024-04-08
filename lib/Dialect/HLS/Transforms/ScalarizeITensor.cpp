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

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_SCALARIZEITENSOR
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

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
struct ScalarizeITensorInstanceOp
    : public OpRewritePattern<hls::ITensorInstanceOp> {
  using OpRewritePattern<hls::ITensorInstanceOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorInstanceOp inst,
                                PatternRewriter &rewriter) const override {
    auto iTensorType = inst.getType();
    if (!iTensorType.hasShapedElementType())
      return failure();

    rewriter.modifyOpInPlace(inst, [&]() {
      inst.getResult().setType(getScalarITensorType(iTensorType));
    });
    rewriter.setInsertionPointAfter(inst);
    auto cast =
        rewriter.create<hls::ITensorCastOp>(inst.getLoc(), iTensorType, inst);
    rewriter.replaceAllUsesExcept(inst, cast.getResult(), cast);
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
    auto [ivs, result, iterArg] = constructLoops(
        elementType.getShape(), SmallVector<int64_t>(elementType.getRank(), 1),
        loc, rewriter, read.getInit());

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

static LogicalResult scalarzieDetinationStyleContainerOp(
    Operation *op, ValueRange initOperands, ValueRange iterArgs,
    ValueRange yieldedValues, ValueRange results, PatternRewriter &rewriter) {
  bool hasChanged = false;
  auto terminator = op->getRegions().back().back().getTerminator();
  auto loc = op->getLoc();

  for (auto [initOperand, iterArg, yieldedValue, result] :
       llvm::zip(initOperands, iterArgs, yieldedValues, results)) {
    auto iTensorType = dyn_cast<ITensorType>(result.getType());
    if (!iTensorType || !iTensorType.hasShapedElementType())
      continue;

    hasChanged = true;
    auto scalarITensorType = getScalarITensorType(iTensorType);

    // Cast the initial operand's type.
    rewriter.setInsertionPoint(op);
    auto initOperandCast = rewriter.create<hls::ITensorCastOp>(
        loc, scalarITensorType, initOperand);
    rewriter.replaceUsesWithIf(
        initOperand, initOperandCast,
        [&](OpOperand &operand) { return operand.getOwner() == op; });

    // Cast the iteration argument's type.
    rewriter.setInsertionPointAfterValue(iterArg);
    auto iterArgCast =
        rewriter.create<hls::ITensorCastOp>(loc, iTensorType, iterArg);
    rewriter.replaceAllUsesExcept(iterArg, iterArgCast, iterArgCast);
    rewriter.startOpModification(op);
    iterArg.setType(scalarITensorType);
    rewriter.finalizeOpModification(op);

    // Cast the yeilded value's type.
    rewriter.setInsertionPoint(terminator);
    auto yieldedValueCast = rewriter.create<hls::ITensorCastOp>(
        loc, scalarITensorType, yieldedValue);
    rewriter.replaceUsesWithIf(
        yieldedValue, yieldedValueCast,
        [&](OpOperand &use) { return use.getOwner() == terminator; });

    // Cast the loop result's type.
    rewriter.setInsertionPointAfter(op);
    auto resultCast =
        rewriter.create<hls::ITensorCastOp>(loc, iTensorType, result);
    rewriter.replaceAllUsesExcept(result, resultCast, resultCast);
    rewriter.startOpModification(op);
    result.setType(scalarITensorType);
    rewriter.finalizeOpModification(op);
  }
  return success(hasChanged);
}

namespace {
struct ScalarizeForOp : public OpRewritePattern<scf::ForOp> {
  using OpRewritePattern<scf::ForOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(scf::ForOp op,
                                PatternRewriter &rewriter) const override {
    return scalarzieDetinationStyleContainerOp(
        op, op.getInitArgs(), op.getRegionIterArgs(), op.getYieldedValues(),
        op.getResults(), rewriter);
  }
};
} // namespace

namespace {
struct ScalarizeTaskOp : public OpRewritePattern<hls::TaskOp> {
  using OpRewritePattern<hls::TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TaskOp task,
                                PatternRewriter &rewriter) const override {
    return scalarzieDetinationStyleContainerOp(
        task, task.getInits(), task.getBody().getArguments(),
        task.getYieldOp().getOperands(), task.getResults(), rewriter);
  }
};
} // namespace

namespace {
struct ScalarizeITensor
    : public hls::impl::ScalarizeITensorBase<ScalarizeITensor> {
  LogicalResult postVerification() {
    // Check if all itensor cast ops have been folded.
    auto checkResult = getOperation().walk([&](Operation *op) {
      if (isa<hls::ITensorCastOp>(op)) {
        op->emitOpError("itensor_cast ops should have been folded");
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });
    return failure(checkResult.wasInterrupted());
  }

  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<ScalarizeITensorInstanceOp>(context);
    patterns.add<ScalarizeITensorReadOp>(context);
    patterns.add<ScalarizeITensorWriteOp>(context);
    patterns.add<ScalarizeITensorReassociateOp>(context);
    patterns.add<ScalarizeForOp>(context);
    patterns.add<ScalarizeTaskOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));

    if (failed(postVerification()))
      return signalPassFailure();
  }
};
} // namespace
