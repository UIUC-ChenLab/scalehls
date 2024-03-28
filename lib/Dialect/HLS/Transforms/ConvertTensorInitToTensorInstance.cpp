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
    patterns.add<ConvertTensorInitOp>(context);
    patterns.add<ConvertITensorInitOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
