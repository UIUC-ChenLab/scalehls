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

namespace {
struct DataflowAwareLoopUnrollJam
    : public DataflowAwareLoopUnrollJamBase<DataflowAwareLoopUnrollJam> {
  DataflowAwareLoopUnrollJam() = default;
  DataflowAwareLoopUnrollJam(unsigned loopUnrollFactor,
                             bool unrollPointLoopOnly) {
    maxUnrollFactor = loopUnrollFactor;
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

      TileList sizes;
      unsigned remainTileSize = maxUnrollFactor;

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
      if (loopOrderOpt.getValue())
        applyAffineLoopOrderOpt(band);
      applyFullyLoopUnrolling(*band.back().getBody());
    }
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createDataflowAwareLoopUnrollJamPass(unsigned loopUnrollFactor,
                                               bool unrollPointLoopOnly) {
  return std::make_unique<DataflowAwareLoopUnrollJam>(loopUnrollFactor,
                                                      unrollPointLoopOnly);
}
