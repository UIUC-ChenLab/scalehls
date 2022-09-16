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

//===----------------------------------------------------------------------===//
// Convert dataflow task to node
//===----------------------------------------------------------------------===//

namespace {
struct NodeConversionPattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    SmallVector<Value, 8> outputs;
    SmallVector<Value, 8> outputArgs;
    SmallVector<Location, 8> outputLocs;
    for (auto output : task.getYieldOp().getOperands()) {
      // TODO: How to handle this??
      output.getDefiningOp()->moveBefore(task);
      outputs.push_back(output);
      outputArgs.push_back(output);
      outputLocs.push_back(output.getLoc());
    }

    SmallVector<Value, 8> inputs;
    SmallVector<BlockArgument, 8> inputArgs;
    SmallVector<Location, 8> inputLocs;
    SmallVector<Value, 8> params;
    SmallVector<BlockArgument, 8> paramArgs;
    SmallVector<Location, 8> paramLocs;
    for (auto arg : task.getBody()->getArguments()) {
      auto operand = task.getOperand(arg.getArgNumber());

      if (operand.getType().isa<MemRefType, StreamType>()) {
        if (llvm::any_of(arg.getUses(), isWritten)) {
          outputs.push_back(operand);
          outputArgs.push_back(arg);
          outputLocs.push_back(operand.getLoc());
        } else {
          inputs.push_back(operand);
          inputArgs.push_back(arg);
          inputLocs.push_back(operand.getLoc());
        }
      } else {
        params.push_back(operand);
        paramArgs.push_back(arg);
        paramLocs.push_back(operand.getLoc());
      }
    }

    rewriter.setInsertionPoint(task);
    auto node = rewriter.create<NodeOp>(rewriter.getUnknownLoc(), inputs,
                                        outputs, params);
    auto nodeBlock = rewriter.createBlock(&node.body());

    auto &nodeOps = nodeBlock->getOperations();
    auto &taskOps = task.getBody()->getOperations();
    nodeOps.splice(nodeOps.begin(), taskOps, taskOps.begin(),
                   std::prev(taskOps.end()));

    auto newInputArgs = nodeBlock->addArguments(ValueRange(inputs), inputLocs);
    for (auto t : llvm::zip(inputArgs, newInputArgs))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

    auto newOutputArgs =
        node.getBody()->addArguments(ValueRange(outputs), outputLocs);
    for (auto t : llvm::zip(outputArgs, newOutputArgs))
      std::get<0>(t).replaceAllUsesExcept(std::get<1>(t), node);

    auto newParamArgs = nodeBlock->addArguments(ValueRange(params), paramLocs);
    for (auto t : llvm::zip(paramArgs, newParamArgs))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

    rewriter.replaceOp(
        task, ValueRange({outputs.begin(),
                          std::next(outputs.begin(), task.getNumResults())}));
    return success();
  }
};
} // namespace

//===----------------------------------------------------------------------===//
// Schedule operation lowering
//===----------------------------------------------------------------------===//

namespace {
struct ScheduleOutputRemovePattern : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    auto returnOp = schedule.getReturnOp();

    SmallVector<Value, 4> remainedOutputs;
    SmallVector<OpResult, 4> remainedResults;
    SmallVector<Value, 4> hoistedOutputs;
    SmallVector<OpResult, 4> hoistedResults;
    for (auto result : schedule.getResults()) {
      auto output = returnOp.getOperand(result.getResultNumber());
      // TODO: How to handle this??
      if (auto buffer = output.getDefiningOp<BufferOp>())
        if (schedule->isAncestor(buffer)) {
          buffer->moveBefore(schedule);
          hasChanged = true;
          hoistedOutputs.push_back(output);
          hoistedResults.push_back(result);
          continue;
        }
      remainedOutputs.push_back(output);
      remainedResults.push_back(result);
    }

    if (hasChanged) {
      rewriter.setInsertionPoint(returnOp);
      rewriter.replaceOpWithNewOp<ReturnOp>(returnOp, remainedOutputs);

      rewriter.setInsertionPoint(schedule);
      auto newSchedule = rewriter.create<ScheduleOp>(
          schedule.getLoc(), ValueRange(remainedOutputs));
      rewriter.inlineRegionBefore(schedule.body(), newSchedule.body(),
                                  newSchedule.body().end());

      for (auto t : llvm::zip(remainedResults, newSchedule.getResults()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      for (auto t : llvm::zip(hoistedResults, hoistedOutputs))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

      rewriter.eraseOp(schedule);
    }
    return success(hasChanged);
  }
};
} // namespace

