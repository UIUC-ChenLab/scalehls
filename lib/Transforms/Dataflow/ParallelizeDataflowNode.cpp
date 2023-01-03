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
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "parallelize-dataflow-node"

using namespace mlir;
using namespace scalehls;

/// Apply loop vectorization to the loop band.
static bool applyLoopVectorization(AffineLoopBand &band,
                                   FactorList vectorFactors) {
  assert(!band.empty() && "no loops provided");
  if (llvm::all_of(vectorFactors, [](unsigned factor) { return factor == 1; }))
    return true;

  // We require all loops to be parallel loop.
  for (auto loop : band)
    if (!(hasParallelAttr(loop) || isLoopParallel(loop)))
      return false;

  // Apply loop vectorization.
  auto loopSet = llvm::DenseSet<Operation *>(band.begin(), band.end());
  auto sizes = SmallVector<int64_t>(vectorFactors.begin(), vectorFactors.end());
  vectorizeAffineLoops(band.front()->getParentOp(), loopSet, sizes, {});
  return true;
}

namespace {
struct ParallelizeDataflowNode
    : public ParallelizeDataflowNodeBase<ParallelizeDataflowNode> {
  ParallelizeDataflowNode() = default;
  ParallelizeDataflowNode(unsigned loopUnrollFactor, bool unrollPointLoopOnly,
                          bool argComplexityAware, bool argCorrelationAware) {
    maxUnrollFactor = loopUnrollFactor;
    pointLoopOnly = unrollPointLoopOnly;
    complexityAware = argComplexityAware;
    correlationAware = argCorrelationAware;
  }

  /// Try to calculate the unroll factors of the nodes contained in each
  /// dataflow schedule.
  void getNodeParallelFactorMap(func::FuncOp func) {
    auto compAnal = ComplexityAnalysis(func);
    nodeParallelFactorMap.clear();

    func.walk<WalkOrder::PreOrder>([&](ScheduleOp schedule) {
      unsigned long scheduleUnrollFactor = maxUnrollFactor.getValue();
      if (auto parentNode = schedule->getParentOfType<NodeOp>()) {
        if (!nodeParallelFactorMap.count(parentNode)) {
          parentNode.emitOpError("failed to get parent node's unroll factor");
          return WalkResult::interrupt();
        }
        scheduleUnrollFactor = nodeParallelFactorMap.lookup(parentNode);
        // FIXME: A hacky method to hand tune the factors and resolve
        // outstanding dataflow nodes.
        if (auto attr = schedule->getAttr("increase"))
          if (auto annoFactor = attr.dyn_cast<IntegerAttr>())
            scheduleUnrollFactor *= annoFactor.getInt();
        if (auto attr = schedule->getAttr("decrease"))
          if (auto annoFactor = attr.dyn_cast<IntegerAttr>())
            scheduleUnrollFactor /= annoFactor.getInt();
      }

      auto scheduleComplexity = compAnal.getScheduleComplexity(schedule);
      if (!scheduleComplexity.has_value()) {
        schedule.emitOpError("failed to get schedule complexity");
        return WalkResult::interrupt();
      }

      for (auto node : schedule.getOps<NodeOp>()) {
        auto nodeComplexity = compAnal.getNodeComplexity(node);
        if (!nodeComplexity.has_value()) {
          node.emitOpError("failed to get node complexity");
          return WalkResult::interrupt();
        }
        auto nodeUnrollFactor = std::max(
            (unsigned long)1, scheduleUnrollFactor * nodeComplexity.value() /
                                  scheduleComplexity.value());
        nodeParallelFactorMap.insert({node, nodeUnrollFactor});

        LLVM_DEBUG(
            // clang-format off
          llvm::dbgs() << "\nNode Complexity: " << nodeComplexity.value() << "\n";
          llvm::dbgs() << "Schedule Complexity: " << scheduleComplexity.value() << "\n";
          llvm::dbgs() << "Node Factor: " << nodeUnrollFactor << "\n";
          llvm::dbgs() << "Schedule Factor: " << scheduleUnrollFactor << "\n";
          llvm::dbgs() << "Node at " << node.getLoc() << ": \n" << node << "\n";
            // clang-format on
        );
      }
      return WalkResult::advance();
    });
  }

  /// Unroll dataflow node with the given parallel factor. If the pass is not
  /// complexity aware, always unroll with the max unroll factor.
  void applyNaiveLoopUnroll(NodeOp node, unsigned parallelFactor) {
    auto unrollFactor = parallelFactor;
    if (!complexityAware)
      unrollFactor = maxUnrollFactor.getValue();

    // Collect all loop bands to be unrolled.
    AffineLoopBands bands;
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
      // FIXME: Need a better solution on handling external buffers.
      if (pointLoopOnly && !hasEffectOnExternalBuffer(band.front())) {
        AffineLoopBand tileBand;
        AffineLoopBand pointBand;
        if (!getTileAndPointLoopBand(band, tileBand, pointBand) ||
            pointBand.empty())
          continue;
        band = pointBand;
      }

      auto factors = FactorList(band.size(), 1);
      SmallVector<FactorList> constrFactors;
      if (failed(getEvenlyDistributedFactors(unrollFactor, factors, band,
                                             constrFactors)))
        factors = getDistributedFactors(unrollFactor, band);
      applyLoopUnrollJam(band, factors);
    }
  }

