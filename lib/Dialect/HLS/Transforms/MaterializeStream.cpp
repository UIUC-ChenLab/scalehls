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

static std::tuple<Value, Value, Value>
getLoopBoundsAndStep(int64_t tripCount, int64_t step, Location loc,
                     PatternRewriter &rewriter) {
  auto lbCst = rewriter.create<arith::ConstantIndexOp>(loc, 0);
  auto ubCst = rewriter.create<arith::ConstantIndexOp>(loc, tripCount * step);
  auto stepCst = rewriter.create<arith::ConstantIndexOp>(loc, step);
  return std::make_tuple(lbCst, ubCst, stepCst);
}

/// Construct a loop with the given trip counts, steps, and an optional tensor
/// as the iteration argument. Return the loop induction variables, the result
/// of the outermost loop, and the iteration argument of the innermost loop.
static std::tuple<SmallVector<Value>, Value, Value>
constructLoops(ArrayRef<int64_t> tripCounts, ArrayRef<int64_t> steps,
               Location loc, PatternRewriter &rewriter,
               Value iterArg = Value()) {
  SmallVector<Value> ivs;
  Value result = iterArg;
  for (auto [tripCount, step] : llvm::zip(tripCounts, steps)) {
    // Construct loops with the given trip counts and steps.
    auto [lbCst, ubCst, stepCst] =
        getLoopBoundsAndStep(tripCount, step, loc, rewriter);
    auto iterArgs = iterArg ? ValueRange(iterArg) : std::nullopt;
    auto loop =
        rewriter.create<scf::ForOp>(loc, lbCst, ubCst, stepCst, iterArgs);

    // Handle the iteration argument if it is provided.
    if (iterArg) {
      iterArg = loop.getRegionIterArg(0);
      // For the outermost loop, we return the loop result. For the other loops,
      // we just yield the loop result and continue to the next loop.
      if (ivs.empty())
        result = loop.getResult(0);
      else
        rewriter.create<scf::YieldOp>(loc, loop.getResult(0));
    }

    // Set the insertion point to the start of the loop body.
    rewriter.setInsertionPointToStart(loop.getBody());
    ivs.push_back(loop.getInductionVar());
  }
  return std::make_tuple(ivs, result, iterArg);
}

static std::tuple<SmallVector<OpFoldResult>, SmallVector<OpFoldResult>,
                  SmallVector<OpFoldResult>>
getSliceInfo(ArrayRef<Value> ivs, ArrayRef<AffineExpr> indexExprs,
             ArrayRef<int64_t> elementShape, Location loc,
             PatternRewriter &rewriter) {
  assert(indexExprs.size() == elementShape.size() &&
         "indices and element shape should have the same size");
  auto offsets = llvm::map_to_vector(indexExprs, [&](AffineExpr expr) {
    auto map = AffineMap::get(ivs.size(), 0, expr);
    auto apply = rewriter.create<affine::AffineApplyOp>(loc, map, ivs);
    return OpFoldResult(apply.getResult());
  });
  auto sizes = llvm::map_to_vector(elementShape, [&](int64_t size) {
    return OpFoldResult(rewriter.getI64IntegerAttr(size));
  });
  auto strides = SmallVector<OpFoldResult>(indexExprs.size(),
                                           rewriter.getI64IntegerAttr(1));
  return std::make_tuple(offsets, sizes, strides);
}

static void extactSliceAndWriteStream(ArrayRef<Value> ivs, Value channel,
                                      Value tensor, Location loc,
                                      PatternRewriter &rewriter) {
  auto streamType = channel.getType().cast<StreamType>();
  auto [offsets, sizes, strides] =
      getSliceInfo(ivs, streamType.getIterMap().getResults(),
                   streamType.getElementShape(), loc, rewriter);
  auto slice = rewriter.create<tensor::ExtractSliceOp>(loc, tensor, offsets,
                                                       sizes, strides);
  rewriter.create<hls::StreamWriteOp>(loc, channel, slice);
}

static void readStreamAndInsertSlice(ArrayRef<Value> ivs, Value channel,
                                     Value tensor, Location loc,
                                     PatternRewriter &rewriter,
                                     bool yieldInsertedTensor = true) {
  auto streamType = channel.getType().cast<StreamType>();
  auto [offsets, sizes, strides] =
      getSliceInfo(ivs, streamType.getIterMap().getResults(),
                   streamType.getElementShape(), loc, rewriter);
  auto slice = rewriter.create<hls::StreamReadOp>(
      loc, streamType.getElementType(), channel);
  auto result = rewriter.create<tensor::InsertSliceOp>(
      loc, slice.getResult(), tensor, offsets, sizes, strides);
  if (yieldInsertedTensor)
    rewriter.create<scf::YieldOp>(loc, result.getResult());
}

