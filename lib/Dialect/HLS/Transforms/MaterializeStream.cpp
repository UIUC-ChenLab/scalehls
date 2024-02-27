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

/// Return the offsets, sizes, and strides of a slice given the loop induction
/// variables "ivs", the index expressions "indexExprs", the element shape
/// "elementShape", and the packing flag "packing". If "packing" is true, the
/// offsets, sizes, and strides are for the packed tensor; otherwise, they are
/// for the unpacked tensor.
static std::tuple<SmallVector<OpFoldResult>, SmallVector<OpFoldResult>,
                  SmallVector<OpFoldResult>>
getSliceInfo(ArrayRef<Value> ivs, ArrayRef<AffineExpr> indexExprs,
             ArrayRef<int64_t> elementShape, bool packing, Location loc,
             PatternRewriter &rewriter) {
  assert(indexExprs.size() == elementShape.size() &&
         "indices and element shape should have the same size");

  auto offsets = llvm::map_to_vector(
      llvm::zip(indexExprs, elementShape),
      [&](std::tuple<AffineExpr, int64_t> tuple) {
        auto [expr, tileSize] = tuple;
        if (packing)
          expr = expr.floorDiv(tileSize);
        auto map = AffineMap::get(ivs.size(), 0, expr);
        auto apply = rewriter.create<affine::AffineApplyOp>(loc, map, ivs);
        return OpFoldResult(apply.getResult());
      });
  if (packing)
    offsets.append(elementShape.size(), rewriter.getI64IntegerAttr(0));

  auto sizes = llvm::map_to_vector(elementShape, [&](int64_t size) {
    return OpFoldResult(rewriter.getI64IntegerAttr(size));
  });
  if (packing)
    sizes.insert(sizes.begin(), elementShape.size(),
                 rewriter.getI64IntegerAttr(1));

  auto strides = SmallVector<OpFoldResult>(indexExprs.size(),
                                           rewriter.getI64IntegerAttr(1));
  if (packing)
    strides.append(elementShape.size(), rewriter.getI64IntegerAttr(1));

  return std::make_tuple(offsets, sizes, strides);
}

/// Get the reassociation indices list between a packed tensor and an unpacked
/// tensor of the same shape. Specifically, given a 3-d tensor (d0, d1, d2), the
/// shape of the packed tensor is (1, 1, 1, d0, d1, d2), which means the
/// reassociation indices list is [[0, 1, 2, 3], [4], [5]].
static SmallVector<ReassociationIndices> getPackingReassociation(int64_t rank) {
  SmallVector<ReassociationIndices> reassociation;
  for (int64_t i = 0; i < rank; i++) {
    ReassociationIndices reassociationIndices;
    if (i == 0)
      reassociationIndices =
          llvm::map_to_vector(llvm::seq(rank), [&](int64_t j) { return j; });
    reassociationIndices.push_back(rank + i);
    reassociation.push_back(reassociationIndices);
  }
  return reassociation;
}

/// Extract a slice from the tensor and write to the stream channel. If
/// "packing" is true, the slice is extracted from the packed tensor and shape
/// collapsed before writing to the stream channel.
static void extactSliceAndWriteStream(ArrayRef<Value> ivs,
                                      TypedValue<StreamType> channel,
                                      TypedValue<RankedTensorType> tensor,
                                      bool packing, Location loc,
                                      PatternRewriter &rewriter) {
  auto streamType = channel.getType();
  auto [offsets, sizes, strides] =
      getSliceInfo(ivs, streamType.getIterMap().getResults(),
                   streamType.getElementShape(), packing, loc, rewriter);
  Value slice = rewriter.create<tensor::ExtractSliceOp>(loc, tensor, offsets,
                                                        sizes, strides);
  if (packing)
    slice = rewriter.create<tensor::CollapseShapeOp>(
        loc, slice, getPackingReassociation(streamType.getElementRank()));
  rewriter.create<hls::StreamWriteOp>(loc, channel, slice);
}

