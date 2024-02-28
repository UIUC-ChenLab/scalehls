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

namespace {
struct EliminateIntermediateTensor
    : public OpRewritePattern<hls::TensorToStreamOp> {
  using OpRewritePattern<hls::TensorToStreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TensorToStreamOp tensorTostream,
                                PatternRewriter &rewriter) const override {
    auto streamToTensor =
        tensorTostream.getTensor().getDefiningOp<hls::StreamToTensorOp>();
    if (!streamToTensor)
      return failure();
    auto tensorType = streamToTensor.getType();

    // Directly replace the result stream with the source stream if they share
    // the same type.
    auto sourceType = streamToTensor.getSourceType();
    auto resultType = tensorTostream.getDestType();
    if (sourceType == resultType) {
      for (auto dest : tensorTostream.getDests()) {
        rewriter.replaceAllUsesWith(dest, streamToTensor.getSource());
        rewriter.eraseOp(dest.getDefiningOp());
        rewriter.eraseOp(tensorTostream);
      }
      return success();
    }

    // Otherwise, we need to generate a stream.buffer operation to reduce the
    // buffer size.
    // TODO: Support non-regular stream types.
    if (!sourceType.tileIsRegular() || !resultType.tileIsRegular())
      return failure();

    SmallVector<int64_t> bufferShape;
    SmallVector<int64_t> sharedLoops;
    unsigned beforeLoop = 0;
    for (int64_t dim = 0; dim < tensorType.getRank(); dim++) {
      // To reduce the buffer size, we need to ensure that the source and result
      // stream share the same tile size for the current dimension.
      // TODO: Theoratically, we can partially reduce the buffer size when the
      // tile sizes are different.
      if (sourceType.getElementDimSize(dim) !=
          resultType.getElementDimSize(dim))
        break;

      auto sourceExpr = sourceType.getIterMap().getResult(dim);
      auto resultExpr = resultType.getIterMap().getResult(dim);

      // If both the source and result indices are constants and have the same
      // value, we can reduce the buffer size. Meanwhile, we don't need any loop
      // to iterate over the dimension, thus the corresponding loop index is -1.
      auto sourceConstExpr = dyn_cast<AffineConstantExpr>(sourceExpr);
      auto resultConstExpr = dyn_cast<AffineConstantExpr>(resultExpr);
      if (sourceConstExpr && resultConstExpr &&
          sourceConstExpr.getValue() == resultConstExpr.getValue()) {
        bufferShape.push_back(sourceType.getElementDimSize(dim));
        sharedLoops.push_back(-1);
        continue;
      }

      // If both the source and result indices are dimensions and follow the
      // same iteration order, we may be able to reduce the buffer size.
      auto sourceDimExpr = dyn_cast<AffineDimExpr>(sourceExpr);
      auto resultDimExpr = dyn_cast<AffineDimExpr>(resultExpr);
      if (sourceDimExpr && resultDimExpr &&
          sourceDimExpr.getPosition() == resultDimExpr.getPosition()) {
        bufferShape.push_back(sourceType.getElementDimSize(dim));
        sharedLoops.push_back(sourceDimExpr.getPosition());
        beforeLoop++;
        continue;
      }
      break;
    }

    // Ensure the buffer can be positioned correctly.
    while (llvm::any_of(sharedLoops, [&](int64_t loopIndex) {
      return loopIndex >= beforeLoop;
    })) {
      bufferShape.pop_back();
      if (sharedLoops.pop_back_val() != -1)
        beforeLoop--;
    }

    // For the remaining dimensions, we keep the original dimension size.
    int64_t beforeDim = bufferShape.size();
    bufferShape.append(std::next(tensorType.getShape().begin(), beforeDim),
                       tensorType.getShape().end());

    rewriter.replaceOpWithNewOp<hls::StreamBufferOp>(
        tensorTostream, streamToTensor.getSource(), tensorTostream.getDests(),
        tensorType.getElementType(), bufferShape, beforeLoop, beforeDim);
    return success();
  }
};
} // namespace

namespace {
struct ConvertTensorForkToStreamFork
    : public OpRewritePattern<hls::TensorForkOp> {
  using OpRewritePattern<hls::TensorForkOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TensorForkOp tensorForkOp,
                                PatternRewriter &rewriter) const override {
    auto streamToTensor =
        tensorForkOp.getSource().getDefiningOp<hls::StreamToTensorOp>();
    if (!streamToTensor)
      return failure();

    // Construct N forked stream channels.
    auto loc = tensorForkOp.getLoc();
    SmallVector<Value> destStreams;
    for (unsigned i = 0; i < tensorForkOp.getNumResults(); i++)
      destStreams.push_back(
          rewriter.create<hls::StreamOp>(loc, streamToTensor.getSourceType()));

    // Create the stream fork operation.
    rewriter.create<hls::StreamForkOp>(loc, streamToTensor.getSource(),
                                       destStreams);

    // Replace the tensor fork results with the forked streams.
    for (auto [result, destStream] :
         llvm::zip(tensorForkOp.getResults(), destStreams)) {
      auto destTensor = rewriter.create<hls::StreamToTensorOp>(
          loc, result.getType(), destStream);
      rewriter.replaceAllUsesWith(result, destTensor.getResult());
    }
    return success();
    // love uuuuuuuu ;)
  }
};
} // namespace

namespace {
struct ReduceTensorToStream
    : public ReduceTensorToStreamBase<ReduceTensorToStream> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<EliminateIntermediateTensor>(context);
    patterns.add<ConvertTensorForkToStreamFork>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createReduceTensorToStreamPass() {
  return std::make_unique<ReduceTensorToStream>();
}