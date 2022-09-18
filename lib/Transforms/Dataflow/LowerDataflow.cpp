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

//===----------------------------------------------------------------------===//
// Convert dataflow task to node
//===----------------------------------------------------------------------===//

namespace {
struct NodeConversionPattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    SmallVector<Value, 4> outputsToReplace;
    for (auto output : task.getYieldOp().getOperands()) {
      if (auto arg = output.dyn_cast<BlockArgument>())
        outputsToReplace.push_back(task.getOperand(arg.getArgNumber()));
      else
        return task.emitOpError("must yield task arguments");
      if (!output.getType().isa<MemRefType, StreamType>())
        return task.emitOpError("must yield memref or stream values");
    }

    SmallVector<Value, 8> inputs;
    SmallVector<BlockArgument, 8> inputArgs;
    SmallVector<Location, 8> inputLocs;
    SmallVector<Value, 8> outputs;
    SmallVector<BlockArgument, 8> outputArgs;
    SmallVector<Location, 8> outputLocs;
    SmallVector<Value, 8> params;
    SmallVector<BlockArgument, 8> paramArgs;
    SmallVector<Location, 8> paramLocs;
    for (auto arg : task.getBody().getArguments()) {
      auto operand = task.getOperand(arg.getArgNumber());

      if (operand.getType().isa<MemRefType, StreamType>()) {
        if (llvm::any_of(arg.getUsers(),
                         [](Operation *user) { return isa<TaskOp>(user); }))
          return failure();
        else if (llvm::any_of(arg.getUses(), [](OpOperand &use) {
                   return isWritten(use) || isa<YieldOp>(use.getOwner());
                 })) {
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
    auto nodeBlock = rewriter.createBlock(&node.getBody());

    auto &nodeOps = nodeBlock->getOperations();
    auto &taskOps = task.getBody().front().getOperations();
    nodeOps.splice(nodeOps.begin(), taskOps, taskOps.begin(),
                   std::prev(taskOps.end()));

    auto newInputArgs = nodeBlock->addArguments(ValueRange(inputs), inputLocs);
    for (auto t : llvm::zip(inputArgs, newInputArgs))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

    auto newOutputArgs =
        node.getBody().addArguments(ValueRange(outputs), outputLocs);
    for (auto t : llvm::zip(outputArgs, newOutputArgs))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

    auto newParamArgs = nodeBlock->addArguments(ValueRange(params), paramLocs);
    for (auto t : llvm::zip(paramArgs, newParamArgs))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

    rewriter.replaceOp(task, outputsToReplace);
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
    rewriter.replaceOpWithNewOp<BufferOp>(op, op.getType());
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
      rewriter.inlineRegionBefore(schedule.getBody(), newSchedule.getBody(),
                                  newSchedule.getBody().end());

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
// Pass entry
//===----------------------------------------------------------------------===//

namespace {
struct LowerDataflow : public LowerDataflowBase<LowerDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<NodeConversionPattern>(context);
    patterns.add<BufferConversionPattern<memref::AllocOp>>(context);
    patterns.add<BufferConversionPattern<memref::AllocaOp>>(context);
    patterns.add<ScheduleOutputRemovePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLowerDataflowPass() {
  return std::make_unique<LowerDataflow>();
}
