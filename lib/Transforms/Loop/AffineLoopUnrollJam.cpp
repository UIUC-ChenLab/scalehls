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

/// Apply unroll and jam to the loop band with the given overall unroll factor.
bool scalehls::applyLoopUnrollJam(AffineLoopBand &band,
                                  unsigned overallUnrollFactor,
                                  bool loopOrderOpt) {
  assert(!band.empty() && "no loops provided");
  if (overallUnrollFactor == 1)
    return true;

  // Calculate the tiling size of each loop level.
  auto sizes = getDistributedFactors(overallUnrollFactor, band);
  return applyLoopUnrollJam(band, sizes, loopOrderOpt);
}

/// Apply unroll and jam to the loop band with the given unroll factors.
bool scalehls::applyLoopUnrollJam(AffineLoopBand &band,
                                  FactorList unrollFactors, bool loopOrderOpt) {
  assert(!band.empty() && "no loops provided");
  if (llvm::all_of(unrollFactors, [](unsigned factor) { return factor == 1; }))
    return true;

  // FIXME: Unknown issue causing failure in order opt.
  if (loopOrderOpt)
    applyAffineLoopOrderOpt(band);

  // Apply loop tiling and then unroll all point loops.
  applyLoopTiling(band, unrollFactors, /*loopNormalize=*/false);
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
      // For loop band that has effect on external buffers, we should directly
      // unroll them without considering whether it's point loop.
      if (hasEffectOnExternalBuffer(band.front())) {
        applyLoopUnrollJam(band, unrollFactor.getValue());
        continue;
      }

      if (pointLoopOnly) {
        AffineLoopBand tileBand;
        AffineLoopBand pointBand;
        if (!getTileAndPointLoopBand(band, tileBand, pointBand) ||
            pointBand.empty())
          continue;
        band = pointBand;
      }
      applyLoopUnrollJam(band, unrollFactor.getValue());
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
