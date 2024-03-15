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

static StreamType getScalarStreamType(StreamType stream) {
  if (auto shapedElement = stream.getShapedElementType()) {
    SmallVector<int64_t> scalarIterTripCounts(stream.getIterTripCounts());
    scalarIterTripCounts.append(shapedElement.getShape().begin(),
                                shapedElement.getShape().end());

    SmallVector<int64_t> scalarIterSteps(stream.getIterSteps());
    scalarIterSteps.append(shapedElement.getRank(), 1);

    SmallVector<AffineExpr> scalarIterExprs;
    for (auto [dim, expr] : llvm::enumerate(stream.getIterMap().getResults())) {
      auto newExpr = expr + getAffineDimExpr(stream.getIterRank() + dim,
                                             stream.getContext());
      scalarIterExprs.push_back(newExpr);
    }

    auto scalarIterMap =
        AffineMap::get(stream.getIterRank() + shapedElement.getRank(), 0,
                       scalarIterExprs, stream.getContext());
    return StreamType::get(shapedElement.getElementType(), scalarIterTripCounts,
                           scalarIterSteps, scalarIterMap, stream.getDepth());
  }
  return stream;
}

namespace {
struct ScalarizeStreamOp : public OpRewritePattern<hls::ITensorInitOp> {
  using OpRewritePattern<hls::ITensorInitOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorInitOp channel,
                                PatternRewriter &rewriter) const override {
    auto streamType = channel.getType();
    if (!streamType.hasShapedElementType())
      return failure();

    channel.getResult().setType(getScalarStreamType(streamType));
    rewriter.setInsertionPointAfter(channel);
    auto cast = rewriter.create<hls::ITensorCastOp>(channel.getLoc(),
                                                    streamType, channel);
    rewriter.replaceAllUsesExcept(channel, cast.getResult(), cast);
    return success();
  }
};
} // namespace

namespace {
struct ScalarizeStreamReadOp : public OpRewritePattern<hls::ITensorReadOp> {
  using OpRewritePattern<hls::ITensorReadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorReadOp read,
                                PatternRewriter &rewriter) const override {
    auto streamType = read.getSource().getType();
    if (!streamType.hasShapedElementType())
      return failure();

    auto loc = read.getLoc();
    rewriter.setInsertionPointAfterValue(read.getSource());
    auto cast = rewriter.create<hls::ITensorCastOp>(
        loc, getScalarStreamType(streamType), read.getSource());

    rewriter.setInsertionPoint(read);
    auto elementType = streamType.getShapedElementType();
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
struct ScalarizeStreamWriteOp : public OpRewritePattern<hls::ITensorWriteOp> {
  using OpRewritePattern<hls::ITensorWriteOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorWriteOp write,
                                PatternRewriter &rewriter) const override {
    auto streamType = write.getResult().getType();
    if (!streamType.hasShapedElementType())
      return failure();

    auto loc = write.getLoc();
    auto scalarStreamType = getScalarStreamType(streamType);
    rewriter.setInsertionPointAfterValue(write.getInit());
    auto cast = rewriter.create<hls::ITensorCastOp>(loc, scalarStreamType,
                                                    write.getInit());

    rewriter.setInsertionPoint(write);
    auto elementType = streamType.getShapedElementType();
    auto [ivs, result, iterArg] = constructLoops(
        elementType.getShape(), SmallVector<int64_t>(elementType.getRank(), 1),
        loc, rewriter, cast);

    auto extract =
        rewriter.create<tensor::ExtractOp>(loc, write.getValue(), ivs);
    auto scalarWrite = rewriter.create<hls::ITensorWriteOp>(
        loc, scalarStreamType, extract.getResult(), iterArg);
    rewriter.create<scf::YieldOp>(loc, scalarWrite.getResult());

    rewriter.setInsertionPointAfterValue(result);
    auto castBack =
        rewriter.create<hls::ITensorCastOp>(loc, streamType, result);
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
struct ScalarizeStreamReassociateOp
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
        loc, getScalarStreamType(sourceType), op.getSource());

    auto scalarIterationReassociation =
        rewriter.getArrayAttr(getScalarIterationReassociation(
            op.getIterationReassociationIndices(),
            op.getShapeReassociationIndices(), rewriter));
    auto scalarOp = rewriter.create<hls::ITensorReassociateOp>(
        loc, getScalarStreamType(resultType), inputCast, op.getExpandShape(),
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
      auto streamType = dyn_cast<StreamType>(result.getType());
      if (streamType && streamType.hasShapedElementType()) {
        hasChanged = true;
        auto scalarStreamType = getScalarStreamType(streamType);

        // Cast the initial argument's type.
        rewriter.setInsertionPoint(op);
        auto initArgCast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), scalarStreamType, initArg);
        rewriter.replaceUsesWithIf(
            initArg, initArgCast,
            [&](OpOperand &operand) { return operand.getOwner() == op; });

        // Cast the iteration argument's type.
        rewriter.setInsertionPointToStart(op.getBody());
        auto iterArgCast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), streamType, iterArg);
        rewriter.replaceAllUsesExcept(iterArg, iterArgCast, iterArgCast);
        iterArg.setType(scalarStreamType);

        // Cast the yeilded value's type.
        rewriter.setInsertionPoint(yieldOp);
        auto yieldedValueCast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), scalarStreamType, yieldedValue);
        rewriter.replaceUsesWithIf(
            yieldedValue, yieldedValueCast,
            [&](OpOperand &operand) { return operand.getOwner() == yieldOp; });

        // Cast the loop result's type.
        rewriter.setInsertionPointAfter(op);
        auto resultCast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), streamType, result);
        rewriter.replaceAllUsesExcept(result, resultCast, resultCast);
        result.setType(scalarStreamType);
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
      auto streamType = dyn_cast<StreamType>(result.getType());
      if (streamType && streamType.hasShapedElementType()) {
        hasChanged = true;
        auto scalarStreamType = getScalarStreamType(streamType);

        rewriter.setInsertionPoint(yieldOp);
        auto cast = rewriter.create<hls::ITensorCastOp>(
            op.getLoc(), scalarStreamType, yieldedValue);
        rewriter.replaceUsesWithIf(yieldedValue, cast, [&](OpOperand &operand) {
          return operand.getOwner() == yieldOp;
        });

        rewriter.setInsertionPointAfter(op);
        auto castBack = rewriter.create<hls::ITensorCastOp>(op.getLoc(),
                                                            streamType, result);
        rewriter.replaceAllUsesExcept(result, castBack, castBack);
        result.setType(scalarStreamType);
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct ScalarizeStream : public ScalarizeStreamBase<ScalarizeStream> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ScalarizeStreamOp>(context);
    patterns.add<ScalarizeStreamReadOp>(context);
    patterns.add<ScalarizeStreamWriteOp>(context);
    patterns.add<ScalarizeStreamReassociateOp>(context);
    patterns.add<ScalarizeForOp>(context);
    patterns.add<ScalarizeScheduleOrTaskOp<hls::ScheduleOp>>(context);
    patterns.add<ScalarizeScheduleOrTaskOp<hls::TaskOp>>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScalarizeStreamPass() {
  return std::make_unique<ScalarizeStream>();
}