//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Utils.h"
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

  /// A helper to get the complexity of a schedule.
  Optional<unsigned long> getScheduleComplexity(ScheduleOp schedule) const {
    unsigned long scheduleComplexity = 0;
    for (auto node : schedule.getOps<NodeOp>()) {
      if (!nodeComplexityMap.count(node))
        return Optional<unsigned long>();
      scheduleComplexity =
          std::max(scheduleComplexity, nodeComplexityMap.lookup(node));
    }
    return scheduleComplexity;
  }

  /// A helper to get the complexity of the given block
  Optional<unsigned long> getBlockComplexity(Block *block) const {
    unsigned long complexity = 0;
    for (auto &op : block->getOperations()) {
      assert(!isa<NodeOp>(op) && "must not be node op");

      if (auto schedule = dyn_cast<ScheduleOp>(op)) {
        auto scheduleComplexity = getScheduleComplexity(schedule);
        if (!scheduleComplexity.has_value())
          return Optional<unsigned long>();
        complexity += scheduleComplexity.value();

      } else if (auto loop = dyn_cast<mlir::AffineForOp>(op)) {
        auto loopComplexity = getBlockComplexity(loop.getBody());
        auto loopTripCount = getAverageTripCount(loop);
        if (!loopComplexity.has_value() || !loopTripCount.has_value())
          return Optional<unsigned long>();
        complexity += loopTripCount.value() *
                      std::max((unsigned long)1, loopComplexity.value());

      } else if (auto ifOp = dyn_cast<mlir::AffineIfOp>(op)) {
        auto thenComplexity = getBlockComplexity(ifOp.getThenBlock());
        if (!thenComplexity.has_value())
          return Optional<unsigned long>();
        auto ifComplexity = thenComplexity.value();

        if (ifOp.hasElse()) {
          auto elseComplexity = getBlockComplexity(ifOp.getElseBlock());
          if (!elseComplexity.has_value())
            return Optional<unsigned long>();
          ifComplexity = std::max(ifComplexity, elseComplexity.value());
        }
        complexity += ifComplexity;
      }
      // else if (!op.hasTrait<OpTrait::IsTerminator>())
      //   complexity += 1;
    }
    return complexity;
  }

  void runOnOperation() override {
    auto func = getOperation();

    // Try to calculate the computational complexity of each node.
    auto result = func.walk([&](NodeOp node) {
      auto nodeComplexity = getBlockComplexity(&node.getBody().front());
      if (!nodeComplexity.has_value()) {
        node.emitOpError("failed to calculate node complexity");
        return WalkResult::interrupt();
      }
      nodeComplexityMap.insert({node, nodeComplexity.value()});
      return WalkResult::advance();
    });

    // Try to calculate the unroll factors of the nodes contained in each
    // dataflow schedule.
    result = func.walk<WalkOrder::PreOrder>([&](ScheduleOp schedule) {
      unsigned long scheduleUnrollFactor = maxUnrollFactor.getValue();
      if (auto parentNode = schedule->getParentOfType<NodeOp>()) {
        if (!nodeUnrollFactorMap.count(parentNode)) {
          parentNode.emitOpError("failed to get parent node's unroll factor");
          return WalkResult::interrupt();
        }
        scheduleUnrollFactor = nodeUnrollFactorMap.lookup(parentNode);
      }

      auto scheduleComplexity = getScheduleComplexity(schedule);
      if (!scheduleComplexity.has_value()) {
        schedule.emitOpError("failed to get schedule complexity");
        return WalkResult::interrupt();
      }

      for (auto node : schedule.getOps<NodeOp>()) {
        if (!nodeComplexityMap.count(node)) {
          node.emitOpError("failed to get node complexity");
          return WalkResult::interrupt();
        }
        auto nodeUnrollFactor = 1 + scheduleUnrollFactor *
                                        nodeComplexityMap.lookup(node) /
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
  llvm::SmallDenseMap<NodeOp, unsigned long> nodeComplexityMap;
  llvm::SmallDenseMap<NodeOp, unsigned long> nodeUnrollFactorMap;
};
} // namespace

std::unique_ptr<Pass>
scalehls::createParallelizeDataflowNodePass(unsigned loopUnrollFactor,
                                            bool unrollPointLoopOnly) {
  return std::make_unique<ParallelizeDataflowNode>(loopUnrollFactor,
                                                   unrollPointLoopOnly);
}
