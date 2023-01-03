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

namespace {
struct InsertCopyNode : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    if (!node.getLevel())
      return failure();

    for (auto output : node.getOutputs()) {
      if (output.isa<BlockArgument>() &&
          node.getScheduleOp().isDependenceFree())
        continue;

      SmallVector<std::pair<unsigned, NodeOp>, 4> worklist;
      for (auto consumer : getDependentConsumers(output, node)) {
        auto diff = node.getLevel().value() - consumer.getLevel().value();
        if (diff > 1)
          worklist.push_back({diff, consumer});
      }
      if (worklist.empty())
        continue;

      // Sort all consumers in a descending order of level difference.
      llvm::sort(worklist, [](auto a, auto b) { return a.first > b.first; });
      auto maxDiff = worklist.front().first;

      // If the output is written to a DRAM buffer allocated inside of the
      // schedule, then we can set the depth of the DRAM buffer and use taps to
      // access the data. In this way, we no longer need to allocate multiple
      // buffers and construct explicit copy to move data. Instead, we can
      // implement the ping-pong buffer in DRAM that saves the memory interface
      // and logic resources.
      if (auto buffer = output.getDefiningOp<BufferOp>())
        if (isExtBuffer(output)) {
          buffer.setDepthAttr(rewriter.getI32IntegerAttr(maxDiff));
          for (auto item : worklist) {
            auto consumer = item.second;
            auto idx = llvm::find(consumer.getInputs(), output) -
                       consumer.getInputs().begin();
            item.second.setInputTap(idx, item.first - 1);
          }
          continue;
        }

      // Otherwise, we need to construct a chain of buffers to hold data at each
      // level and construct explicit copies to pass data between different
      // dataflow levels.
      auto currentBuf = output;
      auto currentNode = node;
      for (unsigned i = 2; i <= maxDiff; ++i) {
        // Create a new buffer.
        auto loc = rewriter.getUnknownLoc();
        rewriter.setInsertionPoint(currentNode);
        auto newBuf =
            rewriter.create<BufferOp>(loc, output.getType()).getMemref();

        // Construct a new node for data copy.
        rewriter.setInsertionPointAfter(currentNode);
        auto newNode = rewriter.create<NodeOp>(loc, ValueRange(currentBuf),
                                               ValueRange(newBuf));
        newNode.setLevelAttr(
            rewriter.getI32IntegerAttr(node.getLevel().value() + 1 - i));
        auto block = rewriter.createBlock(&newNode.getBody());
        block->addArguments(TypeRange({currentBuf.getType(), newBuf.getType()}),
                            {currentBuf.getLoc(), newBuf.getLoc()});

        // Create an explicit copy operation.
        rewriter.setInsertionPointToStart(block);
        rewriter.create<memref::CopyOp>(loc, block->getArgument(0),
                                        block->getArgument(1));

        // Replace all uses at the current level.
        llvm::SmallDenseSet<Operation *, 4> consumers;
        while (!worklist.empty() && (worklist.back().first == i))
          consumers.insert(worklist.pop_back_val().second);
        output.replaceUsesWithIf(newBuf, [&](OpOperand &use) {
          return consumers.count(use.getOwner());
        });

        // Finally, we can update current buffer and current node.
        currentBuf = newBuf;
        currentNode = newNode;
      }
    }
    return success();
  }
};
} // namespace

namespace {
struct BalanceDataflowNode
    : public BalanceDataflowNodeBase<BalanceDataflowNode> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<InsertCopyNode>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createBalanceDataflowNodePass() {
  return std::make_unique<BalanceDataflowNode>();
}
