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

static void getNodesToMerge(llvm::SmallDenseSet<NodeOp> const &allNodes,
                            llvm::SmallDenseSet<NodeOp> &visitedNodes,
                            NodeOp node, SmallVector<NodeOp> &nodesToMerge) {
  if (!visitedNodes.insert(node).second)
    return;
  nodesToMerge.push_back(node);
  for (auto input : node.getInputs())
    for (auto consumer : getConsumersExcept(input, node))
      if (allNodes.count(consumer))
        getNodesToMerge(allNodes, visitedNodes, consumer, nodesToMerge);
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
        getNodesToMerge(p.second, visitedNodes, node, nodesToMerge);
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

namespace {
struct EliminateMultiConsumerDeprecated
    : public EliminateMultiConsumerDeprecatedBase<
          EliminateMultiConsumerDeprecated> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<FuseMultiConsumer>(context);
    auto frozenPatterns = FrozenRewritePatternSet(std::move(patterns));
    func.walk([&](ScheduleOp schedule) {
      (void)applyOpPatternsAndFold(schedule, frozenPatterns);
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createEliminateMultiConsumerDeprecatedPass() {
  return std::make_unique<EliminateMultiConsumerDeprecated>();
}
