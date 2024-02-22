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

/*

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
struct ScalarizeStreamOp : public OpRewritePattern<hls::StreamOp> {
  using OpRewritePattern<hls::StreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamOp channel,
                                PatternRewriter &rewriter) const override {
    auto streamType = channel.getType();
    if (!streamType.hasShapedElementType())
      return failure();

    channel.getResult().setType(getScalarStreamType(streamType));
    rewriter.setInsertionPointAfter(channel);
    auto cast = rewriter.create<hls::StreamCastOp>(channel.getLoc(), streamType,
                                                   channel);
    rewriter.replaceAllUsesExcept(channel, cast.getResult(), cast);
    return success();
  }
};
} // namespace

namespace {
struct ScalarizeStreamReadOp : public OpRewritePattern<hls::StreamReadOp> {
  using OpRewritePattern<hls::StreamReadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamReadOp read,
                                PatternRewriter &rewriter) const override {
    auto streamType = read.getChannel().getType();
    if (!streamType.hasShapedElementType())
      return failure();

    auto loc = read.getLoc();
    rewriter.setInsertionPointAfterValue(read.getChannel());
    auto cast = rewriter.create<hls::StreamCastOp>(
        loc, getScalarStreamType(streamType), read.getChannel());

    rewriter.setInsertionPoint(read);
    auto elementType = streamType.getShapedElementType();
    auto init = rewriter.create<hls::TensorInitOp>(loc, elementType);
    auto [ivs, result, iterArg] = constructLoops(
        elementType.getShape(), SmallVector<int64_t>(elementType.getRank(), 1),
        loc, rewriter, init);

    auto scalarRead = rewriter.create<hls::StreamReadOp>(
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
struct ScalarizeStreamWriteOp : public OpRewritePattern<hls::StreamWriteOp> {
  using OpRewritePattern<hls::StreamWriteOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamWriteOp write,
                                PatternRewriter &rewriter) const override {
    auto streamType = write.getChannel().getType();
    if (!streamType.hasShapedElementType())
      return failure();

    auto loc = write.getLoc();
    rewriter.setInsertionPointAfterValue(write.getChannel());
    auto cast = rewriter.create<hls::StreamCastOp>(
        loc, getScalarStreamType(streamType), write.getChannel());

    rewriter.setInsertionPoint(write);
    auto elementType = streamType.getShapedElementType();
    auto [ivs, result, iterArg] = constructLoops(
        elementType.getShape(), SmallVector<int64_t>(elementType.getRank(), 1),
        loc, rewriter);

    auto extract =
        rewriter.create<tensor::ExtractOp>(loc, write.getValue(), ivs);
    rewriter.create<hls::StreamWriteOp>(loc, cast, extract.getResult());

    rewriter.eraseOp(write);
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
    : public OpRewritePattern<hls::StreamReassociateOp> {
  using OpRewritePattern<hls::StreamReassociateOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamReassociateOp op,
                                PatternRewriter &rewriter) const override {
    auto inputType = op.getInputType();
    auto outputType = op.getOutputType();
    if (!inputType.hasShapedElementType() || !outputType.hasShapedElementType())
      return failure();

    auto loc = op.getLoc();
    auto inputCast = rewriter.create<hls::StreamCastOp>(
        loc, getScalarStreamType(inputType), op.getInput());

    auto scalarIterationReassociation =
        rewriter.getArrayAttr(getScalarIterationReassociation(
            op.getIterationReassociationIndices(),
            op.getShapeReassociationIndices(), rewriter));
    auto scalarOp = rewriter.create<hls::StreamReassociateOp>(
        loc, getScalarStreamType(outputType), inputCast, op.getExpandShape(),
        op.getShapeReassociation(), op.getExpandIteration(),
        scalarIterationReassociation);

    rewriter.replaceOpWithNewOp<hls::StreamCastOp>(op, outputType, scalarOp);
    return success();
  }
};
} // namespace

*/

namespace {
struct ScalarizeStream : public ScalarizeStreamBase<ScalarizeStream> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    // patterns.add<ScalarizeStreamOp>(context);
    // patterns.add<ScalarizeStreamReadOp>(context);
    // patterns.add<ScalarizeStreamWriteOp>(context);
    // patterns.add<ScalarizeStreamReassociateOp>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScalarizeStreamPass() {
  return std::make_unique<ScalarizeStream>();
}