//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Utils.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct AffineLoopUnrollAndPipeline
    : public AffineLoopUnrollAndPipelineBase<AffineLoopUnrollAndPipeline> {
  AffineLoopUnrollAndPipeline() = default;
  AffineLoopUnrollAndPipeline(unsigned loopUnrollSize) {
    unrollSize = loopUnrollSize;
  }

  void runOnOperation() override {
    AffineLoopBands targetBands;
    getTileableBands(getOperation(), &targetBands);

    for (auto &band : targetBands) {
      TileList sizes;
      unsigned remainTileSize = unrollSize;

      // Calculate the tiling size of each loop level.
      for (auto loop : band) {
        if (auto optionalTripCount = getConstantTripCount(loop)) {
          auto tripCount = optionalTripCount.getValue();
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

      // Apply loop tiling.
      applyLoopTiling(band, sizes);

      // Apply loop order optimization if required.
      if (loopOrderOpt.getValue())
        applyAffineLoopOrderOpt(band);

      // Apply loop pipelining. All point loops will be fully unrolled.
      applyLoopPipelining(band, band.size() - 1, (unsigned)1);
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createAffineLoopUnrollAndPipelinePass() {
  return std::make_unique<AffineLoopUnrollAndPipeline>();
}
std::unique_ptr<Pass>
scalehls::createAffineLoopUnrollAndPipelinePass(unsigned loopUnrollSize) {
  return std::make_unique<AffineLoopUnrollAndPipeline>(loopUnrollSize);
}
