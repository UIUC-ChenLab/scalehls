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
    SmallVector<Type, 8> inputTypes;
    SmallVector<Location, 8> inputLocs;

    auto liveins = Liveness(dispatch).getLiveIn(&dispatch.getBody().front());
    for (auto livein : liveins) {
      if (dispatch.getBody().isAncestor(livein.getParentRegion()))
        continue;
      inputs.push_back(livein);
      inputTypes.push_back(livein.getType());
      inputLocs.push_back(livein.getLoc());
    }

    rewriter.setInsertionPoint(dispatch);
    auto schedule =
        rewriter.create<ScheduleOp>(rewriter.getUnknownLoc(), inputs);
    auto scheduleBlock = rewriter.createBlock(&schedule.getBody());

    auto inputArgs =
        scheduleBlock->addArguments(TypeRange(inputTypes), inputLocs);
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
    SmallVector<Type, 8> inputTypes;
    SmallVector<Location, 8> inputLocs;
    SmallVector<Value, 8> outputs;
    SmallVector<Type, 8> outputTypes;
    SmallVector<Location, 8> outputLocs;
    SmallVector<Value, 8> params;
    SmallVector<Type, 8> paramTypes;
    SmallVector<Location, 8> paramLocs;

    auto liveins = Liveness(task).getLiveIn(&task.getBody().front());
    for (auto livein : liveins) {
      if (task.getBody().isAncestor(livein.getParentRegion()))
        continue;

      if (livein.getType().isa<MemRefType, StreamType>()) {
        auto uses = llvm::make_filter_range(livein.getUses(), isInTask);
        if (llvm::any_of(uses, [](OpOperand &use) { return isWritten(use); })) {
          outputs.push_back(livein);
          outputTypes.push_back(livein.getType());
          outputLocs.push_back(livein.getLoc());
        } else {
          inputs.push_back(livein);
          inputTypes.push_back(livein.getType());
          inputLocs.push_back(livein.getLoc());
        }
      } else {
        params.push_back(livein);
        paramTypes.push_back(livein.getType());
        paramLocs.push_back(livein.getLoc());
      }
    }

    rewriter.setInsertionPoint(task);
    auto node = rewriter.create<NodeOp>(rewriter.getUnknownLoc(), inputs,
                                        outputs, params);
    auto nodeBlock = rewriter.createBlock(&node.getBody());

    auto inputArgs = nodeBlock->addArguments(TypeRange(inputTypes), inputLocs);
    for (auto t : llvm::zip(inputs, inputArgs))
      std::get<0>(t).replaceUsesWithIf(std::get<1>(t), isInTask);

    auto outputArgs =
        node.getBody().addArguments(TypeRange(outputTypes), outputLocs);
    for (auto t : llvm::zip(outputs, outputArgs))
      std::get<0>(t).replaceUsesWithIf(std::get<1>(t), isInTask);

    auto paramArgs = nodeBlock->addArguments(TypeRange(paramTypes), paramLocs);
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
struct LowerDataflow : public LowerDataflowBase<LowerDataflow> {
  LowerDataflow() = default;
  explicit LowerDataflow(bool argSplitExternalAccess) {
    splitExternalAccess = argSplitExternalAccess;
  }

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
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createLowerDataflowPass(bool splitExternalAccess) {
  return std::make_unique<LowerDataflow>(splitExternalAccess);
}
