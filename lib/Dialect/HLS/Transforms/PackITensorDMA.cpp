//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Dialect/Tensor/Transforms/Transforms.h"
#include "mlir/Dialect/Utils/ReshapeOpsUtils.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_PACKITENSORDMA
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

static tensor::PackOp packTensor(TypedValue<RankedTensorType> tensor,
                                 ArrayRef<int64_t> tileSizes, Location loc,
                                 PatternRewriter &rewriter) {
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

static tensor::UnPackOp unpackTensor(TypedValue<RankedTensorType> tensor,
                                     ArrayRef<int64_t> tileSizes, Location loc,
                                     PatternRewriter &rewriter) {
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

static hls::ITensorType getPackedItensorType(hls::ITensorType iTensorType) {
  OpBuilder builder(iTensorType.getContext());
  auto packedElementType =
      getPackedType(cast<RankedTensorType>(iTensorType.getElementType()),
                    iTensorType.getElementShape());
  SmallVector<AffineExpr> packedExprs(iTensorType.getRank(),
                                      builder.getAffineConstantExpr(0));
  for (auto expr : iTensorType.getIterMap().getResults())
    packedExprs.push_back(expr);
  auto packedIterMap = AffineMap::get(iTensorType.getIterRank(), 0, packedExprs,
                                      iTensorType.getContext());
  return hls::ITensorType::get(
      packedElementType, iTensorType.getIterTripCounts(),
      iTensorType.getIterSteps(), packedIterMap, iTensorType.getDepth());
}

/// Get the reassociation indices list between a packed tensor and an unpacked
/// tensor of the same shape. Specifically, given a 3-d tensor (d0, d1, d2), the
/// shape of the packed tensor is (1, 1, 1, d0, d1, d2), which means the
/// reassociation indices list is [[0, 1, 2, 3], [4], [5]].
static ArrayAttr getPackingReassociationAttr(int64_t rank,
                                             PatternRewriter &rewriter) {
  SmallVector<ReassociationIndices> reassociation;
  for (int64_t i = 0; i < rank; i++) {
    ReassociationIndices reassociationIndices;
    if (i == 0)
      reassociationIndices =
          llvm::map_to_vector(llvm::seq(rank), [&](int64_t j) { return j; });
    reassociationIndices.push_back(rank + i);
    reassociation.push_back(reassociationIndices);
  }
  return getReassociationIndicesAttribute(rewriter, reassociation);
}

static ArrayAttr getIdenticalReassociationAttr(int64_t rank,
                                               PatternRewriter &rewriter) {
  auto reassociation = llvm::map_to_vector(
      llvm::seq(rank), [&](int64_t i) { return ReassociationIndices(1, i); });
  return getReassociationIndicesAttribute(rewriter, reassociation);
}

namespace {
struct PackITensorWriteFullTensorOp
    : public OpRewritePattern<hls::ITensorWriteFullTensorOp> {
  using OpRewritePattern<hls::ITensorWriteFullTensorOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorWriteFullTensorOp writeFullTensor,
                                PatternRewriter &rewriter) const override {
    if (writeFullTensor.getPacked())
      return failure();

    auto iTensorType = writeFullTensor.getResultType();
    if (!iTensorType.tileIsRegular() || iTensorType.getRank() == 1)
      return failure();

    // Pack the full tensor to be written.
    auto loc = writeFullTensor.getLoc();
    auto packedTensor =
        packTensor(writeFullTensor.getFullTensor(),
                   iTensorType.getElementShape(), loc, rewriter);

    auto packedITensorType = getPackedItensorType(iTensorType);
    auto shapeReasAttr =
        getPackingReassociationAttr(iTensorType.getRank(), rewriter);
    auto iterReasAttr =
        getIdenticalReassociationAttr(iTensorType.getIterRank(), rewriter);

    // Pack the destination itensor through reassociation.
    auto packedITensor = rewriter.create<hls::ITensorReassociateOp>(
        loc, packedITensorType, writeFullTensor.getDest(), /*expandShape=*/true,
        shapeReasAttr, /*expandIteration=*/true, iterReasAttr);

    // Update the writeFullTensor op.
    rewriter.modifyOpInPlace(writeFullTensor, [&]() {
      writeFullTensor.getDestMutable().assign(packedITensor);
      writeFullTensor.getFullTensorMutable().assign(packedTensor);
      writeFullTensor.getResult().setType(packedITensorType);
      writeFullTensor.setPacked(true);
    });

    // Unpack the result itensor through reassociation.
    rewriter.setInsertionPointAfter(writeFullTensor);
    auto unpackedITensor = rewriter.create<hls::ITensorReassociateOp>(
        loc, iTensorType, writeFullTensor.getResult(), /*expandShape=*/false,
        shapeReasAttr, /*expandIteration=*/false, iterReasAttr);
    rewriter.replaceAllUsesExcept(writeFullTensor, unpackedITensor,
                                  unpackedITensor);
    return success();
  }
};
} // namespace

namespace {
struct PackITensorReadFullTensorOp
    : public OpRewritePattern<hls::ITensorReadFullTensorOp> {
  using OpRewritePattern<hls::ITensorReadFullTensorOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorReadFullTensorOp readFullTensor,
                                PatternRewriter &rewriter) const override {
    if (readFullTensor.getPacked())
      return failure();

    auto iTensorType = readFullTensor.getSourceType();
    if (!iTensorType.tileIsRegular() || iTensorType.getRank() == 1)
      return failure();

    // Pack the init full tensor.
    auto loc = readFullTensor.getLoc();
    TypedValue<RankedTensorType> packedFullTensorInit;
    if (auto init = readFullTensor.getFullTensorInit()
                        .getDefiningOp<hls::TensorInitOp>())
      packedFullTensorInit = rewriter.create<hls::TensorInitOp>(
          loc, getPackedType(init.getType(), iTensorType.getElementShape()),
          init.getInitValueAttr());
    else
      packedFullTensorInit =
          packTensor(readFullTensor.getFullTensorInit(),
                     iTensorType.getElementShape(), loc, rewriter);

    auto packedITensorType = getPackedItensorType(iTensorType);
    auto shapeReasAttr =
        getPackingReassociationAttr(iTensorType.getRank(), rewriter);
    auto iterReasAttr =
        getIdenticalReassociationAttr(iTensorType.getIterRank(), rewriter);

    auto packedITensor = rewriter.create<hls::ITensorReassociateOp>(
        loc, packedITensorType, readFullTensor.getSource(),
        /*expandShape=*/true, shapeReasAttr, /*expandIteration=*/true,
        iterReasAttr);

    // Update the readFullTensor op.
    rewriter.modifyOpInPlace(readFullTensor, [&]() {
      readFullTensor.getSourceMutable().assign(packedITensor);
      readFullTensor.getFullTensorInitMutable().assign(packedFullTensorInit);
      readFullTensor.getFullTensor().setType(packedFullTensorInit.getType());
      readFullTensor.setPacked(true);
    });

    // Unpack the result full tensor.
    rewriter.setInsertionPointAfter(readFullTensor);
    auto unpackedFullTensor =
        unpackTensor(readFullTensor.getFullTensor(),
                     iTensorType.getElementShape(), loc, rewriter);
    rewriter.replaceAllUsesExcept(readFullTensor, unpackedFullTensor,
                                  unpackedFullTensor);
    return success();
  }
};
} // namespace