/// Read from the stream channel and insert the slice to the tensor. If
/// "packing" is true, the slice is read from the stream channel and shape
/// expanded before inserting to the tensor.
static TypedValue<RankedTensorType>
readStreamAndInsertSlice(ArrayRef<Value> ivs, TypedValue<StreamType> channel,
                         TypedValue<RankedTensorType> tensor, bool packing,
                         Location loc, PatternRewriter &rewriter) {
  auto streamType = channel.getType();
  auto [offsets, sizes, strides] =
      getSliceInfo(ivs, streamType.getIterMap().getResults(),
                   streamType.getElementShape(), packing, loc, rewriter);

  // As we are going to insert a tensor slice back to the "input" tensor, to
  // avoid unnecessary memory allocation and copy, we need to extract the slice
  // from the "input" tensor first.
  auto extractSlice = rewriter.create<tensor::ExtractSliceOp>(
      loc, tensor, offsets, sizes, strides);
  auto init =
      llvm::cast<TypedValue<RankedTensorType>>(extractSlice.getResult());
  if (packing)
    init = rewriter.create<tensor::CollapseShapeOp>(
        loc, init, getPackingReassociation(streamType.getElementRank()));

  // Then we take the extracted tensor as the "init" operand of the stream read
  // op, making it a "payload-carried" style operation.
  auto streamRead = rewriter.create<hls::StreamReadOp>(
      loc, streamType.getElementType(), channel, init);
  auto slice = llvm::cast<TypedValue<RankedTensorType>>(streamRead.getResult());

  if (packing) {
    SmallVector<int64_t> expandedShape(streamType.getElementRank(), 1);
    expandedShape.append(streamType.getElementShape());
    auto expandedType =
        RankedTensorType::get(expandedShape, slice.getType().getElementType());
    slice = rewriter.create<tensor::ExpandShapeOp>(
        loc, expandedType, slice,
        getPackingReassociation(streamType.getElementRank()));
  }
  return rewriter.create<tensor::InsertSliceOp>(loc, slice, tensor, offsets,
                                                sizes, strides);
}

static RankedTensorType getPackedType(RankedTensorType tensorType,
                                      ArrayRef<int64_t> tileSizes) {
  auto packedShape =
      llvm::map_to_vector(llvm::zip(tensorType.getShape(), tileSizes),
                          [&](std::tuple<int64_t, int64_t> shape) {
                            return std::get<0>(shape) / std::get<1>(shape);
                          });
  packedShape.append(tileSizes.begin(), tileSizes.end());
  return RankedTensorType::get(packedShape, tensorType.getElementType());
}

static RankedTensorType getUnpackedType(RankedTensorType tensorType,
                                        ArrayRef<int64_t> tileSizes) {
  auto unpackedShape = llvm::map_to_vector(
      llvm::zip(tensorType.getShape().take_front(tileSizes.size()), tileSizes),
      [&](std::tuple<int64_t, int64_t> shape) {
        return std::get<0>(shape) * std::get<1>(shape);
      });
  return RankedTensorType::get(unpackedShape, tensorType.getElementType());
}

static TypedValue<RankedTensorType>
packTensor(TypedValue<RankedTensorType> tensor, ArrayRef<int64_t> tileSizes,
           Location loc, PatternRewriter &rewriter) {
  auto packedType = getPackedType(tensor.getType(), tileSizes);

  auto init = rewriter.create<hls::TensorInitOp>(loc, packedType);
  auto innerDimsPos = llvm::map_to_vector(llvm::seq<int64_t>(tileSizes.size()),
                                          [&](int64_t i) { return i; });
  auto innerTiles = llvm::map_to_vector(tileSizes, [&](int64_t tileSize) {
    return OpFoldResult(rewriter.getI64IntegerAttr(tileSize));
  });

  return rewriter.create<tensor::PackOp>(loc, tensor, init, innerDimsPos,
                                         innerTiles);
}

static TypedValue<RankedTensorType>
unpackTensor(TypedValue<RankedTensorType> tensor, ArrayRef<int64_t> tileSizes,
             Location loc, PatternRewriter &rewriter) {
  auto unpackedType = getUnpackedType(tensor.getType(), tileSizes);

  auto init = rewriter.create<hls::TensorInitOp>(loc, unpackedType);
  auto innerDimsPos = llvm::map_to_vector(llvm::seq<int64_t>(tileSizes.size()),
                                          [&](int64_t i) { return i; });
  auto innerTiles = llvm::map_to_vector(tileSizes, [&](int64_t tileSize) {
    return OpFoldResult(rewriter.getI64IntegerAttr(tileSize));
  });

  return rewriter.create<tensor::UnPackOp>(loc, tensor, init, innerDimsPos,
                                           innerTiles);
}

