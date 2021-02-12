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

/// Apply loop tiling to the input loop band and return the location of the
/// original innermost loop in the tiled loop band. If tile is failed, -1 will
/// be returned.
int64_t scalehls::applyLoopTiling(AffineLoopBand &band, TileList tileList) {
  if (!isPerfectlyNested(band))
    return -1;

  // Collect each loop location that is fully tiled and can be eliminated.
  SmallVector<unsigned, 8> fullyTiledLoops;
  unsigned pipelineLoc = 0;
  unsigned loc = 0;
  for (auto loop : band) {
    if (auto tripCount = getConstantTripCount(loop)) {
      if (tripCount.getValue() == tileList[loc])
        fullyTiledLoops.push_back(loc);
      else
        pipelineLoc = loc;
    } else
      return -1;
    ++loc;
  }

  // If all loops are fully tiled, keep the last loop untouched.
  if (fullyTiledLoops.size() == band.size()) {
    fullyTiledLoops.pop_back();
    pipelineLoc = band.size() - 1;
  }

  // Loop tiling.
  AffineLoopBand tiledBand;
  if (failed(tilePerfectlyNested(band, tileList, &tiledBand)))
    return -1;
  band = tiledBand;

  auto builder = OpBuilder(band.back());

  // Remove fully tiled loops.
  for (auto loc : fullyTiledLoops) {
    auto loop = band[loc];

    // Create an affine apply operation generating a constant zero.
    builder.setInsertionPoint(loop);
    auto constZero = builder.create<AffineApplyOp>(
        loop.getLoc(), builder.getConstantAffineMap(0), ValueRange({}));
    loop.getInductionVar().replaceAllUsesWith(constZero);

    // Move all operation except the terminator to the outside.
    auto &parentBlock = loop->getBlock()->getOperations();
    auto &loopBlock = loop.getBody()->getOperations();
    parentBlock.splice(loop->getIterator(), loopBlock, loopBlock.begin(),
                       std::prev(loopBlock.end()));
    loop.erase();
  }

  return pipelineLoc;
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

      applyLoopTiling(band, sizes);
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createPartialAffineLoopTilePass() {
  return std::make_unique<PartialAffineLoopTile>();
}
