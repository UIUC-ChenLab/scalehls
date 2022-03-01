//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Utils.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

static IntegerSet simplify(IntegerSet set) { return simplifyIntegerSet(set); }

/// Performs basic affine map simplifications.
static AffineMap simplify(AffineMap map) {
  MutableAffineMap mMap(map);
  mMap.simplify();
  return mMap.getAffineMap();
}

/// Utility to simplify an affine attribute and update its entry in the parent
/// operation if necessary.
template <typename AttrT>
static void
simplifyAndUpdateAttr(Operation *op, StringAttr name, AttrT attr,
                      DenseMap<Attribute, Attribute> &simplifiedAttrs) {
  auto &simplified = simplifiedAttrs[attr];
  if (simplified == attr)
    return;

  // This is a newly encountered attribute.
  if (!simplified) {
    // Try to simplify the value of the attribute.
    auto value = attr.getValue();
    auto simplifiedValue = simplify(value);
    if (simplifiedValue == value) {
      simplified = attr;
      return;
    }
    simplified = AttrT::get(simplifiedValue);
  }

  // Simplification was successful, so update the attribute.
  op->setAttr(name, simplified);
}

static void simplifyAffineStructures(Block &block) {
  auto context = block.front().getContext();
  DenseMap<Attribute, Attribute> simplifiedAttrs;

  RewritePatternSet patterns(context);
  AffineApplyOp::getCanonicalizationPatterns(patterns, context);
  AffineForOp::getCanonicalizationPatterns(patterns, context);
  AffineIfOp::getCanonicalizationPatterns(patterns, context);
  FrozenRewritePatternSet frozenPatterns(std::move(patterns));

  // The simplification of affine attributes will likely simplify the op. Try to
  // fold/apply canonicalization patterns when we have affine dialect ops.
  SmallVector<Operation *> opsToSimplify;
  block.walk([&](Operation *op) {
    for (auto attr : op->getAttrs()) {
      if (auto mapAttr = attr.getValue().dyn_cast<AffineMapAttr>())
        simplifyAndUpdateAttr(op, attr.getName(), mapAttr, simplifiedAttrs);
      else if (auto setAttr = attr.getValue().dyn_cast<IntegerSetAttr>())
        simplifyAndUpdateAttr(op, attr.getName(), setAttr, simplifiedAttrs);
    }

    if (isa<AffineForOp, AffineIfOp, AffineApplyOp>(op))
      opsToSimplify.push_back(op);
  });
  applyOpPatternsAndFold(opsToSimplify, frozenPatterns, /*strict=*/true);
}

/// Apply loop tiling to the input loop band and sink all intra-tile loops to
/// the innermost loop with the original loop order. Return the location of the
/// innermost tile-space loop.
Optional<unsigned> scalehls::applyLoopTiling(AffineLoopBand &band,
                                             TileList tileList, bool simplify) {
  assert(!band.empty() && "no loops provided");

  if (!isPerfectlyNested(band))
    return Optional<unsigned>();

  // Loop tiling.
  auto originalBandSize = band.size();
  AffineLoopBand tiledBand;
  if (failed(tilePerfectlyNested(band, tileList, &tiledBand)))
    return Optional<unsigned>();

  // Simplify the tiled loop band if required.
  if (simplify) {
    band.clear();
    unsigned simplifiedBandSize = 0;
    for (unsigned i = 0, e = tiledBand.size(); i < e; ++i) {
      auto loop = tiledBand[i];

      Optional<uint64_t> tripCount = getConstantTripCount(loop);
      if (i < originalBandSize - 1 || simplifiedBandSize > 0 || !tripCount ||
          tripCount.getValue() != 1)
        (void)normalizeAffineFor(loop);

      if (loop && !loop.getLoopBody().empty()) {
        band.push_back(loop);
        if (i < originalBandSize)
          ++simplifiedBandSize;
      }
    }
    simplifyAffineStructures(*band.front().getBody());
    return simplifiedBandSize - 1;
  }

  // Otherwise, directly return the tiled loop band.
  band = tiledBand;
  return originalBandSize - 1;
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

      // Apply loop tiling and extract the tile loops if applicable.
      if (auto tileLoc = applyLoopTiling(band, sizes))
        band.resize(tileLoc.getValue() + 1);

      // Apply loop order optimization and pipelining.
      if (loopOrderOpt)
        applyAffineLoopOrderOpt(band);
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
