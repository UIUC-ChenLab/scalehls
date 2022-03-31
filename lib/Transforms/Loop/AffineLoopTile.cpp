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
#include "mlir/Dialect/Affine/Utils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

/// Apply loop tiling to the input loop band and sink all intra-tile loops to
/// the innermost loop with the original loop order.
bool scalehls::applyLoopTiling(AffineLoopBand &band, TileList tileList,
                               bool loopNormalize, bool annotatePointLoop) {
  assert(!band.empty() && "no loops provided");
  if (!isPerfectlyNested(band))
    return false;

  // Record the original band size and attributes to make use of later.
  auto originalBandSize = band.size();
  SmallVector<std::pair<bool, bool>, 6> flags;
  for (auto loop : band)
    flags.push_back({hasParallelAttr(loop), hasPointAttr(loop)});

  // Apply loop tiling.
  AffineLoopBand tiledBand;
  if (failed(tilePerfectlyNested(band, tileList, &tiledBand)))
    return false;

  // Get the tile loop band and point loop band.
  AffineLoopBand pointBand(std::next(tiledBand.begin(), originalBandSize),
                           tiledBand.end());
  tiledBand.resize(originalBandSize);

  // Annotate the required attributes.
  for (auto zip : llvm::zip(tiledBand, pointBand, flags)) {
    auto tileLoop = std::get<0>(zip);
    auto pointLoop = std::get<1>(zip);
    auto flag = std::get<2>(zip);

    // If a tile loop is parallel, the corresponding point loop should also be
    // a parallel loop.
    if (flag.first) {
      setParallelAttr(tileLoop);
      setParallelAttr(pointLoop);
    }

    // Re-annotate the point attribute to the tile loop if required.
    if (flag.second)
      setPointAttr(tileLoop);

    // Annotate the point attribute to the point loop.
    if (annotatePointLoop)
      setPointAttr(pointLoop);
  }

  // Collect the normalized tile band.
  if (loopNormalize) {
    band.clear();
    for (auto loop : tiledBand) {
      (void)normalizeAffineFor(loop);
      auto tripCount = getConstantTripCount(loop);
      if (!tripCount || tripCount.getValue() != 1)
        band.push_back(loop);
    }
  } else
    band = tiledBand;
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
struct AffineLoopTile : public AffineLoopTileBase<AffineLoopTile> {
  AffineLoopTile() = default;
  explicit AffineLoopTile(unsigned loopTileSize) { tileSize = loopTileSize; }

  void runOnOperation() override {
    // Bands of loops to tile.
    std::vector<SmallVector<AffineForOp, 6>> bands;
    getTileableBands(getOperation(), &bands);

    // Tile each band.
    for (auto &band : bands) {
      SmallVector<unsigned, 8> tileSizes(band.size(), tileSize);
      if (avoidMaxMinBounds)
        adjustToDivisorsOfTripCounts(band, &tileSizes);

      applyLoopTiling(band, tileSizes, /*loopNormalize=*/false);
    }
  }

  // If true, tile sizes are set to avoid max/min in bounds if possible.
  bool avoidMaxMinBounds = true;
};
} // namespace

/// Creates a pass to perform loop tiling on all suitable loop nests of a
/// Function.
std::unique_ptr<Pass>
scalehls::createAffineLoopTilePass(unsigned loopTileSize) {
  return std::make_unique<AffineLoopTile>(loopTileSize);
}