namespace {
struct LowerTensorToStreamConversionOp
    : public OpRewritePattern<hls::TensorToStreamOp> {
  using OpRewritePattern<hls::TensorToStreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TensorToStreamOp toStream,
                                PatternRewriter &rewriter) const override {
    auto streamType = toStream.getStream().getType();
    auto loc = toStream.getLoc();

    // Create a new stream channel, then construct a loop nest to extract stream
    // element from the tensor and write to the stream channel.
    auto channel = rewriter.create<hls::StreamOp>(loc, streamType);
    auto [ivs, result, iterArg] =
        constructLoops(streamType.getIterTripCounts(),
                       streamType.getIterSteps(), loc, rewriter);
    extactSliceAndWriteStream(ivs, channel, toStream.getTensor(), loc,
                              rewriter);

    // Replace the original stream channel with the new channel.
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

    // Create a new tensor, then construct a loop nest to read from the stream
    // channel and insert stream element to the tensor.
    auto init = rewriter.create<hls::TensorInitOp>(loc, tensorType);
    auto [ivs, result, iterArg] = constructLoops(streamType.getIterTripCounts(),
                                                 streamType.getIterSteps(), loc,
                                                 rewriter, init.getResult());
    readStreamAndInsertSlice(ivs, toTensor.getStream(), iterArg, loc, rewriter);

    // Replace the original tensor with the new tensor.
    rewriter.replaceAllUsesWith(toTensor.getTensor(), result);
    return success();
  }
};
} // namespace

namespace {
struct LowerStreamBufferOp : public OpRewritePattern<hls::StreamBufferOp> {
  using OpRewritePattern<hls::StreamBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamBufferOp streamBuffer,
                                PatternRewriter &rewriter) const override {
    auto inputType = streamBuffer.getInput().getType();
    auto outputType = streamBuffer.getOutput().getType();
    auto beforeLoop = streamBuffer.getBeforeLoop();
    auto loc = streamBuffer.getLoc();

    // Construct the output stream channel.
    auto channel = rewriter.create<hls::StreamOp>(loc, outputType);

    // Construct loops to iterate over the dimensions shared by input stream and
    // output stream.
    for (auto [tripCount, step] :
         llvm::zip(inputType.getIterTripCounts().take_front(beforeLoop),
                   inputType.getIterSteps().take_front(beforeLoop))) {
      auto [lbCst, ubCst, stepCst] =
          getLoopBoundsAndStep(tripCount, step, loc, rewriter);
      auto loop = rewriter.create<scf::ForOp>(loc, lbCst, ubCst, stepCst);
      rewriter.setInsertionPointToStart(loop.getBody());
    }

    // Instantiate a buffer tensor with specified shape and element type.
    auto bufferType = RankedTensorType::get(
        streamBuffer.getBufferShape(), streamBuffer.getBufferElementType());
    auto init = rewriter.create<hls::TensorInitOp>(loc, bufferType);
    auto zeroCst = rewriter.create<arith::ConstantIndexOp>(loc, 0);

    // Construct loops to read from the input stream channel and insert stream
    // element to the buffer tensor.
    auto [inputIvs, inputResult, inputIterArg] =
        constructLoops(inputType.getIterTripCounts().drop_front(beforeLoop),
                       inputType.getIterSteps().drop_front(beforeLoop), loc,
                       rewriter, init.getResult());
    SmallVector<Value> bufferInputIvs(beforeLoop, zeroCst);
    bufferInputIvs.append(inputIvs);
    readStreamAndInsertSlice(bufferInputIvs, streamBuffer.getInput(),
                             inputIterArg, loc, rewriter, inputIvs.size() > 0);

    // Construct loops to extract stream element from the buffer tensor and
    // write to the output stream channel.
    rewriter.setInsertionPointAfterValue(inputResult);
    auto [outputIvs, outputResult, outputIterArg] = constructLoops(
        outputType.getIterTripCounts().drop_front(beforeLoop),
        outputType.getIterSteps().drop_front(beforeLoop), loc, rewriter);
    SmallVector<Value> bufferOutputIvs(beforeLoop, zeroCst);
    bufferOutputIvs.append(outputIvs);
    extactSliceAndWriteStream(bufferOutputIvs, channel, inputResult, loc,
                              rewriter);

    // Replace the original output stream channel with the new channel.
    rewriter.replaceAllUsesWith(streamBuffer.getOutput(), channel);
    return success();
  }
};
} // namespace

namespace {
struct MaterializeStream : public MaterializeStreamBase<MaterializeStream> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<LowerTensorToStreamConversionOp>(context);
    patterns.add<LowerStreamToTensorConversionOp>(context);
    patterns.add<LowerStreamBufferOp>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createMaterializeStreamPass() {
  return std::make_unique<MaterializeStream>();
}