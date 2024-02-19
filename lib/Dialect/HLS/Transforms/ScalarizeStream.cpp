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
    for (auto [dim, expr] : llvm::enumerate(stream.getIterMap().getResults()))
      scalarIterExprs.push_back(
          expr + getAffineDimExpr(stream.getIterMap().getNumDims() + dim,
                                  stream.getContext()));

    auto scalarIterMap = AffineMap::get(
        stream.getIterMap().getNumDims() + shapedElement.getRank(), 0,
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

static SmallVector<Attribute>
getScalarReassociation(ArrayRef<ReassociationIndices> reassociation,
                       PatternRewriter &rewriter) {
  SmallVector<ReassociationIndices> scalarReassociation(reassociation);
  auto rank = reassociation.back().back() + 1;
  for (auto indices : reassociation) {
    ReassociationIndices scalarReassociationIndices;
    for (auto index : indices)
      scalarReassociationIndices.push_back(index + rank);
    scalarReassociation.push_back(scalarReassociationIndices);
  }
  return llvm::map_to_vector(scalarReassociation, [&](auto indices) {
    return Attribute(rewriter.getI64ArrayAttr(indices));
  });
}

namespace {
struct ScalarizeStreamExpandShapeOp
    : public OpRewritePattern<hls::StreamExpandShapeOp> {
  using OpRewritePattern<hls::StreamExpandShapeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamExpandShapeOp expandShape,
                                PatternRewriter &rewriter) const override {
    auto inputType = expandShape.getInput().getType();
    auto outputType = expandShape.getOutput().getType();
    if (!inputType.hasShapedElementType() || !outputType.hasShapedElementType())
      return failure();

    auto loc = expandShape.getLoc();
    auto inputCast = rewriter.create<hls::StreamCastOp>(
        loc, getScalarStreamType(inputType), expandShape.getInput());

    auto scalarReassociation = rewriter.getArrayAttr(getScalarReassociation(
        expandShape.getReassociationIndices(), rewriter));
    auto scalarExpandShape = rewriter.create<hls::StreamExpandShapeOp>(
        loc, getScalarStreamType(outputType), inputCast, scalarReassociation);
    rewriter.replaceOpWithNewOp<hls::StreamCastOp>(expandShape, outputType,
                                                   scalarExpandShape);
    return success();
  }
};
} // namespace

namespace {
struct ScalarizeStreamCollapseShapeOp
    : public OpRewritePattern<hls::StreamCollapseShapeOp> {
  using OpRewritePattern<hls::StreamCollapseShapeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamCollapseShapeOp collapseShape,
                                PatternRewriter &rewriter) const override {
    auto inputType = collapseShape.getInput().getType();
    auto outputType = collapseShape.getOutput().getType();
    if (!inputType.hasShapedElementType() || !outputType.hasShapedElementType())
      return failure();

    auto loc = collapseShape.getLoc();
    auto inputCast = rewriter.create<hls::StreamCastOp>(
        loc, getScalarStreamType(inputType), collapseShape.getInput());

    auto scalarReassociation = rewriter.getArrayAttr(getScalarReassociation(
        collapseShape.getReassociationIndices(), rewriter));
    auto scalarCollapseShape = rewriter.create<hls::StreamCollapseShapeOp>(
        loc, getScalarStreamType(outputType), inputCast, scalarReassociation);
    rewriter.replaceOpWithNewOp<hls::StreamCastOp>(collapseShape, outputType,
                                                   scalarCollapseShape);
    return success();
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
    patterns.add<ScalarizeStreamExpandShapeOp>(context);
    patterns.add<ScalarizeStreamCollapseShapeOp>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScalarizeStreamPass() {
  return std::make_unique<ScalarizeStream>();
}