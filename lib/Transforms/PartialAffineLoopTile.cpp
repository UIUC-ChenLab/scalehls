//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Transforms/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct PartialAffineLoopTile
    : public PartialAffineLoopTileBase<PartialAffineLoopTile> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    std::vector<SmallVector<AffineForOp, 6>> bands;
    getTileableBands(func, &bands);

    for (auto band : bands) {
      AffineLoopBand tiledBand;
      applyPartialAffineLoopTiling(band, tiledBand, builder, tileSize);
    }

    // Canonicalize the IR after loop tiling.
    OwningRewritePatternList patterns;
    for (auto *op : func.getContext()->getRegisteredOperations())
      op->getCanonicalizationPatterns(patterns, func.getContext());

    applyPatternsAndFoldGreedily(func.getRegion(), std::move(patterns));
  }
};
} // namespace

bool scalehls::applyPartialAffineLoopTiling(AffineLoopBand band,
                                            AffineLoopBand &tiledBand,
                                            OpBuilder &builder,
                                            unsigned tileSize) {
  if (!isPerfectlyNested(band))
    return false;

  // Calculate the tiling size of each loop in the band.
  SmallVector<unsigned, 8> fullyTiledLoops;
  SmallVector<unsigned, 8> sizes;
  auto remainTileSize = tileSize;

  unsigned loc = 0;
  for (auto loop : band) {
    if (auto optionalTripCount = getConstantTripCount(loop)) {
      auto tripCount = optionalTripCount.getValue();
      auto tileSize = tripCount;

      if (remainTileSize >= tripCount)
        remainTileSize = (remainTileSize + tripCount - 1) / tripCount;
      else if (remainTileSize > 1) {
        tileSize = 1;
        while (tileSize < remainTileSize || tripCount % tileSize != 0) {
          tileSize++;
        }
        remainTileSize = 1;
      } else
        tileSize = 1;

      sizes.push_back(tileSize);
      if (tileSize == tripCount)
        fullyTiledLoops.push_back(loc);
    } else
      return false;

    loc++;
  }

  if (failed(tilePerfectlyNested(band, sizes, &tiledBand)))
    return false;

  // Remove fully tiled loops.
  for (auto loc : fullyTiledLoops) {
    // Will always keep one loop, even if it is already fully tiled.
    if (loc == band.size() - 1)
      break;

    auto loop = tiledBand[loc];

    // Create an affine apply operation generating a constant zero.
    builder.setInsertionPoint(loop);
    auto constZero = builder.create<AffineApplyOp>(
        loop.getLoc(), builder.getConstantAffineMap(0), ValueRange({}));
    loop.getInductionVar().replaceAllUsesWith(constZero);

    // Move all operation except the terminator to the outside.
    auto &parentBlock = loop.getOperation()->getBlock()->getOperations();
    auto &loopBlock = loop.getLoopBody().front().getOperations();
    parentBlock.splice(loop.getOperation()->getIterator(), loopBlock,
                       loopBlock.begin(), std::prev(loopBlock.end()));
    loop.erase();
  }

  return true;
}

std::unique_ptr<Pass> scalehls::createPartialAffineLoopTilePass() {
  return std::make_unique<PartialAffineLoopTile>();
}
