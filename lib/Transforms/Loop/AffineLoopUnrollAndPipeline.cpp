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

/// Apply loop tiling to the input loop band and sink all intra-tile loops to
/// the innermost loop with the original loop order. If "tileOrderOpt" is true,
/// the order of all tile-space loops are optimizaed after tiling. If
/// "unrollPointLoops" is true, all intra-tile loops (also called point loops)
/// are fully unrolled after tiling.
bool scalehls::applyLoopTiling(AffineLoopBand &band, TileList tileList,
                               bool tileOrderOpt, bool unrollPointLoops) {
  assert(!band.empty() && "no loops provided");

  if (!isPerfectlyNested(band))
    return false;

  // Record the original band size and attributes to make use of later.
  auto originalBandSize = band.size();
  SmallVector<bool, 6> parallelFlags;
  for (auto loop : band)
    parallelFlags.push_back(isParallel(loop));

  // Apply loop tiling.
  AffineLoopBand tiledBand;
  if (failed(tilePerfectlyNested(band, tileList, &tiledBand)))
    return false;

  // Get all tile-space loops and reannotate the attributes.
  band = tiledBand;
  band.resize(originalBandSize);
  for (auto zip : llvm::zip(band, parallelFlags))
    if (std::get<1>(zip))
      setParallel(std::get<0>(zip));

  // Apply loop order optimization and point loops unrolling if required.
  if (tileOrderOpt)
    applyAffineLoopOrderOpt(band);
  if (unrollPointLoops)
    applyFullyLoopUnrolling(*band.back().getBody());
  return true;
}

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

      // Apply loop unrolling and pipelining.
      applyLoopTiling(band, sizes, /*tileOrderOpt=*/loopOrderOpt.getValue(),
                      /*unrollPointLoops=*/true);
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
