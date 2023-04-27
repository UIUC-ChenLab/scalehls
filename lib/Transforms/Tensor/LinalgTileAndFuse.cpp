//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Dialect/Linalg/Utils/Utils.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct TileAndFuseConv : public OpRewritePattern<linalg::Conv2DNchwFchwOp> {
  using OpRewritePattern<linalg::Conv2DNchwFchwOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::Conv2DNchwFchwOp target,
                                PatternRewriter &rewriter) const override {
    SmallVector<Value, 4> tileSizes;
    SmallVector<int64_t, 4> tileSizesInt64;
    auto linalgOp = cast<linalg::LinalgOp>(target.getOperation());
    for (unsigned i = 0, e = linalgOp.getNumLoops(); i < e; ++i) {
      tileSizes.push_back(rewriter.create<hls::TileParameter>(
          rewriter.getUnknownLoc(), rewriter.getI64Type()));
      if (linalgOp.getIteratorTypesArray()[i] ==
              utils::IteratorType::parallel &&
          linalgOp.getStaticShape()[i] > 1)
        tileSizesInt64.push_back(2);
      else
        tileSizesInt64.push_back(0);
    }

    auto config = linalg::LinalgTilingOptions();
    config.setTileSizes(tileSizesInt64);
    auto tiledLinalgOp = linalg::tileLinalgOp(rewriter, linalgOp, config);
    if (succeeded(tiledLinalgOp)) {
      rewriter.replaceOp(target, tiledLinalgOp.value().tensorResults);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
/// This pass is only for testing use!!! To really support quantized model,
/// first we need to have front-ends, such as Torch-MLIR, to support the model
/// quantization, which has not came true unfortunately.
struct LinalgTileAndFuse : public LinalgTileAndFuseBase<LinalgTileAndFuse> {
  void runOnOperation() override {
    mlir::RewritePatternSet patterns(&getContext());
    patterns.add<TileAndFuseConv>(&getContext());
    auto config = GreedyRewriteConfig();
    config.maxIterations = 1;
    config.maxNumRewrites = 1;
    applyPatternsAndFoldGreedily(getOperation(), std::move(patterns), config);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLinalgTileAndFusePass() {
  return std::make_unique<LinalgTileAndFuse>();
}