namespace {
struct PackITensorBufferOp : public OpRewritePattern<hls::ITensorBufferOp> {
  using OpRewritePattern<hls::ITensorBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorBufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (buffer.getPacked())
      return failure();

    auto sourceType = buffer.getSourceType();
    auto resultType = buffer.getResultType();
    if (!sourceType.tileIsRegular() || !resultType.tileIsRegular() ||
        (sourceType.getRank() == 1 && resultType.getRank() == 1))
      return failure();

    auto packedSourceType = getPackedItensorType(sourceType);
    auto sourceShapeReasAttr =
        getPackingReassociationAttr(sourceType.getRank(), rewriter);
    auto sourceIterReasAttr =
        getIdenticalReassociationAttr(sourceType.getIterRank(), rewriter);

    auto packedResultType = getPackedItensorType(resultType);
    auto resultShapeReasAttr =
        getPackingReassociationAttr(resultType.getRank(), rewriter);
    auto resultIterReasAttr =
        getIdenticalReassociationAttr(resultType.getIterRank(), rewriter);

    // Pack the source and dest itensor.
    auto loc = buffer.getLoc();
    auto packedSource = rewriter.create<hls::ITensorReassociateOp>(
        loc, packedSourceType, buffer.getSource(), /*expandShape=*/true,
        sourceShapeReasAttr, /*expandIteration=*/true, sourceIterReasAttr);
    auto packedDest = rewriter.create<hls::ITensorReassociateOp>(
        loc, packedResultType, buffer.getDest(), /*expandShape=*/true,
        resultShapeReasAttr, /*expandIteration=*/true, resultIterReasAttr);

