//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct LowerCopyToAffineLoopsPattern : public OpRewritePattern<memref::CopyOp> {
  using OpRewritePattern<memref::CopyOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::CopyOp copy,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPoint(copy);
    auto loc = copy.getLoc();
    auto memrefType = copy.getSource().getType().cast<MemRefType>();

    // Create explicit memory copy using an affine loop nest.
    SmallVector<Value, 4> ivs;
    auto constantZero = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    for (auto dimSize : memrefType.getShape()) {
      if (dimSize == 1) {
        ivs.push_back(constantZero);
        continue;
      }
      auto loop = rewriter.create<affine::AffineForOp>(loc, 0, dimSize);
      rewriter.setInsertionPointToStart(loop.getBody());
      ivs.push_back(loop.getInductionVar());
    }

    // Create affine load/store operations.
    auto value =
        rewriter.create<affine::AffineLoadOp>(loc, copy.getSource(), ivs);
    rewriter.create<affine::AffineStoreOp>(loc, value, copy.getTarget(), ivs);

    rewriter.eraseOp(copy);
    return success();
  }
};
} // namespace

namespace {
struct LowerCopyToAffineLoops
    : public LowerCopyToAffineLoopsBase<LowerCopyToAffineLoops> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    // Lower copy operation.
    mlir::RewritePatternSet patterns(context);
    patterns.add<LowerCopyToAffineLoopsPattern>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createLowerCopyToAffineLoopsPass() {
  return std::make_unique<LowerCopyToAffineLoops>();
}