namespace {
struct MaterializeStreamFromTensorOp
    : public OpRewritePattern<hls::StreamFromTensorOp> {
  MaterializeStreamFromTensorOp(MLIRContext *context, bool enablePacking = true,
                                PatternBenefit benefit = 1,
                                ArrayRef<StringRef> generatedNames = {})
      : OpRewritePattern(context, benefit, generatedNames),
        enablePacking(enablePacking) {}

  LogicalResult matchAndRewrite(hls::StreamFromTensorOp fromTensor,
                                PatternRewriter &rewriter) const override {
    auto streamType = fromTensor.getStreamType();
    auto loc = fromTensor.getLoc();

    // Only if the stream type is not overlapped, we can pack the tensor to make
    // more efficient memory access pattern.
    auto packing =
        enablePacking && streamType.tileIsRegular() && streamType.getRank() > 1;
    auto source = fromTensor.getTensor();
    if (packing)
      source = packTensor(source, streamType.getElementShape(), loc, rewriter);

    // Create a new stream channel, then construct a loop nest to extract
    // stream element from the tensor and write to the stream channel.
    auto [ivs, result, iterArg] =
        constructLoops(streamType.getIterTripCounts(),
                       streamType.getIterSteps(), loc, rewriter);
    extactSliceAndWriteStream(ivs, fromTensor.getStream(), source, packing, loc,
                              rewriter);
    rewriter.eraseOp(fromTensor);
    return success();
  }

private:
  bool enablePacking = true;
};
} // namespace

namespace {
struct MaterializeStreamToTensorOp
    : public OpRewritePattern<hls::StreamToTensorOp> {
  MaterializeStreamToTensorOp(MLIRContext *context, bool enablePacking = true,
                              PatternBenefit benefit = 1,
                              ArrayRef<StringRef> generatedNames = {})
      : OpRewritePattern(context, benefit, generatedNames),
        enablePacking(enablePacking) {}

  LogicalResult matchAndRewrite(hls::StreamToTensorOp toTensor,
                                PatternRewriter &rewriter) const override {
    auto streamType = toTensor.getStreamType();
    auto loc = toTensor.getLoc();

    // Only if the stream type is not overlapped, we can pack the tensor to make
    // more efficient memory access pattern.
    auto packing =
        enablePacking && streamType.tileIsRegular() && streamType.getRank() > 1;
    auto targetType = toTensor.getTensor().getType();
    if (packing)
      targetType = getPackedType(targetType, streamType.getElementShape());

    // Create a new tensor, then construct a loop nest to read from the stream
    // channel and insert stream element to the tensor.
    auto init = rewriter.create<hls::TensorInitOp>(loc, targetType);
    auto [ivs, result, iterArg] = constructLoops(streamType.getIterTripCounts(),
                                                 streamType.getIterSteps(), loc,
                                                 rewriter, init.getResult());
    auto newResult = readStreamAndInsertSlice(ivs, toTensor.getStream(),
                                              iterArg, packing, loc, rewriter);

    // Update "result" if no loop is constructed. Otherwise, create a new yield
    // op to yield "newResult" to "result".
    if (ivs.empty())
      result = newResult;
    else
      rewriter.create<scf::YieldOp>(loc, newResult);

    // Handle the case where the tensor is packed.
    if (packing) {
      rewriter.setInsertionPointAfterValue(result);
      result =
          unpackTensor(result, streamType.getElementShape(), loc, rewriter);
    }

    // Replace the original tensor with the new tensor.
    rewriter.replaceOp(toTensor, result);
    return success();
  }

private:
  bool enablePacking = true;
};
} // namespace