//===----------------------------------------------------------------------===//
// Legalize node-level dataflow
//===----------------------------------------------------------------------===//

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
      auto producers = getProducersInSchedule(buffer, schedule);
      llvm::sort(producers, [&](NodeOp a, NodeOp b) {
        return DT.properlyDominates(a, b);
      });
      if (node != producers.front())
        targetArgs.push_back(arg);
    }

    if (targetArgs.empty())
      return failure();

    auto loc = rewriter.getUnknownLoc();
    auto newInputs = SmallVector<Value>(node.inputs());
    rewriter.setInsertionPoint(node);

    // Create new buffers and write to them instead of the original buffers. The
    // original buffer will be passed into the new node as inputs.
    for (auto arg : targetArgs) {
      auto buffer = node.getOperand(arg.getArgNumber());
      newInputs.push_back(buffer);
      auto newBuffer = rewriter.create<BufferOp>(loc, arg.getType());
      node.setOperand(arg.getArgNumber(), newBuffer);

      buffer.replaceUsesWithIf(newBuffer, [&](OpOperand &use) {
        if (auto user = dyn_cast<NodeOp>(use.getOwner()))
          return user.getScheduleOp() == schedule &&
                 DT.properlyDominates(node, user);
        return false;
      });
    }

    // Create a new node and erase the original one.
    auto newNode =
        rewriter.create<NodeOp>(node.getLoc(), newInputs, node.outputs(),
                                node.params(), node.levelAttr());
    rewriter.inlineRegionBefore(node.body(), newNode.body(),
                                newNode.body().end());

    // Insert new arguments and create explicit data copy from the original
    // buffer to new buffer.
    rewriter.setInsertionPointToStart(newNode.getBody());
    for (auto e : llvm::enumerate(targetArgs)) {
      auto newBufferArg = e.value();
      auto bufferArg = newNode.getBody()->insertArgument(
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
    if (node.level().hasValue())
      return failure();
    auto schedule = node.getScheduleOp();

    unsigned level = 0;
    for (auto output : node.outputs()) {
      if (!getProducersInScheduleExcept(output, schedule, node).empty())
        return failure();

      for (auto consumer : getConsumersInSchedule(output, schedule)) {
        if (!consumer.level().hasValue())
          return failure();
        level = std::max(level, consumer.level().getValue() + 1);
      }
    }
    node.levelAttr(rewriter.getI32IntegerAttr(level));

    for (auto output : node.outputs()) {
      SmallVector<std::pair<unsigned, NodeOp>, 4> worklist;
      for (auto consumer : getConsumersInSchedule(output, schedule)) {
        auto diff = level - consumer.level().getValue();
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
        auto newBuf = rewriter.create<BufferOp>(loc, output.getType()).memref();

        // Construct a new node for data copy.
        rewriter.setInsertionPointAfter(currentNode);
        auto newNode = rewriter.create<NodeOp>(
            loc, ValueRange(currentBuf), ValueRange(newBuf), ValueRange(),
            /*level=*/rewriter.getI32IntegerAttr(level + 1 - i));
        auto block = rewriter.createBlock(&newNode.body());
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
  llvm::SmallVector<Location, 8> inputLocs;
  llvm::SetVector<Value> outputs;
  llvm::SmallVector<Location, 8> outputLocs;
  llvm::SetVector<Value> params;
  llvm::SmallVector<Location, 8> paramLocs;

  for (auto node : nodes) {
    for (auto input : node.inputs())
      if (inputs.insert(input))
        inputLocs.push_back(input.getLoc());
    for (auto output : node.outputs())
      if (outputs.insert(output))
        outputLocs.push_back(output.getLoc());
    for (auto param : node.params())
      if (params.insert(param))
        paramLocs.push_back(param.getLoc());
  }

  // Construct the new node after the last node.
  rewriter.setInsertionPointAfter(nodes.back());
  auto newNode =
      rewriter.create<NodeOp>(rewriter.getUnknownLoc(), inputs.getArrayRef(),
                              outputs.getArrayRef(), params.getArrayRef());
  auto block = rewriter.createBlock(&newNode.body());
  block->addArguments(ValueRange(inputs.getArrayRef()), inputLocs);
  block->addArguments(ValueRange(outputs.getArrayRef()), outputLocs);
  block->addArguments(ValueRange(params.getArrayRef()), paramLocs);

  // Inline all nodes into the new node.
  for (auto node : nodes) {
    auto &nodeOps = node.getBody()->getOperations();
    auto &newNodeOps = newNode.getBody()->getOperations();
    newNodeOps.splice(newNode.end(), nodeOps);
    for (auto t : llvm::zip(node.getBody()->getArguments(), node.getOperands()))
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
      if (auto level = node.level())
        worklist[level.getValue()].push_back(node);
      else
        return failure();
    }

    bool hasChanged = false;
    for (const auto &p : worklist)
      if (p.second.size() > 1) {
        auto node = fuseNodeOps(p.second, rewriter);
        node.levelAttr(rewriter.getI32IntegerAttr(p.first));
        hasChanged = true;
      }
    schedule.isLegalAttr(rewriter.getUnitAttr());
    return success(hasChanged);
  }
};
} // namespace

//===----------------------------------------------------------------------===//
// Pass entry
//===----------------------------------------------------------------------===//

namespace {
struct LowerDataflow : public LowerDataflowBase<LowerDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    // Convert dataflow task to node.
    ConversionTarget target(*context);
    target.addIllegalOp<TaskOp, YieldOp>();
    target.addLegalOp<NodeOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<NodeConversionPattern>(context);
    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();

    // Legalize dataflow schedule.
    patterns.clear();
    patterns.add<MultiProducerRemovePattern>(context);
    patterns.add<BypassPathRemovePattern>(context);
    patterns.add<ScheduleOutputRemovePattern>(context);
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

std::unique_ptr<Pass> scalehls::createLowerDataflowPass() {
  return std::make_unique<LowerDataflow>();
}
