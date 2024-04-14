//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_MATERIALIZEITENSORDMA
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

/// Return the offsets, sizes, and strides of a slice given the loop induction
/// variables "ivs", the index expressions "indexExprs", the element shape
/// "elementShape".
static std::tuple<SmallVector<OpFoldResult>, SmallVector<OpFoldResult>,
                  SmallVector<OpFoldResult>>
getSliceInfo(ArrayRef<Value> ivs, ArrayRef<AffineExpr> indexExprs,
             ArrayRef<int64_t> elementShape, Location loc, bool packing,
             PatternRewriter &rewriter) {
  assert(indexExprs.size() == elementShape.size() &&
         "indices and element shape should have the same size");

  SmallVector<AffineExpr> newIndexExprs;
  if (packing) {
    assert(indexExprs.size() % 2 == 0 &&
           "packing requires even number of indices");
    auto unpackedRank = indexExprs.size() / 2;
    for (auto [expr, tileSize] :
         llvm::zip(indexExprs.take_back(unpackedRank),
                   elementShape.take_back(unpackedRank)))
      newIndexExprs.push_back(expr.floorDiv(tileSize));
    for (auto [expr, tileSize] :
         llvm::zip(indexExprs.take_back(unpackedRank),
                   elementShape.take_back(unpackedRank)))
      newIndexExprs.push_back(expr % tileSize);
  } else {
    newIndexExprs = {indexExprs.begin(), indexExprs.end()};
  }

  auto offsets = llvm::map_to_vector(newIndexExprs, [&](AffineExpr expr) {
    auto map = AffineMap::get(ivs.size(), 0, expr);
    auto apply = rewriter.create<affine::AffineApplyOp>(loc, map, ivs);
    return OpFoldResult(apply.getResult());
  });

  auto sizes = llvm::map_to_vector(elementShape, [&](int64_t size) {
    return OpFoldResult(rewriter.getI64IntegerAttr(size));
  });
  auto strides = SmallVector<OpFoldResult>(newIndexExprs.size(),
                                           rewriter.getI64IntegerAttr(1));
  return std::make_tuple(offsets, sizes, strides);
}

/// Extract a slice from the tensor and write to the iterative tensor.
static TypedValue<ITensorType>
extactSliceAndWriteITensor(ArrayRef<Value> ivs, TypedValue<ITensorType> iTensor,
                           TypedValue<RankedTensorType> tensor,
                           TypedValue<ITensorType> loopResult, Location loc,
                           bool packing, PatternRewriter &rewriter) {
  auto iTensorType = cast<ITensorType>(iTensor.getType());

  auto [offsets, sizes, strides] =
      getSliceInfo(ivs, iTensorType.getIterMap().getResults(),
                   iTensorType.getElementShape(), loc, packing, rewriter);
  Value slice = rewriter.create<tensor::ExtractSliceOp>(loc, tensor, offsets,
                                                        sizes, strides);
  return rewriter.create<hls::ITensorWriteOp>(loc, iTensorType, slice, iTensor);
}

/// Read from the iterative tensor and insert the slice to the tensor. If
/// "packing" is true, the slice is read from the iterative tensor and shape
/// expanded before inserting to the tensor.
static TypedValue<RankedTensorType>
readITensorAndInsertSlice(ArrayRef<Value> ivs, TypedValue<ITensorType> iTensor,
                          TypedValue<RankedTensorType> tensor,
                          TypedValue<RankedTensorType> loopResult, Location loc,
                          bool packing, PatternRewriter &rewriter) {
  auto iTensorType = iTensor.getType();
  auto [offsets, sizes, strides] =
      getSliceInfo(ivs, iTensorType.getIterMap().getResults(),
                   iTensorType.getElementShape(), loc, packing, rewriter);

  // As we are going to insert a tensor slice back to the "input" tensor, to
  // avoid unnecessary memory allocation and copy, we need to extract the slice
  // from the "input" tensor first.
  auto extractSlice = rewriter.create<tensor::ExtractSliceOp>(
      loc, tensor, offsets, sizes, strides);

  // Then we take the extracted tensor as the "init" operand of the stream read
  // op, making it a "payload-carried" style operation.
  auto slice = rewriter.create<hls::ITensorReadOp>(
      loc, iTensorType.getElementType(), iTensor, extractSlice.getResult());
  return rewriter.create<tensor::InsertSliceOp>(loc, slice, tensor, offsets,
                                                sizes, strides);
}

