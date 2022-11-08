//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static void getNodesToMerge(llvm::SmallDenseSet<NodeOp> const &allNodes,
                            llvm::SmallDenseSet<NodeOp> &visitedNodes,
                            NodeOp node, SmallVector<NodeOp> &nodesToMerge) {
  if (visitedNodes.insert(node).second)
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
    bool hasChanged = false;
    for (const auto &p : levelToNodesMap) {
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
        auto newNode = fuseNodeOps(nodesToMerge, rewriter);
        newNode.setLevelAttr(rewriter.getI32IntegerAttr(p.first));
        hasChanged = true;
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct InsertForkNode : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    auto loc = rewriter.getUnknownLoc();

    auto hasChanged = false;
    for (auto output : node.getOutputs()) {
      auto consumers = getConsumersExcept(output, node);
      if (consumers.size() < 2)
        continue;

      hasChanged = true;
      rewriter.setInsertionPointAfter(node);
      SmallVector<Value> buffers;
      SmallVector<Location> bufferLocs;

      // Insert a buffer for each consumer.
      for (auto consumer : consumers) {
        auto buffer = rewriter.create<BufferOp>(loc, output.getType());
        output.replaceUsesWithIf(
            buffer, [&](OpOperand &use) { return use.getOwner() == consumer; });
        buffers.push_back(buffer);
        bufferLocs.push_back(loc);
      }

      // Create a new fork node.
      auto fork = rewriter.create<NodeOp>(loc, output, buffers);
      auto block = rewriter.createBlock(&fork.getBody());
      auto outputArg = block->addArgument(output.getType(), output.getLoc());
      auto bufferArgs = block->addArguments(ValueRange(buffers), bufferLocs);

      // Create explicit copy from the original output to the buffers.
      rewriter.setInsertionPointToStart(block);
      for (auto bufferArg : bufferArgs)
        rewriter.create<memref::CopyOp>(loc, outputArg, bufferArg);
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct EliminateMultiConsumer
    : public EliminateMultiConsumerBase<EliminateMultiConsumer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<InsertForkNode>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    // mlir::RewritePatternSet patterns(context);
    // patterns.add<FuseMultiConsumer>(context);
    // auto frozenPatterns = FrozenRewritePatternSet(std::move(patterns));
    // func.walk([&](ScheduleOp schedule) {
    //   (void)applyOpPatternsAndFold(schedule, frozenPatterns);
    // });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createEliminateMultiConsumerPass() {
  return std::make_unique<EliminateMultiConsumer>();
}
