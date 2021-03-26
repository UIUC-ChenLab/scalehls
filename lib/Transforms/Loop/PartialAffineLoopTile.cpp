//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Transforms/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// Apply loop tiling to the input loop band and sink all intra-tile loops to
/// the innermost loop with the original loop order. Return the location of the
/// innermost tile-space loop.
Optional<unsigned> scalehls::applyLoopTiling(AffineLoopBand &band,
                                             TileList tileList) {
  if (!isPerfectlyNested(band))
    return Optional<unsigned>();

  // Loop tiling.
  AffineLoopBand tiledBand;
  if (failed(tilePerfectlyNested(band, tileList, &tiledBand)))
    return Optional<unsigned>();

  // Record the band size and clear the original loop band.
  auto originalBandSize = band.size();
  band.clear();

  // Remove redundant loops in the tiled loop band.
  auto builder = OpBuilder(tiledBand.back());
  unsigned erasedLoopNum = 0;
  unsigned loc = 0;

  for (auto loop : tiledBand) {
    if (erasedLoopNum >= originalBandSize - 1 || loc >= originalBandSize ||
        getConstantTripCount(loop).getValue() > 1) {
      // All tile-space loops which have a trip count larger than 1 and all
      // intra-tile loops are pushed back. Meanwhile, we are not willing to see
      // all tile-space loops removed since in that case many analysis and
      // transforms will become very hard. Thereby we record the number of
      // erased loop so far and always keep at least one tile-space loop
      // remained in the loop band even if it has a trip count of 1.
      band.push_back(loop);
    } else {
      // Create an affine apply operation to represent the lower bound.
      builder.setInsertionPoint(loop);
      auto newIterVar = builder.create<AffineApplyOp>(
          loop.getLoc(), loop.getLowerBoundMap(), loop.getLowerBoundOperands());
      loop.getInductionVar().replaceAllUsesWith(newIterVar);

      // Move all operation except the terminator to the outside.
      auto &parentBlock = loop->getBlock()->getOperations();
      auto &loopBlock = loop.getBody()->getOperations();
      parentBlock.splice(loop->getIterator(), loopBlock, loopBlock.begin(),
                         std::prev(loopBlock.end()));
      loop.erase();
      ++erasedLoopNum;
    }
    ++loc;
  }

  return band.size() - originalBandSize - 1;
}

namespace {
struct PartialAffineLoopTile
    : public PartialAffineLoopTileBase<PartialAffineLoopTile> {
  void runOnOperation() override {
    AffineLoopBands targetBands;
    getTileableBands(getOperation(), &targetBands);

    for (auto &band : targetBands) {
      TileList sizes;
      unsigned remainTileSize = tileSize;

      // Calculate the tiling size of each loop level.
      for (auto loop : band) {
        if (auto optionalTripCount = getConstantTripCount(loop)) {
          auto tripCount = optionalTripCount.getValue();
          auto size = tripCount;

          if (remainTileSize >= tripCount)
            remainTileSize = (remainTileSize + tripCount - 1) / tripCount;
          else if (remainTileSize > 1) {
            size = 1;
            while (size < remainTileSize || tripCount % size != 0) {
              ++size;
            }
            remainTileSize = 1;
          } else
            size = 1;

          sizes.push_back(size);
        } else
          sizes.push_back(1);
      }

      auto tileLoc = applyLoopTiling(band, sizes).getValue();
      band.resize(tileLoc + 1);

      if (applyOrderOpt)
        applyAffineLoopOrderOpt(band);

      if (applyPipeline)
        applyLoopPipelining(band, tileLoc, (unsigned)1);
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createPartialAffineLoopTilePass() {
  return std::make_unique<PartialAffineLoopTile>();
}
