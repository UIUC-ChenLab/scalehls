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

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_CONVERTEMPTYTOINSTANCE
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
struct ConvertTensorEmptyOp : public OpRewritePattern<tensor::EmptyOp> {
  using OpRewritePattern<tensor::EmptyOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tensor::EmptyOp empty,
                                PatternRewriter &rewriter) const override {
    for (auto &use : llvm::make_early_inc_range(empty->getUses())) {
      rewriter.setInsertionPoint(use.getOwner());
      auto instance = rewriter.create<hls::TensorInstanceOp>(empty.getLoc(),
                                                             empty.getType());
      rewriter.modifyOpInPlace(use.getOwner(), [&]() { use.set(instance); });
    }
    rewriter.eraseOp(empty);
    return success();
  }
};
} // namespace

namespace {
struct ConvertITensorEmptyOp : public OpRewritePattern<hls::ITensorEmptyOp> {
  using OpRewritePattern<hls::ITensorEmptyOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorEmptyOp init,
                                PatternRewriter &rewriter) const override {
    for (auto &use : llvm::make_early_inc_range(init->getUses())) {
      rewriter.setInsertionPoint(use.getOwner());
      auto instance = rewriter.create<hls::ITensorInstanceOp>(init.getLoc(),
                                                              init.getType());
      rewriter.modifyOpInPlace(use.getOwner(), [&]() { use.set(instance); });
    }
    rewriter.eraseOp(init);
    return success();
  }
};
} // namespace

namespace {
struct ConvertEmptyToInstance
    : public hls::impl::ConvertEmptyToInstanceBase<ConvertEmptyToInstance> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    tensor::populateFoldTensorEmptyPatterns(patterns);
    tensor::populateFoldTensorSubsetOpPatterns(patterns);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));

    patterns.clear();
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertITensorEmptyOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