namespace {
struct MaterializeStreamBufferOp
    : public OpRewritePattern<hls::StreamBufferOp> {
  MaterializeStreamBufferOp(MLIRContext *context, bool enablePacking = true,
                            PatternBenefit benefit = 1,
                            ArrayRef<StringRef> generatedNames = {})
      : OpRewritePattern(context, benefit, generatedNames),
        enablePacking(enablePacking) {}

  LogicalResult matchAndRewrite(hls::StreamBufferOp streamBuffer,
                                PatternRewriter &rewriter) const override {
    auto sourceType = streamBuffer.getSourceType();
    auto destType = streamBuffer.getDestType();
    auto loopIndex = streamBuffer.getLoopIndex();
    auto loc = streamBuffer.getLoc();

    // Construct loops to iterate over the dimensions shared by input stream and
    // output stream.
    for (auto [tripCount, step] :
         llvm::zip(sourceType.getIterTripCounts().take_front(loopIndex),
                   sourceType.getIterSteps().take_front(loopIndex))) {
      auto [lbCst, ubCst, stepCst] =
          getLoopBoundsAndStep(tripCount, step, loc, rewriter);
      auto loop = rewriter.create<scf::ForOp>(loc, lbCst, ubCst, stepCst);
      rewriter.setInsertionPointToStart(loop.getBody());
    }

    // Calculate the maximum tile sizes.
    auto maxTileSizes = llvm::map_to_vector(
        llvm::zip(sourceType.getElementShape(), destType.getElementShape()),
        [&](std::tuple<int64_t, int64_t> shapes) {
          return std::max(std::get<0>(shapes), std::get<1>(shapes));
        });

    // Get the buffer type and packed buffer type if necessary.
    auto packing = enablePacking && sourceType.tileIsRegular() &&
                   destType.tileIsRegular() &&
                   (sourceType.getRank() > 1 || destType.getRank() > 1);
    auto bufferType = RankedTensorType::get(
        streamBuffer.getBufferShape(), streamBuffer.getBufferElementType());
    if (packing)
      bufferType = getPackedType(bufferType, maxTileSizes);

    // Instantiate a buffer tensor with calculated buffer type.
    auto init = rewriter.create<hls::TensorInitOp>(loc, bufferType);

    // Construct loops to read from the input stream channel and insert stream
    // element to the buffer tensor.
    auto zeroCst = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto [inputIvs, inputResult, inputIterArg] =
        constructLoops(sourceType.getIterTripCounts().drop_front(loopIndex),
                       sourceType.getIterSteps().drop_front(loopIndex), loc,
                       rewriter, init.getResult());
    SmallVector<Value> bufferInputIvs(loopIndex, zeroCst);
    bufferInputIvs.append(inputIvs);
    auto newInputResult =
        readStreamAndInsertSlice(bufferInputIvs, streamBuffer.getSource(),
                                 inputIterArg, packing, loc, rewriter);

    // Update "inputResult" if no loop is constructed. Otherwise, create a new
    // yield op to yield "newInputResult" to "inputResult".
    if (inputIvs.empty())
      inputResult = newInputResult;
    else
      rewriter.create<scf::YieldOp>(loc, newInputResult);

    // Construct loops to extract stream element from the buffer tensor and
    // write to the output stream channel.
    rewriter.setInsertionPointAfterValue(inputResult);
    auto [outputIvs, outputResult, outputIterArg] = constructLoops(
        destType.getIterTripCounts().drop_front(loopIndex),
        destType.getIterSteps().drop_front(loopIndex), loc, rewriter);
    SmallVector<Value> bufferOutputIvs(loopIndex, zeroCst);
    bufferOutputIvs.append(outputIvs);
    extactSliceAndWriteStream(bufferOutputIvs, streamBuffer.getDest(),
                              inputResult, packing, loc, rewriter);
    rewriter.eraseOp(streamBuffer);
    return success();
  }

private:
  bool enablePacking = true;
};
} // namespace

namespace {
struct FoldPackOpIntoConstantOp : public OpRewritePattern<tensor::PackOp> {
  using OpRewritePattern<tensor::PackOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tensor::PackOp pack,
                                PatternRewriter &rewriter) const override {
    return failure();
  }
};
} // namespace

namespace {
struct MaterializeStream : public MaterializeStreamBase<MaterializeStream> {
  MaterializeStream() = default;
  MaterializeStream(bool optEnablePacking = true) {
    enablePacking = optEnablePacking;
  }

  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<MaterializeStreamFromTensorOp>(context, enablePacking);
    patterns.add<MaterializeStreamToTensorOp>(context, enablePacking);
    patterns.add<MaterializeStreamBufferOp>(context, enablePacking);
    if (enablePacking)
      patterns.add<FoldPackOpIntoConstantOp>(context);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::hls::createMaterializeStreamPass(bool enablePacking) {
  return std::make_unique<MaterializeStream>(enablePacking);
}