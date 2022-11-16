//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static void collectNodes(llvm::SmallDenseSet<NodeOp> const &allNodes,
                         llvm::SmallDenseSet<NodeOp> &visitedNodes,
                         SmallVector<NodeOp> &nodesToMerge, NodeOp node) {
  if (!visitedNodes.insert(node).second)
    return;
  nodesToMerge.push_back(node);
  for (auto input : node.getInputs())
    for (auto consumer : getConsumersExcept(input, node))
      if (allNodes.count(consumer))
        collectNodes(allNodes, visitedNodes, nodesToMerge, consumer);
}

namespace {
struct FuseMultiConsumer : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    // Collect nodes that are scheduled to the same level.
    llvm::SmallDenseMap<unsigned, llvm::SmallDenseSet<NodeOp>> levelToNodesMap;
    for (auto node : schedule.getOps<NodeOp>()) {
      if (auto level = node.getLevel())
        levelToNodesMap[level.value()].insert(node);
      else
        return failure();
    }

    // Merge nodes at the same level if they share the same input (to remove
    // multi-consumer violation).
    DominanceInfo domInfo;
    bool hasChanged = false;
    for (const auto &p : levelToNodesMap) {
      // llvm::outs() << p.first << "\n";
      llvm::SmallDenseSet<NodeOp> visitedNodes;
      SmallVector<SmallVector<NodeOp>> worklist;

      for (auto node : p.second) {
        if (visitedNodes.count(node))
          continue;
        SmallVector<NodeOp> nodesToMerge;
        collectNodes(p.second, visitedNodes, nodesToMerge, node);
        if (nodesToMerge.size() > 1)
          worklist.push_back(nodesToMerge);
      }

      for (auto nodesToMerge : worklist) {
        // llvm::outs() << "merged " << nodesToMerge.size() << "\n";
        llvm::sort(nodesToMerge,
                   [&](NodeOp a, NodeOp b) { return domInfo.dominates(a, b); });
        auto newNode = fuseNodeOps(nodesToMerge, rewriter);
        newNode.setLevelAttr(rewriter.getI32IntegerAttr(p.first));
        hasChanged = true;
      }
    }
    schedule.setIsLegalAttr(rewriter.getUnitAttr());
    return success(hasChanged);
  }
};
} // namespace

static void collectBypassNodes(
    llvm::SmallDenseMap<unsigned, llvm::SmallDenseSet<NodeOp>> const &map,
    llvm::SmallDenseSet<unsigned> &mergedLevels,
    SmallVector<NodeOp> &nodesToMerge, unsigned targetLevel) {
  // Find the maximum difference between the nodes in the current level and
  // all consumer nodes.
  unsigned maxDiff = 1;
  for (auto node : map.lookup(targetLevel)) {
    for (auto output : node.getOutputs()) {
      if (output.isa<BlockArgument>() &&
          node.getScheduleOp().isDependenceFree())
        continue;

      SmallVector<std::pair<unsigned, NodeOp>, 4> bypassNodes;
      for (auto consumer : getDependentConsumers(output, node)) {
        auto diff = node.getLevel().value() - consumer.getLevel().value();
        if (diff > 1)
          bypassNodes.push_back({diff, consumer});
      }
      if (bypassNodes.empty())
        continue;

      // Sort all consumers in a descending order of level difference.
      llvm::sort(bypassNodes, [](auto a, auto b) { return a.first > b.first; });
      maxDiff = std::max(maxDiff, bypassNodes.front().first);
    }
  }
  if (maxDiff == 1)
    return;

  for (auto level = targetLevel - 1; level >= targetLevel - maxDiff; --level) {
    if (!mergedLevels.insert(level).second)
      continue;
    // llvm::outs() << "---------- " << level << "\n";
    for (auto node : map.lookup(level))
      nodesToMerge.push_back(node);
    collectBypassNodes(map, mergedLevels, nodesToMerge, level);
  }
}

namespace {
struct FuseBypassPath : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    // Collect nodes that are scheduled to the same level.
    unsigned maxLevel = 0;
    llvm::SmallDenseMap<unsigned, llvm::SmallDenseSet<NodeOp>> levelToNodesMap;
    for (auto node : schedule.getOps<NodeOp>()) {
      if (auto level = node.getLevel()) {
        levelToNodesMap[level.value()].insert(node);
        maxLevel = std::max(maxLevel, level.value());
      } else
        return failure();
    }

    // Traverse all dataflow node levels.
    llvm::SmallDenseSet<unsigned> mergedLevels;
    SmallVector<SmallVector<NodeOp>> worklist;

    for (auto level = maxLevel; level > 0; --level) {
      if (mergedLevels.count(level))
        continue;
      // llvm::outs() << "\n========== " << level << "\n";
      SmallVector<NodeOp> nodesToMerge;
      collectBypassNodes(levelToNodesMap, mergedLevels, nodesToMerge, level);
      if (nodesToMerge.size() > 1)
        worklist.push_back(nodesToMerge);
    }

    bool hasChanged = false;
    DominanceInfo domInfo;
    for (auto nodesToMerge : worklist) {
      // llvm::outs() << "merged " << nodesToMerge.size() << "\n";
      llvm::sort(nodesToMerge,
                 [&](NodeOp a, NodeOp b) { return domInfo.dominates(a, b); });
      auto newNode = fuseNodeOps(nodesToMerge, rewriter);
      newNode.setLevelAttr(
          rewriter.getI32IntegerAttr(nodesToMerge.front().getLevel().value()));
      hasChanged = true;
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct LegalizeDataflow : public LegalizeDataflowBase<LegalizeDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet pattern1(context);
    pattern1.add<FuseMultiConsumer>(context);
    auto frozenPattern1 = FrozenRewritePatternSet(std::move(pattern1));

    mlir::RewritePatternSet pattern2(context);
    pattern2.add<FuseBypassPath>(context);
    auto frozenPattern2 = FrozenRewritePatternSet(std::move(pattern2));

    func.walk([&](ScheduleOp schedule) {
      (void)applyOpPatternsAndFold(schedule, frozenPattern1);
      (void)applyOpPatternsAndFold(schedule, frozenPattern2);
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
