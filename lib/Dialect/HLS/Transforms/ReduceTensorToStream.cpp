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
    : public OpRewritePattern<hls::StreamToTensorOp> {
  using OpRewritePattern<hls::StreamToTensorOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamToTensorOp streamToTensor,
                                PatternRewriter &rewriter) const override {
    if (streamToTensor->use_empty()) {
      rewriter.eraseOp(streamToTensor);
      return success();
    }

    auto sourceType = streamToTensor.getSourceType();
    assert(sourceType.tileIsRegular() &&
           "non-regular stream type is not supported");

    // Collect all destination stream channels.
    bool hasChanged = false;
    llvm::SmallDenseMap<hls::StreamType, SmallVector<Value>> typeToDestsMap;
    for (auto user : llvm::make_early_inc_range(streamToTensor->getUsers()))
      if (auto tensorToStream = dyn_cast<hls::TensorToStreamOp>(user)) {
        auto destType = tensorToStream.getDestType();
        assert(destType.tileIsRegular() &&
               "non-regular stream type is not supported");

        for (auto dest : tensorToStream.getDests()) {
          auto destStream = dest.getDefiningOp<hls::StreamOp>();
          assert(destStream && "destination is not a stream channel");
          destStream->moveBefore(streamToTensor);
          typeToDestsMap[destType].push_back(dest);
        }
        rewriter.eraseOp(tensorToStream);
        hasChanged = true;
      }

    auto loc = streamToTensor.getLoc();
    SmallVector<Value> newSources;
    for (unsigned i = 0; i < typeToDestsMap.size(); i++)
      newSources.push_back(rewriter.create<hls::StreamOp>(loc, sourceType));
    rewriter.create<hls::StreamForkOp>(loc, streamToTensor.getSource(),
                                       newSources);

    for (auto [newSource, pair] : llvm::zip(newSources, typeToDestsMap)) {
      auto [destType, dests] = pair;

      if (sourceType == destType) {
        // If the source and destination types are the same, we can use stream
        // fork to replace the tensor to stream operations.
        rewriter.create<hls::StreamForkOp>(loc, newSource, dests);
      } else {
        // Otherwise, we need to generate a stream buffer to pass the original
        // tensor while reducing the buffer size.
        auto tensorType = streamToTensor.getTensorType();
        SmallVector<int64_t> bufferShape;
        SmallVector<int64_t> sharedLoops;
        unsigned beforeLoop = 0;
        for (int64_t dim = 0; dim < tensorType.getRank(); dim++) {
          // To reduce the buffer size, we need to ensure that the source and
          // result stream share the same tile size for the current dimension.
          // TODO: Theoratically, we can partially reduce the buffer size when
          // the tile sizes are different.
          if (sourceType.getElementDimSize(dim) !=
              destType.getElementDimSize(dim))
            break;

          auto sourceExpr = sourceType.getIterMap().getResult(dim);
          auto resultExpr = destType.getIterMap().getResult(dim);

          // If both the source and result indices are constants and have the
          // same value, we can reduce the buffer size. Meanwhile, we don't need
          // any loop to iterate over the dimension, thus the corresponding loop
          // index is -1.
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

        rewriter.create<hls::StreamBufferOp>(
            loc, newSource, dests, tensorType.getElementType(), bufferShape,
            beforeLoop, beforeDim);
      }
    }
    return success(hasChanged);
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
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createReduceTensorToStreamPass() {
  return std::make_unique<ReduceTensorToStream>();
}