namespace {
struct MaterializeITensorWriteFullTensorOp
    : public OpRewritePattern<hls::ITensorWriteFullTensorOp> {
  using OpRewritePattern<hls::ITensorWriteFullTensorOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorWriteFullTensorOp writeFullTensor,
                                PatternRewriter &rewriter) const override {
    auto iTensorType = writeFullTensor.getResult().getType();
    auto loc = writeFullTensor.getLoc();

    // Create a new iterative tensor, then construct a loop nest to extract
    // stream element from the tensor and write to the iterative tensor.
    auto [ivs, result, iterArg] = constructLoops(
        iTensorType.getIterTripCounts(), iTensorType.getIterSteps(), loc,
        rewriter, writeFullTensor.getDest());
    auto newResult = extactSliceAndWriteITensor(
        ivs, cast<TypedValue<ITensorType>>(iterArg),
        writeFullTensor.getFullTensor(), cast<TypedValue<ITensorType>>(result),
        loc, writeFullTensor.getPacked(), rewriter);

    // Return "newResult" if no loop is constructed. Otherwise, create a new
    // yield op to yield "newResult" to "result".
    if (ivs.empty())
      result = newResult;
    else
      rewriter.create<scf::YieldOp>(loc, newResult);

    // Replace the original stream with the new stream.
    rewriter.replaceOp(writeFullTensor, result);
    return success();
  }
};
} // namespace

namespace {
struct MaterializeITensorReadFullTensorOp
    : public OpRewritePattern<hls::ITensorReadFullTensorOp> {
  using OpRewritePattern<hls::ITensorReadFullTensorOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorReadFullTensorOp readFullTensor,
                                PatternRewriter &rewriter) const override {
    auto iTensorType = readFullTensor.getSourceType();
    auto loc = readFullTensor.getLoc();

    // Create a new tensor, then construct a loop nest to read from the stream
    // channel and insert stream element to the tensor.
    auto [ivs, result, iterArg] = constructLoops(
        iTensorType.getIterTripCounts(), iTensorType.getIterSteps(), loc,
        rewriter, readFullTensor.getFullTensorInit());
    auto newResult =
        readITensorAndInsertSlice(ivs, readFullTensor.getSource(),
                                  cast<TypedValue<RankedTensorType>>(iterArg),
                                  cast<TypedValue<RankedTensorType>>(result),
                                  loc, readFullTensor.getPacked(), rewriter);

    // Return "newResult" if no loop is constructed. Otherwise, create a new
    // yield op to yield "newResult" to "result".
    if (ivs.empty())
      result = newResult;
    else
      rewriter.create<scf::YieldOp>(loc, newResult);

    // Replace the original tensor with the new tensor.
    rewriter.replaceOp(readFullTensor, result);
    return success();
  }
};
} // namespace

namespace {
struct MaterializeITensorBufferOp
    : public OpRewritePattern<hls::ITensorBufferOp> {
  using OpRewritePattern<hls::ITensorBufferOp>::OpRewritePattern;

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

    // Instantiate a buffer tensor with calculated buffer type.
    auto tensorEmpty = rewriter.create<tensor::EmptyOp>(
        loc, iTensorBuffer.getBufferType(), ValueRange());

    // Construct loops to read from the input iterative tensor and insert stream
    // element to the buffer tensor.
    auto zeroCst = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto [inputIvs, inputResult, inputIterArg] =
        constructLoops(sourceType.getIterTripCounts().drop_front(loopIndex),
                       sourceType.getIterSteps().drop_front(loopIndex), loc,
                       rewriter, tensorEmpty);
    SmallVector<Value> bufferInputIvs(loopIndex, zeroCst);
    bufferInputIvs.append(inputIvs);
    auto newInputResult = readITensorAndInsertSlice(
        bufferInputIvs, iTensorBuffer.getSource(),
        cast<TypedValue<RankedTensorType>>(inputIterArg),
        cast<TypedValue<RankedTensorType>>(inputResult), loc,
        iTensorBuffer.getPacked(), rewriter);

    // Return "newResult" if no loop is constructed. Otherwise, create a new
    // yield op to yield "newResult" to "result".
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
        cast<TypedValue<RankedTensorType>>(inputResult),
        cast<TypedValue<ITensorType>>(outputResult), loc,
        iTensorBuffer.getPacked(), rewriter);

    // Return "newResult" if no loop is constructed. Otherwise, create a new
    // yield op to yield "newResult" to "result".
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
};
} // namespace

namespace {
struct MaterializeITensorDMA
    : public hls::impl::MaterializeITensorDMABase<MaterializeITensorDMA> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<MaterializeITensorWriteFullTensorOp>(context);
    patterns.add<MaterializeITensorReadFullTensorOp>(context);
    patterns.add<MaterializeITensorBufferOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
