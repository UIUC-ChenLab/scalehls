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

    auto packed = packTensor(writeFullTensor.getFullTensor(),
                             iTensorType.getElementShape(),
                             writeFullTensor.getLoc(), rewriter);
    rewriter.updateRootInPlace(writeFullTensor, [&]() {
      writeFullTensor.getFullTensorMutable().assign(packed);
      writeFullTensor.setPacked(true);
    });
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

    auto packedType = getPackedType(readFullTensor.getFullTensorType(),
                                    iTensorType.getElementShape());
    Value newFullTensorInit;
    if (readFullTensor.getFullTensorInit().getDefiningOp<hls::TensorInitOp>())
      newFullTensorInit = rewriter.create<hls::TensorInitOp>(
          readFullTensor.getLoc(), packedType);
    else
      newFullTensorInit = packTensor(readFullTensor.getFullTensorInit(),
                                     iTensorType.getElementShape(),
                                     readFullTensor.getLoc(), rewriter);

    rewriter.updateRootInPlace(readFullTensor, [&]() {
      readFullTensor.getFullTensorInitMutable().assign(newFullTensorInit);
      readFullTensor.getFullTensor().setType(packedType);
      readFullTensor.setPacked(true);
    });

    rewriter.setInsertionPointAfter(readFullTensor);
    auto unpack = unpackTensor(readFullTensor.getFullTensor(),
                               iTensorType.getElementShape(),
                               readFullTensor.getLoc(), rewriter);
    rewriter.replaceAllUsesExcept(readFullTensor, unpack, unpack);
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

    auto packedType =
        getPackedType(buffer.getBufferType(), buffer.getPackSizes());
    rewriter.updateRootInPlace(buffer, [&]() {
      buffer.setBufferType(packedType);
      buffer.setPacked(true);
    });
    return success();
  }
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
struct PackITensorDMA : public hls::impl::PackITensorDMABase<PackITensorDMA> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<PackITensorWriteFullTensorOp>(context);
    patterns.add<PackITensorReadFullTensorOp>(context);
    patterns.add<PackITensorBufferOp>(context);
    patterns.add<LowerPackOp>(context);
    patterns.add<linalg::LinalgGeneralizationPattern>(context);
    linalg::populateConstantFoldLinalgOperations(
        patterns, [&](OpOperand *fusedOperand) { return true; });
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
