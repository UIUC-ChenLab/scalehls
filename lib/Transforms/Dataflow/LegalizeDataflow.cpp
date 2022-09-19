//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct MultiProducerRemovePattern : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    auto schedule = node.getScheduleOp();
    DominanceInfo DT(schedule);

    // Get all argument buffers that need to be transformed.
    SmallVector<BlockArgument, 4> targetArgs;
    for (auto arg : node.getOutputArgs()) {
      auto buffer = node.getOperand(arg.getArgNumber());
      // If the buffer is defined outside of the parent schedule, then we cannot
      // resolve the multi-producer violation through buffering.
      if (buffer.isa<BlockArgument>())
        continue;

      SmallVector<NodeOp, 4> producers(getProducers(buffer));
      llvm::sort(producers, [&](NodeOp a, NodeOp b) {
        return DT.properlyDominates(a, b);
      });
      if (node != producers.front())
        targetArgs.push_back(arg);
    }

    if (targetArgs.empty())
      return failure();

    auto loc = rewriter.getUnknownLoc();
    auto newInputs = SmallVector<Value>(node.getInputs());
    SmallVector<int32_t> newInputTaps(node.getInputTapsAsInt());
    rewriter.setInsertionPoint(node);

    // Create new buffers and write to them instead of the original buffers. The
    // original buffer will be passed into the new node as inputs.
    for (auto arg : targetArgs) {
      auto buffer = node.getOperand(arg.getArgNumber());
      newInputs.push_back(buffer);
      newInputTaps.push_back(0);
      auto newBuffer = rewriter.create<BufferOp>(loc, arg.getType());
      node.setOperand(arg.getArgNumber(), newBuffer);

      buffer.replaceUsesWithIf(newBuffer, [&](OpOperand &use) {
        if (auto user = dyn_cast<NodeOp>(use.getOwner()))
          return DT.properlyDominates(node, user);
        return false;
      });
    }

    // Create a new node and erase the original one.
    auto newNode = rewriter.create<NodeOp>(node.getLoc(), newInputs,
                                           node.getOutputs(), node.getParams(),
                                           newInputTaps, node.getLevelAttr());
    rewriter.inlineRegionBefore(node.getBody(), newNode.getBody(),
                                newNode.getBody().end());

    // Insert new arguments and create explicit data copy from the original
    // buffer to new buffer.
    rewriter.setInsertionPointToStart(&newNode.getBody().front());
    for (auto e : llvm::enumerate(targetArgs)) {
      auto newBufferArg = e.value();
      auto bufferArg = newNode.getBody().insertArgument(
          node.getNumInputs() + e.index(), newBufferArg.getType(),
          newBufferArg.getLoc());
      rewriter.create<memref::CopyOp>(loc, bufferArg, newBufferArg);
    }

    rewriter.eraseOp(node);
    return success();
  }
};
} // namespace

namespace {
struct BypassPathRemovePattern : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    if (node.getLevel())
      return failure();

    unsigned level = 0;
    for (auto output : node.getOutputs()) {
      // TODO: Consider to merge all producers into the same level.
      if (!getProducersExcept(output, node).empty())
        return failure();

      for (auto consumer : getConsumers(output)) {
        if (!consumer.getLevel())
          return failure();
        level = std::max(level, consumer.getLevel().value() + 1);
      }
    }
    node.setLevelAttr(rewriter.getI32IntegerAttr(level));

