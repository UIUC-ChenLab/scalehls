//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/LoopAnalysis.h"
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

    for (auto band : bands)
      applyPartialAffineLoopTiling(band, builder, tileSize);
  }
};
} // namespace

bool scalehls::applyPartialAffineLoopTiling(AffineLoopBand band,
                                            OpBuilder &builder,
                                            unsigned tileSize,
                                            bool applyPipelining) {
  if (!isPerfectlyNested(band))
    return false;

  // Calculate the tiling size of each loop in the band.
  SmallVector<unsigned, 8> sizes;
  auto remainTileSize = tileSize;

  for (auto loop : band) {
    if (auto tripCount = getConstantTripCount(loop)) {
      auto constTripCount = tripCount.getValue();

      if (remainTileSize >= constTripCount) {
        sizes.push_back(constTripCount);
        remainTileSize = (remainTileSize + constTripCount - 1) / constTripCount;
      } else if (remainTileSize > 1) {
        unsigned realTileSize = 1;
        while (realTileSize < remainTileSize ||
               constTripCount % realTileSize != 0) {
          realTileSize++;
        }
        sizes.push_back(realTileSize);
        remainTileSize = 1;
      } else
        sizes.push_back(1);
    } else
      return false;
  }

  AffineLoopBand tiledBand;
  if (failed(tilePerfectlyNested(band, sizes, &tiledBand)))
    return false;

  // Pipelining the tiled loop band if required.
  if (applyPipelining) {
    auto targetLoop = tiledBand[band.size() - 1];
    return applyLoopPipelining(targetLoop, builder);
  }

  return true;
}

std::unique_ptr<Pass> scalehls::createPartialAffineLoopTilePass() {
  return std::make_unique<PartialAffineLoopTile>();
}
