//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Transforms/LoopUtils.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct PartialAffineLoopTile
    : public PartialAffineLoopTileBase<PartialAffineLoopTile> {
  void runOnOperation() override;
};
} // namespace

void PartialAffineLoopTile::runOnOperation() {
  // Walk through all functions and loops.
  auto func = getOperation();

  // Bands of loops to tile.
  std::vector<SmallVector<mlir::AffineForOp, 6>> bands;
  getTileableBands(func, &bands);

  // Tile each band.
  for (auto &band : bands) {
    // Truncate band and only keep first tileLevel loops.
    size_t realTileLevel = band.size();
    if (realTileLevel > tileLevel) {
      band.resize(tileLevel);
      realTileLevel = tileLevel;
    }

    // Set up tile sizes; fill missing tile sizes at the end with default tile
    // size or tileSize if one was provided.
    SmallVector<unsigned, 6> tileSizes;
    tileSizes.assign(band.size(), tileSize);

    SmallVector<mlir::AffineForOp, 6> tiledNest;
    if (failed(tilePerfectlyNested(band, tileSizes, &tiledNest)))
      return signalPassFailure();

    // Permute loop order to move the tiled loop to the innermost of the
    // perfect nested loop.
    SmallVector<mlir::AffineForOp, 4> nestedLoops;
    getPerfectlyNestedLoops(nestedLoops, tiledNest.front());

    SmallVector<unsigned, 4> permMap;
    for (size_t i = 0, e = nestedLoops.size(); i < e; ++i) {
      if (i < realTileLevel)
        permMap.push_back(i);
      else if (i < 2 * realTileLevel)
        permMap.push_back(e + i - 2 * realTileLevel);
      else
        permMap.push_back(i - realTileLevel);
    }
    if (isValidLoopInterchangePermutation(nestedLoops, permMap))
      permuteLoops(nestedLoops, permMap);
  }
}

std::unique_ptr<mlir::Pass> scalehls::createPartialAffineLoopTilePass() {
  return std::make_unique<PartialAffineLoopTile>();
}
