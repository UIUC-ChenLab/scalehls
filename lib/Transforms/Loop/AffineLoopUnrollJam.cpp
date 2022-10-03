//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// Fully unroll all loops insides of a block.
bool scalehls::applyFullyLoopUnrolling(Block &block, unsigned maxIterNum) {
  for (unsigned i = 0; i < maxIterNum; ++i) {
    bool hasFullyUnrolled = true;
    block.walk([&](AffineForOp loop) {
      if (failed(loopUnrollFull(loop)))
        hasFullyUnrolled = false;
    });

    if (hasFullyUnrolled)
      break;

    if (i == 7)
      return false;
  }
  return true;
}

/// Apply loop unroll and jam to the loop band with the given unroll factor.
bool scalehls::applyLoopUnrollJam(AffineLoopBand &band, unsigned unrollFactor,
                                  bool loopOrderOpt) {
  if (unrollFactor == 1)
    return true;
  TileList sizes;
  unsigned remainTileSize = unrollFactor;

  // Calculate the tiling size of each loop level.
  for (auto it = band.rbegin(), e = band.rend(); it != e; ++it) {
    if (auto optionalTripCount = getConstantTripCount(*it)) {
      auto tripCount = optionalTripCount.value();
      auto size = tripCount;

      if (remainTileSize >= tripCount)
        remainTileSize = (remainTileSize + tripCount - 1) / tripCount;
      else if (remainTileSize > 1) {
        size = 1;
        while (size < remainTileSize || tripCount % size != 0)
          ++size;
        remainTileSize = 1;
      } else
        size = 1;

      sizes.push_back(size);
    } else
      sizes.push_back(1);
  }
  std::reverse(sizes.begin(), sizes.end());

  // Apply loop tiling and then unroll all point loops
  applyLoopTiling(band, sizes, /*loopNormalize=*/false);
  if (loopOrderOpt)
    applyAffineLoopOrderOpt(band);
  return applyFullyLoopUnrolling(*band.back().getBody());
}

namespace {
struct AffineLoopUnrollJam
    : public AffineLoopUnrollJamBase<AffineLoopUnrollJam> {
  AffineLoopUnrollJam() = default;
  AffineLoopUnrollJam(unsigned loopUnrollFactor, bool unrollPointLoopOnly) {
    unrollFactor = loopUnrollFactor;
    pointLoopOnly = unrollPointLoopOnly;
  }

  void runOnOperation() override {
    AffineLoopBands targetBands;
    getLoopBands(getOperation().front(), targetBands);
    // getTileableBands(getOperation(), &targetBands);

    for (auto &band : targetBands) {
      if (pointLoopOnly) {
        AffineLoopBand tileBand;
        AffineLoopBand pointBand;
        if (!getTileAndPointLoopBand(band, tileBand, pointBand) ||
            pointBand.empty())
          continue;
        band = pointBand;
      }
      applyLoopUnrollJam(band, unrollFactor.getValue(),
                         loopOrderOpt.getValue());
    }
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createAffineLoopUnrollJamPass(unsigned loopUnrollFactor,
                                        bool unrollPointLoopOnly) {
  return std::make_unique<AffineLoopUnrollJam>(loopUnrollFactor,
                                               unrollPointLoopOnly);
}
