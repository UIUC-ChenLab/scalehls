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
#define GEN_PASS_DEF_CONVERTTENSORINITTOTENSORINSTANCE
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
template <typename ReshapeOp>
struct FoldTensorInitWithReshapeOp : public OpRewritePattern<ReshapeOp> {
  FoldTensorInitWithReshapeOp(MLIRContext *ctx, PatternBenefit benefit = 1,
                              bool foldSingleUseOnly = false)
      : OpRewritePattern<ReshapeOp>(ctx, benefit),
        foldSingleUseOnly(foldSingleUseOnly) {}

  LogicalResult matchAndRewrite(ReshapeOp reshapeOp,
                                PatternRewriter &rewriter) const override {
    // Check for tensor_init source.
    auto init = reshapeOp.getSrc().template getDefiningOp<hls::TensorInitOp>();
    if (!init)
      return failure();

    // Check for single use.
    if (foldSingleUseOnly && !llvm::hasSingleElement(init->getUses()))
      return failure();

    // Reify result shape.
    Location loc = reshapeOp.getLoc();
    ReifiedRankedShapedTypeDims resultShapes;
    if (failed(reifyResultShapes(rewriter, reshapeOp, resultShapes)) ||
        !llvm::hasSingleElement(resultShapes))
      return failure();

    // TODO: Support dynamic shapes.
    SmallVector<int64_t> staticResultShape;
    for (auto dim : resultShapes[0])
      if (auto staticDim = dim.get<Attribute>())
        staticResultShape.push_back(cast<IntegerAttr>(staticDim).getInt());
      else
        return failure();

    // Create new tensor_init op.
    auto newType = RankedTensorType::get(
        staticResultShape, reshapeOp.getResultType().getElementType(),
        reshapeOp.getResultType().getEncoding());
    Value newInit = rewriter.create<hls::TensorInitOp>(loc, newType,
                                                       init.getInitValueAttr());
    if (newInit.getType() != reshapeOp.getResultType()) {
      rewriter.replaceOpWithNewOp<tensor::CastOp>(
          reshapeOp, reshapeOp.getResultType(), newInit);
    } else {
      rewriter.replaceOp(reshapeOp, newInit);
    }
    return success();
  }

private:
  bool foldSingleUseOnly = false;
};
} // namespace

namespace {
/// tensor_init does not define any tensor contents, so a slice of a
/// tensor_init can be folded to a smaller tensor_init.
struct FoldTensorInitWithExtractSliceOp
    : public OpRewritePattern<tensor::ExtractSliceOp> {
  FoldTensorInitWithExtractSliceOp(MLIRContext *ctx, PatternBenefit benefit = 1,
                                   bool foldSingleUseOnly = false)
      : OpRewritePattern<tensor::ExtractSliceOp>(ctx, benefit),
        foldSingleUseOnly(foldSingleUseOnly) {}

  LogicalResult matchAndRewrite(tensor::ExtractSliceOp sliceOp,
                                PatternRewriter &rewriter) const override {
    // Check for tensor_init source.
    auto init = sliceOp.getSource().template getDefiningOp<hls::TensorInitOp>();
    if (!init)
      return failure();

    // Check for single use.
    if (foldSingleUseOnly && !llvm::hasSingleElement(init->getUses()))
      return failure();

    // Create new tensor_init op. tensor.extract_slice may be rank-reducing;
    // its dynamic sizes must be preserved as well as its result type.
    auto tensorType = RankedTensorType::get(sliceOp.getType().getShape(),
                                            sliceOp.getType().getElementType(),
                                            sliceOp.getType().getEncoding());
    rewriter.replaceOpWithNewOp<hls::TensorInitOp>(sliceOp, tensorType,
                                                   init.getInitValueAttr());
    return success();
  }

private:
  bool foldSingleUseOnly = false;
};
} // namespace

namespace {
struct ConvertTensorInitOp : public OpRewritePattern<hls::TensorInitOp> {
  using OpRewritePattern<hls::TensorInitOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TensorInitOp init,
                                PatternRewriter &rewriter) const override {
    for (auto &use : llvm::make_early_inc_range(init->getUses())) {
      rewriter.setInsertionPoint(use.getOwner());
      auto instance = rewriter.create<hls::TensorInstanceOp>(
          init.getLoc(), init.getType(), init.getInitValueAttr());
      rewriter.updateRootInPlace(use.getOwner(), [&]() { use.set(instance); });
    }
    rewriter.eraseOp(init);
    return success();
  }
};
} // namespace

namespace {
struct ConvertITensorInitOp : public OpRewritePattern<hls::ITensorInitOp> {
  using OpRewritePattern<hls::ITensorInitOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorInitOp init,
                                PatternRewriter &rewriter) const override {
    for (auto &use : llvm::make_early_inc_range(init->getUses())) {
      rewriter.setInsertionPoint(use.getOwner());
      auto instance = rewriter.create<hls::ITensorInstanceOp>(
          init.getLoc(), init.getType(), init.getInitValueAttr());
      rewriter.updateRootInPlace(use.getOwner(), [&]() { use.set(instance); });
    }
    rewriter.eraseOp(init);
    return success();
  }
};
} // namespace

namespace {
struct ConvertTensorInitToTensorInstance
    : public hls::impl::ConvertTensorInitToTensorInstanceBase<
          ConvertTensorInitToTensorInstance> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<FoldTensorInitWithReshapeOp<tensor::ExpandShapeOp>>(context);
    patterns.add<FoldTensorInitWithReshapeOp<tensor::CollapseShapeOp>>(context);
    patterns.add<FoldTensorInitWithExtractSliceOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));

    patterns.clear();
    patterns.add<ConvertTensorInitOp>(context);
    patterns.add<ConvertITensorInitOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
