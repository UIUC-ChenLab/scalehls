//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Analysis.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

ComplexityAnalysis::ComplexityAnalysis(func::FuncOp func) {
  func.walk([&](NodeOp node) {
    auto nodeComplexity = calculateBlockComplexity(&node.getBody().front());
    if (!nodeComplexity.has_value()) {
      node.emitOpError("failed to calculate node complexity");
      return WalkResult::interrupt();
    }
    nodeComplexityMap.insert({node, nodeComplexity.value()});
    return WalkResult::advance();
  });
}

/// A helper to get the complexity of a schedule.
Optional<unsigned long>
ComplexityAnalysis::getScheduleComplexity(ScheduleOp schedule) const {
  unsigned long scheduleComplexity = 0;
  for (auto node : schedule.getOps<NodeOp>()) {
    if (!nodeComplexityMap.count(node))
      return Optional<unsigned long>();
    scheduleComplexity =
        std::max(scheduleComplexity, nodeComplexityMap.lookup(node));
  }
  return scheduleComplexity;
}

Optional<unsigned long>
ComplexityAnalysis::getNodeComplexity(NodeOp node) const {
  if (nodeComplexityMap.count(node))
    return nodeComplexityMap.lookup(node);
  return Optional<unsigned long>();
}

/// A helper to get the complexity of the given block
Optional<unsigned long>
ComplexityAnalysis::calculateBlockComplexity(Block *block) const {
  unsigned long complexity = 0;
  for (auto &op : block->getOperations()) {
    assert(!isa<NodeOp>(op) && "must not be node op");

    if (auto schedule = dyn_cast<ScheduleOp>(op)) {
      auto scheduleComplexity = getScheduleComplexity(schedule);
      if (!scheduleComplexity.has_value())
        return Optional<unsigned long>();
      complexity += scheduleComplexity.value();

    } else if (auto loop = dyn_cast<mlir::AffineForOp>(op)) {
      auto loopComplexity = calculateBlockComplexity(loop.getBody());
      auto loopTripCount = getAverageTripCount(loop);
      if (!loopComplexity.has_value() || !loopTripCount.has_value())
        return Optional<unsigned long>();
      complexity += loopTripCount.value() *
                    std::max((unsigned long)1, loopComplexity.value());

    } else if (auto ifOp = dyn_cast<mlir::AffineIfOp>(op)) {
      auto thenComplexity = calculateBlockComplexity(ifOp.getThenBlock());
      if (!thenComplexity.has_value())
        return Optional<unsigned long>();
      auto ifComplexity = thenComplexity.value();

      if (ifOp.hasElse()) {
        auto elseComplexity = calculateBlockComplexity(ifOp.getElseBlock());
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

CorrelationAnalysis::CorrelationAnalysis(func::FuncOp func) {
  func.walk([](hls::BufferLikeInterface buffer) {
    // For now, we don't consider external memories in the correlation analysis.
    if (isExternalBuffer(buffer.getMemref()))
      return WalkResult::advance();

    auto isAnalyzable = [](NodeOp node) {
      return !cast<hls::StageLikeInterface>(node.getOperation())
                  .hasHierarchy() &&
             llvm::hasSingleElement(node.getOps<AffineForOp>());
    };

    for (auto producer : getProducers(buffer.getMemref())) {
      if (!isAnalyzable(producer))
        continue;
      for (auto consumer : getConsumersExcept(buffer.getMemref(), producer)) {
        if (!isAnalyzable(consumer))
          continue;
      }
    }
    return WalkResult::advance();
  });
}
