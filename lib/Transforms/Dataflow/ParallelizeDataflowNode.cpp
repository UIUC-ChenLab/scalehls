//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Utils.h"
#include "scalehls/Dialect/HLS/Analysis.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

// /// Apply loop vectorization to the loop band.
// static bool applyLoopVectorization(AffineLoopBand &band,
//                                    unsigned vectorizeFactor) {
//   assert(!band.empty() && "no loops provided");
//   if (vectorizeFactor == 1)
//     return true;

//   // We require all loops to be parallel loop.
//   for (auto loop : band)
//     if (!(hasParallelAttr(loop) || isLoopParallel(loop)))
//       return false;

//   // Calculate the vectorization size of each loop level.
//   auto loopSet = llvm::DenseSet<Operation *>(band.begin(), band.end());
//   auto sizes = getDistributedFactors(vectorizeFactor, band);

//   // Apply loop vectorization.
//   vectorizeAffineLoops(band.front()->getParentOp(), loopSet,
//                        SmallVector<int64_t>(sizes.begin(), sizes.end()), {});
//   return true;
// }

namespace {
struct ParallelizeDataflowNode
    : public ParallelizeDataflowNodeBase<ParallelizeDataflowNode> {
  ParallelizeDataflowNode() = default;
  ParallelizeDataflowNode(unsigned loopUnrollFactor, bool unrollPointLoopOnly) {
    maxUnrollFactor = loopUnrollFactor;
    pointLoopOnly = unrollPointLoopOnly;
  }

  void runOnOperation() override {
    auto func = getOperation();
    auto ca = ComplexityAnalysis(func);

    // Try to calculate the unroll factors of the nodes contained in each
    // dataflow schedule.
    auto result = func.walk<WalkOrder::PreOrder>([&](ScheduleOp schedule) {
      unsigned long scheduleUnrollFactor = maxUnrollFactor.getValue();
      if (auto parentNode = schedule->getParentOfType<NodeOp>()) {
        if (!nodeUnrollFactorMap.count(parentNode)) {
          parentNode.emitOpError("failed to get parent node's unroll factor");
          return WalkResult::interrupt();
        }
        scheduleUnrollFactor = nodeUnrollFactorMap.lookup(parentNode);
      }

      auto scheduleComplexity = ca.getScheduleComplexity(schedule);
      if (!scheduleComplexity.has_value()) {
        schedule.emitOpError("failed to get schedule complexity");
        return WalkResult::interrupt();
      }

      for (auto node : schedule.getOps<NodeOp>()) {
        auto nodeComplexity = ca.getNodeComplexity(node);
        if (!nodeComplexity.has_value()) {
          node.emitOpError("failed to get node complexity");
          return WalkResult::interrupt();
        }
        auto nodeUnrollFactor = 1 + scheduleUnrollFactor *
                                        nodeComplexity.value() /
                                        scheduleComplexity.value();
        nodeUnrollFactorMap.insert({node, nodeUnrollFactor});
      }
      return WalkResult::advance();
    });

    // Unroll each dataflow node based the calculated unroll factor.
    for (auto p : nodeUnrollFactorMap) {
      auto node = p.first;
      AffineLoopBands bands;

      // Collect all loop bands to be unrolled.
      node.walk([&](AffineForOp loop) {
        if (loop->getParentOfType<NodeOp>() == node &&
            loop.getOps<mlir::AffineForOp>().empty() &&
            loop.getOps<ScheduleOp>().empty()) {
          AffineLoopBand band;
          getLoopBandFromInnermost(loop, band);
          bands.push_back(band);
        }
      });

      for (auto &band : bands) {
        // For loop band that has effect on external buffers, we should directly
        // unroll them without considering whether it's point loop.
        if (hasEffectOnExternalBuffer(band.front())) {
          applyLoopUnrollJam(band, p.second);
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
        applyLoopUnrollJam(band, p.second);
      }
    }
  }

private:
  llvm::SmallDenseMap<NodeOp, unsigned long> nodeUnrollFactorMap;
};
} // namespace

std::unique_ptr<Pass>
scalehls::createParallelizeDataflowNodePass(unsigned loopUnrollFactor,
                                            bool unrollPointLoopOnly) {
  return std::make_unique<ParallelizeDataflowNode>(loopUnrollFactor,
                                                   unrollPointLoopOnly);
}
