//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// Convert high dataflow to low dataflow
//===----------------------------------------------------------------------===//

namespace {
struct ConstBufferConversionPattern
    : public OpRewritePattern<memref::GetGlobalOp> {
  using OpRewritePattern<memref::GetGlobalOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::GetGlobalOp op,
                                PatternRewriter &rewriter) const override {
    auto global = SymbolTable::lookupNearestSymbolFrom<memref::GlobalOp>(
        op, op.nameAttr());
    rewriter.replaceOpWithNewOp<ConstBufferOp>(op, global.type(),
                                               global.getConstantInitValue());
    return success();
  }
};
} // namespace

namespace {
template <typename OpType>
struct BufferConversionPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<BufferOp>(op, op.getType(), /*depth=*/1);
    return success();
  }
};
} // namespace

namespace {
struct NodeConversionPattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    SmallVector<Value, 8> outputs;
    SmallVector<Location, 8> outputLocs;
    for (auto output : task.getYieldOp().getOperands()) {
      // TODO: How to handle this??
      output.getDefiningOp()->moveBefore(task);
      outputs.push_back(output);
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
        inputs.push_back(operand);
        inputArgs.push_back(arg);
        inputLocs.push_back(operand.getLoc());
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
    for (auto t : llvm::zip(outputs, newOutputArgs))
      std::get<0>(t).replaceAllUsesExcept(std::get<1>(t), node);

    auto newParamArgs = nodeBlock->addArguments(ValueRange(params), paramLocs);
    for (auto t : llvm::zip(paramArgs, newParamArgs))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

    rewriter.replaceOp(task, outputs);
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
// Legalize low dataflow
//===----------------------------------------------------------------------===//

namespace {
struct MultiProducerRemovePattern : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (buffer.getProducers().empty() ||
        llvm::hasSingleElement(buffer.getProducers()))
      return failure();

    Value currentBuffer = buffer;
    for (auto user : llvm::drop_begin(buffer.getProducers())) {
      auto node = cast<NodeOp>(user);
      auto operandIdx = llvm::find(node.getOperands(), buffer.memref()) -
                        node.operand_begin();

      // Create a new buffer.
      rewriter.setInsertionPoint(node);
      auto newBuffer = cast<BufferOp>(rewriter.clone(*buffer));
      node.setOperand(operandIdx, newBuffer);

      // Create a new node that takes the current buffer as input.
      auto newInputs = SmallVector<Value>(node.inputs());
      newInputs.push_back(currentBuffer);
      auto newNode =
          rewriter.create<NodeOp>(node.getLoc(), newInputs, node.outputs());
      rewriter.inlineRegionBefore(node.body(), newNode.body(),
                                  newNode.body().end());

      // Create an explicit data copy from the current buffer to new buffer.
      auto currentArg = newNode.getBody()->insertArgument(
          node.getNumInputs(), buffer.getType(), buffer.getLoc());
      auto newArg = newNode.getBody()->getArgument(operandIdx + 1);
      rewriter.setInsertionPointToStart(newNode.getBody());
      rewriter.create<memref::CopyOp>(rewriter.getUnknownLoc(), currentArg,
                                      newArg);

      // Finally, we can safely remove the node and update the current
      rewriter.eraseOp(node);
      currentBuffer = newBuffer;
    }
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

    unsigned level = 0;
    for (auto output : node.outputs()) {
      auto buffer = output.getDefiningOp<BufferOp>();
      if (!buffer)
        return node.emitOpError("has unexpected output");
      if (!buffer.getProducersExcept(node).empty())
        return failure();

      for (auto consumer : buffer.getConsumers()) {
        if (!consumer.level().hasValue())
          return failure();
        level = std::max(level, consumer.level().getValue() + 1);
      }
    }
    node.levelAttr(rewriter.getI32IntegerAttr(level));

    for (auto output : node.outputs()) {
      auto buffer = output.getDefiningOp<BufferOp>();
      SmallVector<std::pair<unsigned, NodeOp>, 4> worklist;
      for (auto consumer : buffer.getConsumers()) {
        auto diff = level - consumer.level().getValue();
        worklist.push_back({diff, consumer});
      }
      if (worklist.empty())
        continue;

      auto currentBuffer = buffer;
      auto currentNode = node;
      llvm::sort(worklist, [](auto a, auto b) { return a.first > b.first; });
      for (unsigned i = 2, e = worklist.front().first; i <= e; ++i) {
        // Create a new buffer.
        rewriter.setInsertionPoint(currentNode);
        auto newBuffer = cast<BufferOp>(rewriter.clone(*buffer));

        // Construct a new node for data copy.
        rewriter.setInsertionPointAfter(currentNode);
        auto newNode = rewriter.create<NodeOp>(
            rewriter.getUnknownLoc(), ValueRange(currentBuffer.memref()),
            ValueRange(newBuffer.memref()));
        auto block = rewriter.createBlock(&newNode.body());
        block->addArguments(
            TypeRange({currentBuffer.getType(), newBuffer.getType()}),
            {currentBuffer.getLoc(), newBuffer.getLoc()});

        // Create an explicit copy operation.
        rewriter.setInsertionPointToStart(block);
        rewriter.create<memref::CopyOp>(rewriter.getUnknownLoc(),
                                        block->getArgument(0),
                                        block->getArgument(1));

        // Replace all uses at the current level.
        llvm::SmallDenseSet<Operation *, 4> consumers;
        while (!worklist.empty() && (worklist.back().first == i))
          consumers.insert(worklist.pop_back_val().second);
        buffer.memref().replaceUsesWithIf(newBuffer, [&](OpOperand &use) {
          return consumers.count(use.getOwner());
        });

        // Finally, we can update current buffer and current node.
        currentBuffer = newBuffer;
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
  SmallVector<Value, 8> inputs;
  SmallVector<Location, 8> inputLocs;
  SmallVector<Value, 8> outputs;
  SmallVector<Location, 8> outputLocs;
  SmallVector<Value, 8> params;
  SmallVector<Location, 8> paramLocs;

  for (auto node : nodes) {
    for (auto input : node.inputs()) {
      inputs.push_back(input);
      inputLocs.push_back(input.getLoc());
    }
    for (auto output : node.outputs()) {
      outputs.push_back(output);
      outputLocs.push_back(output.getLoc());
    }
    for (auto param : node.params()) {
      params.push_back(param);
      paramLocs.push_back(param.getLoc());
    }
  }

  // Construct the new node after the last node.
  rewriter.setInsertionPointAfter(nodes.back());
  auto newNode = rewriter.create<NodeOp>(rewriter.getUnknownLoc(), inputs,
                                         outputs, params);
  auto block = rewriter.createBlock(&newNode.body());
  block->addArguments(ValueRange(inputs), inputLocs);
  block->addArguments(ValueRange(outputs), outputLocs);
  block->addArguments(ValueRange(params), paramLocs);

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
struct NodeMergePattern : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp target,
                                PatternRewriter &rewriter) const override {
    llvm::SmallDenseMap<unsigned, SmallVector<NodeOp, 4>> worklist;
    for (auto node : target.getOps<NodeOp>()) {
      if (auto level = node.level())
        worklist[level.getValue()].push_back(node);
      else
        return node.emitOpError("node is not scheduled");
    }

    bool hasChanged = false;
    for (const auto &p : worklist)
      if (p.second.size() > 1) {
        auto node = fuseNodeOps(p.second, rewriter);
        node.levelAttr(rewriter.getI32IntegerAttr(p.first));
        hasChanged = true;
      }
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

    // Convert dataflow node operations.
    ConversionTarget target(*context);
    target.addIllegalOp<memref::GetGlobalOp, memref::AllocOp, memref::AllocaOp,
                        TaskOp, YieldOp>();
    target.addLegalOp<ConstBufferOp, BufferOp, NodeOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConstBufferConversionPattern>(context);
    patterns.add<BufferConversionPattern<memref::AllocOp>>(context);
    patterns.add<BufferConversionPattern<memref::AllocaOp>>(context);
    patterns.add<NodeConversionPattern>(context);
    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();

    // Remove multi-producers and bypass paths.
    patterns.clear();
    patterns.add<ScheduleOutputRemovePattern>(context);
    patterns.add<MultiProducerRemovePattern>(context);
    patterns.add<BypassPathRemovePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    // Merge nodes at the same dataflow level.
    patterns.clear();
    patterns.add<NodeMergePattern>(context);
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