  /// Unroll loops based on the correlations between dataflow nodes.
  void applyCorrelationAwareUnroll(func::FuncOp func) {
    auto corrAnal = CorrelationAnalysis(func);

    // We first sort all nodes in a decending order of their associated number
    // of correlations. The rationale is nodes that have more correlations
    // should be optimized first.
    SmallVector<std::pair<NodeOp, unsigned>> worklist;
    for (auto &nodeAndList : corrAnal)
      worklist.push_back({nodeAndList.first, nodeAndList.second.size()});
    llvm::sort(worklist, [](auto a, auto b) { return a.second < b.second; });

    // Optimize the unroll factors from the most critical node.
    llvm::SmallDenseMap<NodeOp, FactorList> nodeUnrollFactorsMap;
    while (!worklist.empty()) {
      auto current = worklist.pop_back_val();
      auto node = current.first;
      auto corrNum = current.second;

      // If the correlation list is empty, which means the correlation analysis
      // failed, skip the current node.
      auto corrList = corrAnal.getCorrelations(node);
      if (corrList.empty())
        continue;

      // Get the parallel factor and loop band associated with the current node.
      // Also initialize the unroll factors as one.
      auto parallelFactor = maxUnrollFactor.getValue();
      if (complexityAware && nodeParallelFactorMap.count(node))
        parallelFactor = nodeParallelFactorMap.lookup(node);
      auto band = getNodeLoopBand(node);
      auto factors = FactorList(band.size(), 1);

      // Collect the loop unroll factors of all correlated nodes that have been
      // traversed. Additionally, collect the node and factors of external
      // buffer correlations for later use.
      SmallVector<FactorList> corrFactorsList;
      SmallVector<std::pair<NodeOp, FactorList>> externalNodeAndFactorsList;
      for (auto corr : corrList) {
        auto corrNode = corr.getCorrelatedNode(node);
        if (!nodeUnrollFactorsMap.count(corrNode))
          continue;

        // Permute the unroll factors of correlated node with the permutation
        // map recorded in the correlation.
        auto corrFactors = corr.permuteFactors(
            corrNode, nodeUnrollFactorsMap.lookup(corrNode));

        corrFactorsList.push_back(corrFactors);
        if (isExtBuffer(corr.getBuffer().getMemref())) {
          // Make sure each factor is larger than the corresponding factor of
          // the external buffer correlatations.
          FactorList newFactors;
          for (auto t : llvm::zip(factors, corrFactors))
            newFactors.push_back(std::max(std::get<0>(t), std::get<1>(t)));
          factors = newFactors;
          externalNodeAndFactorsList.push_back({corrNode, corrFactors});
        }

        LLVM_DEBUG(
            // clang-format off
            llvm::dbgs() << "----------\n";
            llvm::dbgs() << "Shared buffer at " << corr.getBuffer().getLoc()
                         << ": " << *corr.getBuffer() << "\n";
            llvm::dbgs() << "Correlate Map: { ";
            for (auto factor : corr.getCorrelateMap(node))
              llvm::dbgs() << factor << " ";
            llvm::dbgs() << "}\n";
            llvm::dbgs() << "Correlated Factors: { ";
            for (auto factor : corrFactors)
              llvm::dbgs() << factor << " ";
            llvm::dbgs() << "}\n";
            llvm::dbgs() << "Correlated Node at " << corrNode.getLoc() << ": \n"
                         << corrNode << "\n";
            // clang-format on
        );
      }

      // Distribute factor based on the constraints and record in the map.
      if (failed(getEvenlyDistributedFactors(parallelFactor, factors, band,
                                             corrFactorsList)))
        factors = getDistributedFactors(parallelFactor, band);
      nodeUnrollFactorsMap[node] = factors;

      // If the final factors are not equal to the factors of any external
      // buffer correlated node, we need to recalculate the node as they must be
      // identical eventually.
      for (auto externalNodeAndFactors : externalNodeAndFactorsList)
        if (factors != externalNodeAndFactors.second)
          worklist.push_back({externalNodeAndFactors.first, 0});

      LLVM_DEBUG(
          // clang-format off
          llvm::dbgs() << "\nCorrelations: " << corrNum << "\n";
          llvm::dbgs() << "Parallel: " << parallelFactor << "\n";
          llvm::dbgs() << "Factors: { ";
          for (auto factor : factors)
            llvm::dbgs() << factor << " ";
          llvm::dbgs() << "}\n";
          llvm::dbgs() << "Node at " << node.getLoc() << ": \n" << node << "\n";
          llvm::dbgs() << "==========\n";
          // clang-format on
      );
    }

    // Apply unroll and jam to loops that is successfully calculated for
    // correlation-aware unroll factors.
    for (auto p : nodeUnrollFactorsMap) {
      auto band = getNodeLoopBand(p.first);
      if (hasEffectOnExternalBuffer(band.front()))
        applyLoopVectorization(band, p.second);
      else
        applyLoopUnrollJam(band, p.second);
    }

    // Apply naive unroll to other loops.
    for (auto p : nodeParallelFactorMap)
      if (!nodeUnrollFactorsMap.count(p.first))
        applyNaiveLoopUnroll(p.first, p.second);
  }

  void runOnOperation() override {
    auto func = getOperation();
    getNodeParallelFactorMap(func);
    if (correlationAware)
      applyCorrelationAwareUnroll(func);
    else
      for (auto p : nodeParallelFactorMap)
        applyNaiveLoopUnroll(p.first, p.second);
  }

private:
  llvm::SmallDenseMap<NodeOp, unsigned long> nodeParallelFactorMap;
};
} // namespace

std::unique_ptr<Pass> scalehls::createParallelizeDataflowNodePass(
    unsigned loopUnrollFactor, bool unrollPointLoopOnly, bool complexityAware,
    bool correlationAware) {
  return std::make_unique<ParallelizeDataflowNode>(
      loopUnrollFactor, unrollPointLoopOnly, complexityAware, correlationAware);
}
