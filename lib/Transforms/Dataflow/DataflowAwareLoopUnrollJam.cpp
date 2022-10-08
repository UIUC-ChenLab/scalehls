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

namespace {
struct DataflowAwareLoopUnrollJam
    : public DataflowAwareLoopUnrollJamBase<DataflowAwareLoopUnrollJam> {
  DataflowAwareLoopUnrollJam() = default;
  DataflowAwareLoopUnrollJam(unsigned loopUnrollFactor,
                             bool unrollPointLoopOnly, bool argLoopOrderOpt) {
    maxUnrollFactor = loopUnrollFactor;
    pointLoopOnly = unrollPointLoopOnly;
    loopOrderOpt = argLoopOrderOpt;
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
        complexity += loopTripCount.value() * loopComplexity.value();

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

      } else if (!op.hasTrait<OpTrait::IsTerminator>())
        complexity += 1;
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
        if (pointLoopOnly) {
          AffineLoopBand tileBand;
          AffineLoopBand pointBand;
          if (!getTileAndPointLoopBand(band, tileBand, pointBand) ||
              pointBand.empty())
            continue;
          band = pointBand;
        }
        applyLoopUnrollJam(band, p.second, loopOrderOpt.getValue());
      }
    }
  }

private:
  llvm::SmallDenseMap<NodeOp, unsigned long> nodeComplexityMap;
  llvm::SmallDenseMap<NodeOp, unsigned long> nodeUnrollFactorMap;
};
} // namespace

std::unique_ptr<Pass> scalehls::createDataflowAwareLoopUnrollJamPass(
    unsigned loopUnrollFactor, bool unrollPointLoopOnly, bool loopOrderOpt) {
  return std::make_unique<DataflowAwareLoopUnrollJam>(
      loopUnrollFactor, unrollPointLoopOnly, loopOrderOpt);
}
