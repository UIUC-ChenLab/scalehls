//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// Apply loop pipelining to the input loop, all inner loops are automatically
/// fully unrolled.
bool scalehls::applyLoopPipelining(AffineLoopBand &band, unsigned pipelineLoc,
                                   unsigned targetII) {
  auto targetLoop = band[pipelineLoc];

  // All inner loops of the pipelined loop are automatically unrolled.
  if (!applyFullyLoopUnrolling(*targetLoop.getBody()))
    return false;

  // Erase all loops in loop band that are inside of the pipelined loop.
  band.resize(pipelineLoc + 1);

  setLoopDirective(targetLoop, true, targetII, false, false);

  // All outer loops that perfect nest the pipelined loop can be flattened.
  auto currentLoop = targetLoop;
  while (true) {
    if (auto outerLoop = currentLoop->getParentOfType<AffineForOp>()) {
      // Only if the current loop is the only child loop of the outer loop, the
      // outer loop can be flattened into the current loop.
      bool canFlatten = true;
      for (auto &op : outerLoop)
        if (&op != currentLoop && !isa<AffineApplyOp, AffineYieldOp>(op)) {
          canFlatten = false;
          break;
        }

      if (canFlatten) {
        currentLoop = outerLoop;
        setLoopDirective(outerLoop, false, 1, false, true);
        continue;
      }
    }
    break;
  }

  return true;
}

namespace {
struct LoopPipelining : public LoopPipeliningBase<LoopPipelining> {
  void runOnOperation() override {
    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(getOperation().front(), targetBands);

    // Apply loop pipelining to corresponding level of each innermost loop.
    for (auto &band : targetBands) {
      auto currentLoop = band.back();
      unsigned loopLevel = 0;
      while (true) {
        auto parentLoop = currentLoop->getParentOfType<AffineForOp>();

        // If meet the outermost loop, pipeline the current loop.
        if (!parentLoop || pipelineLevel == loopLevel) {
          applyLoopPipelining(band, band.size() - loopLevel - 1, targetII);
          break;
        }

        // Move to the next loop level.
        currentLoop = parentLoop;
        ++loopLevel;
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLoopPipeliningPass() {
  return std::make_unique<LoopPipelining>();
}
