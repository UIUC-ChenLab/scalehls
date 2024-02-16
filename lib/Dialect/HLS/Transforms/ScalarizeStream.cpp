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
struct LowerTensorToStreamConversionOp
    : public OpRewritePattern<hls::TensorToStreamOp> {
  using OpRewritePattern<hls::TensorToStreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TensorToStreamOp toStream,
                                PatternRewriter &rewriter) const override {
    auto streamType = toStream.getStream().getType();
    auto loc = toStream.getLoc();

    // Create a new stream channel to replace the original stream.
    auto channel = rewriter.create<hls::StreamOp>(loc, streamType);

    // Construct loops to iterate over the tensor.
    SmallVector<Value> ivs;
    for (auto [tripCount, step] :
         llvm::zip(streamType.getIterTripCounts(), streamType.getIterSteps())) {
      auto lbCst = rewriter.create<arith::ConstantIndexOp>(loc, 0);
      auto ubCst =
          rewriter.create<arith::ConstantIndexOp>(loc, tripCount * step);
      auto stepCst = rewriter.create<arith::ConstantIndexOp>(loc, step);
      auto loop = rewriter.create<scf::ForOp>(loc, lbCst, ubCst, stepCst);
      rewriter.setInsertionPointToStart(loop.getBody());
      ivs.push_back(loop.getInductionVar());
    }

    // Construct the offsets based on the iteration map.
    SmallVector<Value> indices;
    for (auto expr : streamType.getIterMap().getResults()) {
      auto apply = rewriter.create<affine::AffineApplyOp>(
          loc, SmallVector<AffineExpr>({expr}), ivs);
      indices.push_back(apply);
    }

    // Extract slice and write to the channel.
    if (streamType.getShapedElementType()) {
      auto offsets = llvm::map_to_vector(
          indices, [&](Value index) { return (OpFoldResult)index; });
      auto sizes =
          llvm::map_to_vector(streamType.getElementShape(), [&](int64_t size) {
            return (OpFoldResult)rewriter.getI64IntegerAttr(size);
          });
      auto strides = SmallVector<OpFoldResult>(streamType.getRank(),
                                               rewriter.getI64IntegerAttr(1));

      auto slice = rewriter.create<tensor::ExtractSliceOp>(
          loc, toStream.getTensor(), offsets, sizes, strides);
      rewriter.create<hls::StreamWriteOp>(loc, channel, slice);
    } else {
      auto element = rewriter.create<tensor::ExtractOp>(
          loc, toStream.getTensor(), indices);
      rewriter.create<hls::StreamWriteOp>(loc, channel, element);
    }

    rewriter.replaceAllUsesWith(toStream.getStream(), channel);
    return success();
  }
};
} // namespace

namespace {
struct LowerStreamToTensorConversionOp
    : public OpRewritePattern<hls::StreamToTensorOp> {
  using OpRewritePattern<hls::StreamToTensorOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamToTensorOp toTensor,
                                PatternRewriter &rewriter) const override {
    auto streamType = toTensor.getStream().getType();
    auto tensorType = toTensor.getTensor().getType();
    auto loc = toTensor.getLoc();

    // Create a new tensor to replace the original tensor.
    auto tensorInit = rewriter.create<hls::TensorInitOp>(loc, tensorType);

    // Construct loops to iterate over the tensor.
    SmallVector<Value> ivs;
    SmallVector<scf::ForOp> loops;
    Value tensorArg = tensorInit.getResult();
    for (auto [tripCount, step] :
         llvm::zip(streamType.getIterTripCounts(), streamType.getIterSteps())) {
      auto lbCst = rewriter.create<arith::ConstantIndexOp>(loc, 0);
      auto ubCst =
          rewriter.create<arith::ConstantIndexOp>(loc, tripCount * step);
      auto stepCst = rewriter.create<arith::ConstantIndexOp>(loc, step);
      auto loop =
          rewriter.create<scf::ForOp>(loc, lbCst, ubCst, stepCst, tensorArg);
      if (tensorArg != tensorInit.getResult())
        rewriter.create<scf::YieldOp>(loc, loop.getResult(0));

      rewriter.setInsertionPointToStart(loop.getBody());
      tensorArg = loop.getRegionIterArg(0);
      ivs.push_back(loop.getInductionVar());
      loops.push_back(loop);
    }

    // Construct the offsets based on the iteration map.
    SmallVector<Value> indices;
    for (auto expr : streamType.getIterMap().getResults()) {
      auto apply = rewriter.create<affine::AffineApplyOp>(
          loc, SmallVector<AffineExpr>({expr}), ivs);
      indices.push_back(apply);
    }

    // Extract slice and write to the channel.
    if (streamType.getShapedElementType()) {
      auto offsets = llvm::map_to_vector(
          indices, [&](Value index) { return (OpFoldResult)index; });
      auto sizes =
          llvm::map_to_vector(streamType.getElementShape(), [&](int64_t size) {
            return (OpFoldResult)rewriter.getI64IntegerAttr(size);
          });
      auto strides = SmallVector<OpFoldResult>(streamType.getRank(),
                                               rewriter.getI64IntegerAttr(1));

      auto slice = rewriter.create<hls::StreamReadOp>(
          loc, streamType.getElementType(), toTensor.getStream());
      auto tensorResult = rewriter.create<tensor::InsertSliceOp>(
          loc, slice.getResult(), tensorArg, offsets, sizes, strides);
      rewriter.create<scf::YieldOp>(loc, tensorResult.getResult());
    } else {
      auto element = rewriter.create<hls::StreamReadOp>(
          loc, streamType.getElementType(), toTensor.getStream());
      auto tensorResult = rewriter.create<tensor::InsertOp>(
          loc, element.getResult(), tensorArg, indices);
      rewriter.create<scf::YieldOp>(loc, tensorResult.getResult());
    }

    rewriter.replaceAllUsesWith(toTensor.getTensor(),
                                loops.front().getResult(0));
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
    patterns.add<LowerTensorToStreamConversionOp>(context);
    patterns.add<LowerStreamToTensorConversionOp>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScalarizeStreamPass() {
  return std::make_unique<ScalarizeStream>();
}