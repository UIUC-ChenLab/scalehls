//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
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
#define GEN_PASS_DEF_MATERIALIZEITENSOR
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

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

/// Extract a slice from the tensor and write to the iterative tensor. If
/// "packing" is true, the slice is extracted from the packed tensor and shape
/// collapsed before writing to the iterative tensor.
static TypedValue<ITensorType>
extactSliceAndWriteITensor(ArrayRef<Value> ivs, TypedValue<ITensorType> channel,
                           TypedValue<RankedTensorType> tensor, bool packing,
                           Location loc, PatternRewriter &rewriter) {
  auto iTensorType = cast<ITensorType>(channel.getType());

  auto [offsets, sizes, strides] =
      getSliceInfo(ivs, iTensorType.getIterMap().getResults(),
                   iTensorType.getElementShape(), packing, loc, rewriter);
  Value slice = rewriter.create<tensor::ExtractSliceOp>(loc, tensor, offsets,
                                                        sizes, strides);
  if (packing)
    slice = rewriter.create<tensor::CollapseShapeOp>(
        loc, slice, getPackingReassociation(iTensorType.getElementRank()));
  return rewriter.create<hls::ITensorWriteOp>(loc, iTensorType, slice, channel);
}

/// Read from the iterative tensor and insert the slice to the tensor. If
/// "packing" is true, the slice is read from the iterative tensor and shape
/// expanded before inserting to the tensor.
static TypedValue<RankedTensorType>
readITensorAndInsertSlice(ArrayRef<Value> ivs, TypedValue<ITensorType> channel,
                          TypedValue<RankedTensorType> tensor, bool packing,
                          Location loc, PatternRewriter &rewriter) {
  auto iTensorType = channel.getType();
  auto [offsets, sizes, strides] =
      getSliceInfo(ivs, iTensorType.getIterMap().getResults(),
                   iTensorType.getElementShape(), packing, loc, rewriter);

  // As we are going to insert a tensor slice back to the "input" tensor, to
  // avoid unnecessary memory allocation and copy, we need to extract the slice
  // from the "input" tensor first.
  auto extractSlice = rewriter.create<tensor::ExtractSliceOp>(
      loc, tensor, offsets, sizes, strides);
  auto init = extractSlice.getResult();
  if (packing)
    init = rewriter.create<tensor::CollapseShapeOp>(
        loc, init, getPackingReassociation(iTensorType.getElementRank()));

  // Then we take the extracted tensor as the "init" operand of the stream read
  // op, making it a "payload-carried" style operation.
  auto streamRead = rewriter.create<hls::ITensorReadOp>(
      loc, iTensorType.getElementType(), channel, init);
  auto slice = llvm::cast<TypedValue<RankedTensorType>>(streamRead.getResult());

  if (packing) {
    SmallVector<int64_t> expandedShape(iTensorType.getElementRank(), 1);
    expandedShape.append(iTensorType.getElementShape());
    auto expandedType =
        RankedTensorType::get(expandedShape, slice.getType().getElementType());
    slice = rewriter.create<tensor::ExpandShapeOp>(
        loc, expandedType, slice,
        getPackingReassociation(iTensorType.getElementRank()));
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
struct MaterializeITensorWriteFullTensorOp
    : public OpRewritePattern<hls::ITensorWriteFullTensorOp> {
  MaterializeITensorWriteFullTensorOp(MLIRContext *context,
                                      bool enablePacking = true,
                                      PatternBenefit benefit = 1,
                                      ArrayRef<StringRef> generatedNames = {})
      : OpRewritePattern(context, benefit, generatedNames),
        enablePacking(enablePacking) {}

  LogicalResult matchAndRewrite(hls::ITensorWriteFullTensorOp toITensor,
                                PatternRewriter &rewriter) const override {
    auto iTensorType = toITensor.getResult().getType();
    auto loc = toITensor.getLoc();

    // Only if the stream type is not overlapped, we can pack the tensor to make
    // more efficient memory access pattern.
    auto packing = enablePacking && iTensorType.tileIsRegular() &&
                   iTensorType.getRank() > 1;
    auto source = toITensor.getFullTensor();
    if (packing)
      source = packTensor(source, iTensorType.getElementShape(), loc, rewriter);

    // Create a new iterative tensor, then construct a loop nest to extract
    // stream element from the tensor and write to the iterative tensor.
    auto [ivs, result, iterArg] = constructLoops(
        iTensorType.getIterTripCounts(), iTensorType.getIterSteps(), loc,
        rewriter, toITensor.getDest());
    auto newResult =
        extactSliceAndWriteITensor(ivs, cast<TypedValue<ITensorType>>(iterArg),
                                   source, packing, loc, rewriter);

    // Update "result" if no loop is constructed. Otherwise, create a new yield
    // op to yield "newResult" to "result".
    if (ivs.empty())
      result = newResult;
    else
      rewriter.create<scf::YieldOp>(loc, newResult);

    // Replace the original stream with the new stream.
    rewriter.replaceOp(toITensor, result);
    return success();
  }

private:
  bool enablePacking = true;
};
} // namespace

namespace {
struct MaterializeITensorReadFullTensorOp
    : public OpRewritePattern<hls::ITensorReadFullTensorOp> {
  MaterializeITensorReadFullTensorOp(MLIRContext *context,
                                     bool enablePacking = true,
                                     PatternBenefit benefit = 1,
                                     ArrayRef<StringRef> generatedNames = {})
      : OpRewritePattern(context, benefit, generatedNames),
        enablePacking(enablePacking) {}

  LogicalResult matchAndRewrite(hls::ITensorReadFullTensorOp toTensor,
                                PatternRewriter &rewriter) const override {
    auto iTensorType = toTensor.getSourceType();
    auto loc = toTensor.getLoc();

    // Only if the stream type is not overlapped, we can pack the tensor to make
    // more efficient memory access pattern.
    auto packing = enablePacking && iTensorType.tileIsRegular() &&
                   iTensorType.getRank() > 1;
    auto targetType = toTensor.getResult().getType();
    if (packing)
      targetType = getPackedType(targetType, iTensorType.getElementShape());

    // Create a new tensor, then construct a loop nest to read from the stream
    // channel and insert stream element to the tensor.
    auto tensorInit = rewriter.create<hls::TensorInitOp>(loc, targetType);
    auto [ivs, result, iterArg] =
        constructLoops(iTensorType.getIterTripCounts(),
                       iTensorType.getIterSteps(), loc, rewriter, tensorInit);
    auto newResult = readITensorAndInsertSlice(
        ivs, toTensor.getSource(), cast<TypedValue<RankedTensorType>>(iterArg),
        packing, loc, rewriter);

    // Update "result" if no loop is constructed. Otherwise, create a new yield
    // op to yield "newResult" to "result".
    if (ivs.empty())
      result = newResult;
    else
      rewriter.create<scf::YieldOp>(loc, newResult);

    // Handle the case where the tensor is packed.
    if (packing) {
      rewriter.setInsertionPointAfterValue(result);
      result = unpackTensor(cast<TypedValue<RankedTensorType>>(result),
                            iTensorType.getElementShape(), loc, rewriter);
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
struct MaterializeITensorBufferOp
    : public OpRewritePattern<hls::ITensorBufferOp> {
  MaterializeITensorBufferOp(MLIRContext *context, bool enablePacking = true,
                             PatternBenefit benefit = 1,
                             ArrayRef<StringRef> generatedNames = {})
      : OpRewritePattern(context, benefit, generatedNames),
        enablePacking(enablePacking) {}

  LogicalResult matchAndRewrite(hls::ITensorBufferOp iTensorBuffer,
                                PatternRewriter &rewriter) const override {
    auto sourceType = iTensorBuffer.getSource().getType();
    auto resultType = iTensorBuffer.getResult().getType();
    auto loopIndex = iTensorBuffer.getLoopIndex();
    auto loc = iTensorBuffer.getLoc();

    // Construct loops to iterate over the dimensions shared by input stream and
    // output stream.
    auto [ivs, result, iterArg] =
        constructLoops(sourceType.getIterTripCounts().take_front(loopIndex),
                       sourceType.getIterSteps().take_front(loopIndex), loc,
                       rewriter, iTensorBuffer.getDest());

    // Calculate the maximum tile sizes.
    auto maxTileSizes = llvm::map_to_vector(
        llvm::zip(sourceType.getElementShape(), resultType.getElementShape()),
        [&](std::tuple<int64_t, int64_t> shapes) {
          return std::max(std::get<0>(shapes), std::get<1>(shapes));
        });

    // Get the buffer type and packed buffer type if necessary.
    auto packing = enablePacking && sourceType.tileIsRegular() &&
                   resultType.tileIsRegular() &&
                   (sourceType.getRank() > 1 || resultType.getRank() > 1);
    auto bufferType = RankedTensorType::get(
        iTensorBuffer.getBufferShape(), iTensorBuffer.getBufferElementType());
    if (packing)
      bufferType = getPackedType(bufferType, maxTileSizes);

    // Instantiate a buffer tensor with calculated buffer type.
    auto tensorInit = rewriter.create<hls::TensorInitOp>(loc, bufferType);

    // Construct loops to read from the input iterative tensor and insert stream
    // element to the buffer tensor.
    auto zeroCst = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto [inputIvs, inputResult, inputIterArg] =
        constructLoops(sourceType.getIterTripCounts().drop_front(loopIndex),
                       sourceType.getIterSteps().drop_front(loopIndex), loc,
                       rewriter, tensorInit);
    SmallVector<Value> bufferInputIvs(loopIndex, zeroCst);
    bufferInputIvs.append(inputIvs);
    auto newInputResult = readITensorAndInsertSlice(
        bufferInputIvs, iTensorBuffer.getSource(),
        cast<TypedValue<RankedTensorType>>(inputIterArg), packing, loc,
        rewriter);

    // Update "inputResult" if no input loop is constructed. Otherwise, create a
    // new yield op to yield "newInputResult" to "inputResult".
    if (inputIvs.empty())
      inputResult = newInputResult;
    else
      rewriter.create<scf::YieldOp>(loc, newInputResult);

    // Construct loops to extract stream element from the buffer tensor and
    // write to the output iterative tensor.
    rewriter.setInsertionPointAfterValue(inputResult);
    auto [outputIvs, outputResult, outputIterArg] =
        constructLoops(resultType.getIterTripCounts().drop_front(loopIndex),
                       resultType.getIterSteps().drop_front(loopIndex), loc,
                       rewriter, iterArg);
    SmallVector<Value> bufferOutputIvs(loopIndex, zeroCst);
    bufferOutputIvs.append(outputIvs);
    auto newOutputResult = extactSliceAndWriteITensor(
        bufferOutputIvs, cast<TypedValue<ITensorType>>(outputIterArg),
        cast<TypedValue<RankedTensorType>>(inputResult), packing, loc,
        rewriter);

    // Update "outputResult" if no output loop is constructed. Otherwise, create
    // a new yield op to yield "newOutputResult" to "outputResult".
    if (outputIvs.empty())
      outputResult = newOutputResult;
    else
      rewriter.create<scf::YieldOp>(loc, newOutputResult);

    // Update "result" if no shared loop is constructed. Otherwise, create a new
    // yield op to yield "newResult" to "result".
    rewriter.setInsertionPointAfterValue(outputResult);
    if (ivs.empty())
      result = outputResult;
    else
      rewriter.create<scf::YieldOp>(loc, outputResult);

    // Replace the original stream with the new stream.
    rewriter.replaceOp(iTensorBuffer, result);
    return success();
  }

private:
  bool enablePacking = true;
};
} // namespace

namespace {
struct LowerPackOp : public OpRewritePattern<tensor::PackOp> {
  using OpRewritePattern<tensor::PackOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tensor::PackOp pack,
                                PatternRewriter &rewriter) const override {
    if (pack.getPaddingValue() ||
        !pack.getSource().getDefiningOp<arith::ConstantOp>())
      return failure();
    return linalg::lowerPack(rewriter, pack);
  }
};
} // namespace

namespace {
struct MaterializeITensor
    : public hls::impl::MaterializeITensorBase<MaterializeITensor> {
  using Base::Base;

  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<MaterializeITensorWriteFullTensorOp>(context, enablePacking);
    patterns.add<MaterializeITensorReadFullTensorOp>(context, enablePacking);
    patterns.add<MaterializeITensorBufferOp>(context, enablePacking);
    if (enablePacking) {
      patterns.add<LowerPackOp>(context);
      patterns.add<linalg::LinalgGeneralizationPattern>(context);
      linalg::populateConstantFoldLinalgOperations(
          patterns, [&](OpOperand *fusedOperand) { return true; });
    }
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace
