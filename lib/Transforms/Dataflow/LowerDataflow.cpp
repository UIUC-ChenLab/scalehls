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

namespace {
struct LowerDispatchToSchedule : public OpRewritePattern<DispatchOp> {
  using OpRewritePattern<DispatchOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DispatchOp dispatch,
                                PatternRewriter &rewriter) const override {
    if (dispatch.getNumResults())
      return dispatch.emitOpError("should not yield any results");

    auto isInDispatch = [&](OpOperand &use) {
      return dispatch->isAncestor(use.getOwner());
    };

    SmallVector<Value, 8> inputs;
    SmallVector<Location, 8> inputLocs;

    auto liveins = Liveness(dispatch).getLiveIn(&dispatch.getBody().front());
    for (auto livein : liveins) {
      if (dispatch.getBody().isAncestor(livein.getParentRegion()))
        continue;
      inputs.push_back(livein);
      inputLocs.push_back(livein.getLoc());
    }

    rewriter.setInsertionPoint(dispatch);
    auto schedule =
        rewriter.create<ScheduleOp>(rewriter.getUnknownLoc(), inputs);
    auto scheduleBlock = rewriter.createBlock(&schedule.getBody());

    auto inputArgs = scheduleBlock->addArguments(ValueRange(inputs), inputLocs);
    for (auto t : llvm::zip(inputs, inputArgs))
      std::get<0>(t).replaceUsesWithIf(std::get<1>(t), isInDispatch);

    auto &scheduleOps = scheduleBlock->getOperations();
    auto &dispatchOps = dispatch.getBody().front().getOperations();
    scheduleOps.splice(scheduleOps.begin(), dispatchOps, dispatchOps.begin(),
                       std::prev(dispatchOps.end()));

    rewriter.eraseOp(dispatch);
    return success();
  }
};
} // namespace

namespace {
struct LowerTaskToNode : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    if (task.getNumResults())
      return task.emitOpError("should not yield any results");

    auto isInTask = [&](OpOperand &use) {
      return task->isAncestor(use.getOwner());
    };

    SmallVector<Value, 8> inputs;
    SmallVector<Location, 8> inputLocs;
    SmallVector<Value, 8> outputs;
    SmallVector<Location, 8> outputLocs;
    SmallVector<Value, 8> params;
    SmallVector<Location, 8> paramLocs;

    auto liveins = Liveness(task).getLiveIn(&task.getBody().front());
    for (auto livein : liveins) {
      if (task.getBody().isAncestor(livein.getParentRegion()))
        continue;

      if (livein.getType().isa<MemRefType, StreamType>()) {
        auto uses = llvm::make_filter_range(livein.getUses(), isInTask);
        if (llvm::any_of(uses, [](OpOperand &use) { return isWritten(use); })) {
          outputs.push_back(livein);
          outputLocs.push_back(livein.getLoc());
        } else {
          inputs.push_back(livein);
          inputLocs.push_back(livein.getLoc());
        }
      } else {
        params.push_back(livein);
        paramLocs.push_back(livein.getLoc());
      }
    }

    rewriter.setInsertionPoint(task);
    auto node = rewriter.create<NodeOp>(rewriter.getUnknownLoc(), inputs,
                                        outputs, params);
    auto nodeBlock = rewriter.createBlock(&node.getBody());

    auto inputArgs = nodeBlock->addArguments(ValueRange(inputs), inputLocs);
    for (auto t : llvm::zip(inputs, inputArgs))
      std::get<0>(t).replaceUsesWithIf(std::get<1>(t), isInTask);

    auto outputArgs =
        node.getBody().addArguments(ValueRange(outputs), outputLocs);
    for (auto t : llvm::zip(outputs, outputArgs))
      std::get<0>(t).replaceUsesWithIf(std::get<1>(t), isInTask);

    auto paramArgs = nodeBlock->addArguments(ValueRange(params), paramLocs);
    for (auto t : llvm::zip(params, paramArgs))
      std::get<0>(t).replaceUsesWithIf(std::get<1>(t), isInTask);

    auto &nodeOps = nodeBlock->getOperations();
    auto &taskOps = task.getBody().front().getOperations();
    nodeOps.splice(nodeOps.begin(), taskOps, taskOps.begin(),
                   std::prev(taskOps.end()));

    rewriter.eraseOp(task);
    return success();
  }
};
} // namespace

namespace {
struct SplitScheduleExternalBufferAccess : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    auto &scheduleBody = schedule.getBody();
    SmallVector<Value, 16> newOperands(schedule.getOperands());
    bool hasChanged = false;

    for (auto arg : llvm::make_early_inc_range(scheduleBody.getArguments())) {
      // If the buffer is not an external buffer or has zero or one node users,
      // we have nothing to do.
      auto uses = llvm::make_filter_range(arg.getUses(), [&](auto &use) {
        return isa<NodeOp>(use.getOwner());
      });
      if (!isExternalBuffer(arg) || uses.empty() ||
          llvm::hasSingleElement(uses))
        continue;

      // Add a new argument and new input for each additional uses.
      for (auto &use : llvm::make_early_inc_range(llvm::drop_begin(uses))) {
        newOperands.push_back(newOperands[arg.getArgNumber()]);
        auto newArg = scheduleBody.addArgument(arg.getType(), arg.getLoc());
        use.set(newArg);
        hasChanged = true;
      }
    }

    if (hasChanged) {
      auto newSchedule =
          rewriter.create<ScheduleOp>(schedule.getLoc(), newOperands);
      rewriter.inlineRegionBefore(scheduleBody, newSchedule.getBody(),
                                  newSchedule.getBody().end());
      rewriter.eraseOp(schedule);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct SplitNodeExternalBufferAccess : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    auto &nodeBody = node.getBody();
    SmallVector<Value, 16> newInputs(node.getInputs());
    SmallVector<Value, 16> newOutputs(node.getOutputs());
    auto numInputs = node.getNumInputs();
    auto numOutputs = node.getNumOutputs();
    bool hasChanged = false;

    for (auto arg : llvm::make_early_inc_range(node.getInputArgs())) {
      // If the buffer is not an external buffer or has zero or one schedule
      // users, we have nothing to do.
      auto uses = llvm::make_filter_range(arg.getUses(), [&](auto &use) {
        return isa<ScheduleOp>(use.getOwner());
      });
      if (!isExternalBuffer(arg) || uses.empty() ||
          llvm::hasSingleElement(uses))
        continue;

      // Add a new argument and new input for each additional uses.
      for (auto &use : llvm::make_early_inc_range(llvm::drop_begin(uses))) {
        newInputs.push_back(newInputs[arg.getArgNumber()]);
        auto newArg =
            nodeBody.insertArgument(numInputs++, arg.getType(), arg.getLoc());
        use.set(newArg);
        hasChanged = true;
      }
    }

    unsigned argIdx = 0;
    for (auto arg : llvm::make_early_inc_range(node.getOutputArgs())) {
      // If the buffer is not an external buffer or has zero or one schedule
      // users, we have nothing to do.
      auto uses = llvm::make_filter_range(arg.getUses(), [&](auto &use) {
        return isa<ScheduleOp>(use.getOwner());
      });
      if (!isExternalBuffer(arg) || uses.empty() ||
          llvm::hasSingleElement(uses))
        continue;

      // Add a new argument and new input or output for each additional uses
      // apart from the first written use.
      bool outputFlag = false;
      for (auto &use : llvm::make_early_inc_range(uses)) {
        auto useIsWritten = isWritten(use);
        if (useIsWritten && !outputFlag) {
          outputFlag = true;
          continue;
        }
        if (useIsWritten) {
          newOutputs.push_back(newOutputs[argIdx++]);
          auto newArg = nodeBody.insertArgument(numInputs + numOutputs++,
                                                arg.getType(), arg.getLoc());
          use.set(newArg);
        } else {
          newInputs.push_back(newOutputs[argIdx++]);
          auto newArg =
              nodeBody.insertArgument(numInputs++, arg.getType(), arg.getLoc());
          use.set(newArg);
        }
        hasChanged = true;
      }
    }

    if (hasChanged) {
      auto newNode = rewriter.create<NodeOp>(node.getLoc(), newInputs,
                                             newOutputs, node.getParams());
      rewriter.inlineRegionBefore(nodeBody, newNode.getBody(),
                                  newNode.getBody().end());
      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct LowerDataflow : public LowerDataflowBase<LowerDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto builder = OpBuilder(context);

    // Collect all constants in the function and localize them to uses.
    SmallVector<Operation *, 16> constants;
    func.walk([&](arith::ConstantOp op) { constants.push_back(op); });
    for (auto constant : constants) {
      for (auto &use : llvm::make_early_inc_range(constant->getUses())) {
        builder.setInsertionPoint(use.getOwner());
        auto cloneConstant = cast<arith::ConstantOp>(builder.clone(*constant));
        use.set(cloneConstant.getResult());
      }
      constant->erase();
    }

    ConversionTarget target(*context);
    target.addIllegalOp<DispatchOp, TaskOp, YieldOp, memref::GetGlobalOp,
                        memref::AllocOp, memref::AllocaOp>();
    target.addLegalOp<ScheduleOp, NodeOp, ConstBufferOp, BufferOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<LowerDispatchToSchedule>(context);
    patterns.add<LowerTaskToNode>(context);
    populateBufferConversionPatterns(patterns);
    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();

    patterns.clear();
    patterns.add<SplitScheduleExternalBufferAccess>(context);
    patterns.add<SplitNodeExternalBufferAccess>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLowerDataflowPass() {
  return std::make_unique<LowerDataflow>();
}