    for (auto output : node.getOutputs()) {
      SmallVector<std::pair<unsigned, NodeOp>, 4> worklist;
      for (auto consumer : getConsumers(output)) {
        auto diff = level - consumer.getLevel().value();
        if (diff > 1)
          worklist.push_back({diff, consumer});
      }
      if (worklist.empty())
        continue;

      auto currentBuf = output;
      auto currentNode = node;
      llvm::sort(worklist, [](auto a, auto b) { return a.first > b.first; });
      for (unsigned i = 2, e = worklist.front().first; i <= e; ++i) {
        // Create a new buffer.
        auto loc = rewriter.getUnknownLoc();
        rewriter.setInsertionPoint(currentNode);
        auto newBuf =
            rewriter.create<BufferOp>(loc, output.getType()).getMemref();

        // Construct a new node for data copy.
        rewriter.setInsertionPointAfter(currentNode);
        auto newNode = rewriter.create<NodeOp>(loc, ValueRange(currentBuf),
                                               ValueRange(newBuf));
        newNode.setLevelAttr(rewriter.getI32IntegerAttr(level + 1 - i));
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

static NodeOp fuseNodeOps(ArrayRef<NodeOp> nodes, PatternRewriter &rewriter) {
  assert((nodes.size() > 1) && "must fuse at least two nodes");

  // Collect inputs, outputs, and params of the new node.
  llvm::SetVector<Value> inputs;
  llvm::SmallVector<int32_t, 8> inputTaps;
  llvm::SmallVector<Location, 8> inputLocs;
  llvm::SetVector<Value> outputs;
  llvm::SmallVector<Location, 8> outputLocs;
  llvm::SetVector<Value> params;
  llvm::SmallVector<Location, 8> paramLocs;

  for (auto node : nodes) {
    for (auto input : llvm::enumerate(node.getInputs()))
      if (inputs.insert(input.value())) {
        inputLocs.push_back(input.value().getLoc());
        inputTaps.push_back(node.getInputTap(input.index()));
      }
    for (auto output : node.getOutputs())
      if (outputs.insert(output))
        outputLocs.push_back(output.getLoc());
    for (auto param : node.getParams())
      if (params.insert(param))
        paramLocs.push_back(param.getLoc());
  }

  // Construct the new node after the last node.
  rewriter.setInsertionPointAfter(nodes.back());
  auto newNode = rewriter.create<NodeOp>(
      rewriter.getUnknownLoc(), inputs.getArrayRef(), outputs.getArrayRef(),
      params.getArrayRef(), inputTaps);
  auto block = rewriter.createBlock(&newNode.getBody());
  block->addArguments(ValueRange(inputs.getArrayRef()), inputLocs);
  block->addArguments(ValueRange(outputs.getArrayRef()), outputLocs);
  block->addArguments(ValueRange(params.getArrayRef()), paramLocs);

  // Inline all nodes into the new node.
  for (auto node : nodes) {
    auto &nodeOps = node.getBody().front().getOperations();
    auto &newNodeOps = newNode.getBody().front().getOperations();
    newNodeOps.splice(newNode.end(), nodeOps);
    for (auto t : llvm::zip(node.getBody().getArguments(), node.getOperands()))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
    rewriter.eraseOp(node);
  }

  for (auto t : llvm::zip(newNode.getOperands(), block->getArguments()))
    std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
      return newNode->isProperAncestor(use.getOwner());
    });
  return newNode;
}

namespace {
struct ScheduleLegalizePattern : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    llvm::SmallDenseMap<unsigned, SmallVector<NodeOp, 4>> worklist;
    for (auto node : schedule.getOps<NodeOp>()) {
      if (auto level = node.getLevel())
        worklist[level.value()].push_back(node);
      else
        return failure();
    }

    bool hasChanged = false;
    for (const auto &p : worklist)
      if (p.second.size() > 1) {
        auto node = fuseNodeOps(p.second, rewriter);
        node.setLevelAttr(rewriter.getI32IntegerAttr(p.first));
        hasChanged = true;
      }
    schedule.setIsLegalAttr(rewriter.getUnitAttr());
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct LegalizeDataflow : public LegalizeDataflowBase<LegalizeDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<MultiProducerRemovePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    patterns.clear();
    patterns.add<BypassPathRemovePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    patterns.clear();
    patterns.add<ScheduleLegalizePattern>(context);
    auto frozenPatterns = FrozenRewritePatternSet(std::move(patterns));
    func.walk([&](ScheduleOp schedule) {
      (void)applyOpPatternsAndFold(schedule, frozenPatterns);
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
