//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Analysis.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "dataflow-analysis"

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

SmallVector<int64_t> getBufferIndexToLoopDepthMap(NodeOp node, Value buffer) {
  if (cast<hls::StageLikeInterface>(node.getOperation()).hasHierarchy() ||
      !llvm::hasSingleElement(node.getOps<AffineForOp>()))
    return SmallVector<int64_t>();

  auto band = getNodeLoopBand(node);
  auto localBuffer = node.getBody().getArgument(
      llvm::find(node.getOperands(), buffer) - node.operand_begin());

  SmallVector<Value> bufferIndices;
  auto result = band.front().walk([&](Operation *op) {
    Value memref;
    AffineMap map;
    SmallVector<Value> indices;
    if (auto read = dyn_cast<mlir::AffineReadOpInterface>(op)) {
      memref = read.getMemRef();
      map = read.getAffineMap();
      indices = read.getMapOperands();
    } else if (auto write = dyn_cast<mlir::AffineWriteOpInterface>(op)) {
      memref = write.getMemRef();
      map = write.getAffineMap();
      indices = write.getMapOperands();
    } else
      return WalkResult::advance();

    if (memref != localBuffer)
      return WalkResult::advance();
    if (!map.isIdentity())
      return WalkResult::interrupt();

    if (bufferIndices.empty())
      bufferIndices = indices;
    else if (bufferIndices != indices)
      return WalkResult::interrupt();
    return WalkResult::advance();
  });

  if (result.wasInterrupted())
    return SmallVector<int64_t>();

  SmallVector<int64_t> depths;
  for (auto index : bufferIndices) {
    if (isForInductionVar(index)) {
      auto loop = getForInductionVarOwner(index);
      unsigned depth = llvm::find(band, loop) - band.begin();
      if (depth != band.size()) {
        depths.push_back(depth);
        continue;
      }
    }
    depths.push_back(-1);
  }
  return depths;
}

SmallVector<int64_t> getPermuteMap(NodeOp node, SmallVector<int64_t> lhsDepths,
                                   SmallVector<int64_t> rhsDepths) {
  assert(lhsDepths.size() == rhsDepths.size() && "incorrect number of depths");
  SmallVector<int64_t> permuteMap;

  for (int64_t i = 0, e = getNodeLoopBand(node).size(); i < e; i++) {
    unsigned index = llvm::find(rhsDepths, i) - rhsDepths.begin();
    if (index != rhsDepths.size())
      if (lhsDepths[index] != -1) {
        permuteMap.push_back(lhsDepths[index]);
        continue;
      }
    permuteMap.push_back(-1);
  }
  return permuteMap;
}

CorrelationAnalysis::CorrelationAnalysis(func::FuncOp func) {
  func.walk([&](hls::BufferLikeInterface bufferOp) {
    auto buffer = bufferOp.getMemref();

    // For now, we don't consider external memories in the correlation analysis.
    if (isExternalBuffer(buffer))
      return WalkResult::advance();

    // TODO: Support nested node and node that has multiple loop bands.
    for (auto producer : getProducers(buffer)) {
      auto sourceDepths = getBufferIndexToLoopDepthMap(producer, buffer);
      if (sourceDepths.empty())
        continue;

      for (auto consumer : getConsumersExcept(buffer, producer)) {
        auto targetDepths = getBufferIndexToLoopDepthMap(consumer, buffer);
        if (targetDepths.empty())
          continue;

        auto sourceToTargetMap =
            getPermuteMap(consumer, sourceDepths, targetDepths);
        auto targetToSourceMap =
            getPermuteMap(producer, targetDepths, sourceDepths);

        auto corr = Correlation(producer, consumer, bufferOp, sourceToTargetMap,
                                targetToSourceMap);
        LLVM_DEBUG(
            // clang-format off
            llvm::dbgs() << "\n--------- Correlation ----------\n";
            llvm::dbgs() << "Buffer at " << bufferOp.getLoc() << ": "
                         << bufferOp << "\n";
            llvm::dbgs() << "Producer at " << producer.getLoc() << ":\n"
                         << producer << "\n";
            llvm::dbgs() << "Consumer at " << consumer.getLoc() << ":\n"
                         << consumer << "\n";
            llvm::dbgs() << "Source-to-target Map: { ";
            for (auto i : sourceToTargetMap)
              llvm::dbgs() << i << " ";
            llvm::dbgs() << "}\n";
            llvm::dbgs() << "Target-to-source Map: { ";
            for (auto i : targetToSourceMap)
              llvm::dbgs() << i << " ";
            llvm::dbgs() << "}\n";
            // clang-format on
        );

        // correlations.push_back(corr);
        nodeCorrelationMap[producer].push_back(corr);
        nodeCorrelationMap[consumer].push_back(corr);
      }
    }
    return WalkResult::advance();
  });
}
