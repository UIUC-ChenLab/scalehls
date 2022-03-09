//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// Apply loop tiling to the input loop band and sink all intra-tile loops to
/// the innermost loop with the original loop order.
bool scalehls::applyLoopTiling(AffineLoopBand &band, TileList tileList) {
  assert(!band.empty() && "no loops provided");
  if (!isPerfectlyNested(band))
    return false;

  // Record the original band size and attributes to make use of later.
  auto originalBandSize = band.size();
  SmallVector<bool, 6> parallelFlags;
  for (auto loop : band)
    parallelFlags.push_back(hasParallelAttr(loop));

  // Apply loop tiling.
  AffineLoopBand tiledBand;
  if (failed(tilePerfectlyNested(band, tileList, &tiledBand)))
    return false;

  // Get all tile-space loops and reannotate the attributes.
  band = tiledBand;
  band.resize(originalBandSize);
  for (auto zip : llvm::zip(band, parallelFlags))
    if (std::get<1>(zip))
      setParallelAttr(std::get<0>(zip));

  return true;
}

/// Reduces each tile size to the largest divisor of the corresponding trip
/// count (if the trip count is known).
static void adjustToDivisorsOfTripCounts(ArrayRef<AffineForOp> band,
                                         SmallVectorImpl<unsigned> *tileSizes) {
  assert(band.size() == tileSizes->size() && "invalid tile size count");
  for (unsigned i = 0, e = band.size(); i < e; i++) {
    unsigned &tSizeAdjusted = (*tileSizes)[i];
    Optional<uint64_t> mayConst = getConstantTripCount(band[i]);
    if (!mayConst)
      continue;

    // Adjust the tile size to largest factor of the trip count less than
    // tSize.
    uint64_t constTripCount = mayConst.getValue();
    if (constTripCount > 1 && tSizeAdjusted > constTripCount / 2)
      tSizeAdjusted = constTripCount / 2;
    while (constTripCount % tSizeAdjusted != 0)
      tSizeAdjusted--;
  }
}

namespace {
/// A pass to perform loop tiling on all suitable loop nests of a Function.
struct AffineLoopTileAndAnnotate
    : public AffineLoopTileAndAnnotateBase<AffineLoopTileAndAnnotate> {
  AffineLoopTileAndAnnotate() = default;
  explicit AffineLoopTileAndAnnotate(unsigned loopTileSize) {
    tileSize = loopTileSize;
  }

  void runOnOperation() override {
    // Bands of loops to tile.
    std::vector<SmallVector<AffineForOp, 6>> bands;
    getTileableBands(getOperation(), &bands);

    // Tile each band.
    for (auto &band : bands) {
      // Set up tile sizes; fill missing tile sizes at the end with default tile
      // size or tileSize if one was provided.
      SmallVector<unsigned, 6> tileSizes(band.size(), tileSize);
      if (avoidMaxMinBounds)
        adjustToDivisorsOfTripCounts(band, &tileSizes);

      SmallVector<AffineForOp, 6> tiledNest;
      if (failed(tilePerfectlyNested(band, tileSizes, &tiledNest))) {
        // An empty band always succeeds.
        assert(!band.empty() && "guaranteed to succeed on empty bands");
        continue;
      }

      // Annotate point loops.
      for (auto loop : llvm::drop_begin(tiledNest, band.size()))
        setPointAttr(loop);
    }
  }

  // If true, tile sizes are set to avoid max/min in bounds if possible.
  bool avoidMaxMinBounds = true;
};
} // namespace

/// Creates a pass to perform loop tiling on all suitable loop nests of a
/// Function.
std::unique_ptr<Pass> scalehls::createAffineLoopTileAndAnnotatePass() {
  return std::make_unique<AffineLoopTileAndAnnotate>();
}
std::unique_ptr<Pass>
scalehls::createAffineLoopTileAndAnnotatePass(unsigned loopTileSize) {
  return std::make_unique<AffineLoopTileAndAnnotate>(loopTileSize);
}