    auto packSizes = buffer.getPackSizes();
    auto packedBufferType = getPackedType(buffer.getBufferType(), packSizes);
    rewriter.modifyOpInPlace(buffer, [&]() {
      buffer.getSourceMutable().assign(packedSource);
      buffer.getDestMutable().assign(packedDest);
      buffer.setBufferType(packedBufferType);
      buffer.setDimIndex(buffer.getDimIndex() + packSizes.size());
      buffer.getResult().setType(packedResultType);
      buffer.setPacked(true);
    });

    // Unpack the result itensor.
    rewriter.setInsertionPointAfter(buffer);
    auto unpackedResult = rewriter.create<hls::ITensorReassociateOp>(
        loc, resultType, buffer.getResult(), /*expandShape=*/false,
        resultShapeReasAttr, /*expandIteration=*/false, resultIterReasAttr);
    rewriter.replaceAllUsesExcept(buffer, unpackedResult, unpackedResult);
    return success();
  }
};
} // namespace

namespace {
struct LowerPackOp : public OpRewritePattern<tensor::PackOp> {
  using OpRewritePattern<tensor::PackOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tensor::PackOp pack,
                                PatternRewriter &rewriter) const override {
    auto lowerResult = linalg::lowerPack(rewriter, pack);
    if (failed(lowerResult))
      return failure();

    if (auto transpose = lowerResult->transposeOp)
      if (auto empty = transpose.getInit().getDefiningOp<tensor::EmptyOp>()) {
        rewriter.setInsertionPoint(empty);
        rewriter.replaceOpWithNewOp<hls::TensorInitOp>(empty, empty.getType());
      }
    return success();
  }
};
} // namespace

namespace {
struct LowerUnPackOp : public OpRewritePattern<tensor::UnPackOp> {
  using OpRewritePattern<tensor::UnPackOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tensor::UnPackOp unpack,
                                PatternRewriter &rewriter) const override {
    auto lowerResult = linalg::lowerUnPack(rewriter, unpack);
    if (failed(lowerResult))
      return failure();

    if (auto transpose = lowerResult->transposeOp)
      if (auto empty = transpose.getInit().getDefiningOp<tensor::EmptyOp>()) {
        rewriter.setInsertionPoint(empty);
        rewriter.replaceOpWithNewOp<hls::TensorInitOp>(empty, empty.getType());
      }
    return success();
  }
};
} // namespace

namespace {
struct PackITensorDMA : public hls::impl::PackITensorDMABase<PackITensorDMA> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<PackITensorWriteFullTensorOp>(context);
    patterns.add<PackITensorReadFullTensorOp>(context);
    // patterns.add<PackITensorBufferOp>(context);
    tensor::populateFoldIntoPackAndUnpackPatterns(patterns);
    tensor::populateSimplifyPackAndUnpackPatterns(patterns);
    tensor::PackOp::getCanonicalizationPatterns(patterns, context);
    tensor::UnPackOp::getCanonicalizationPatterns(patterns, context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));

    patterns.clear();
    patterns.add<LowerPackOp>(context);
    patterns.add<LowerUnPackOp>(context);
    patterns.add<linalg::LinalgGeneralizationPattern>(context);
    tensor::ExpandShapeOp::getCanonicalizationPatterns(patterns, context);
    tensor::CollapseShapeOp::getCanonicalizationPatterns(patterns, context);
    linalg::populateConstantFoldLinalgOperations(
        patterns, [&](OpOperand *fusedOperand) { return true; });
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
