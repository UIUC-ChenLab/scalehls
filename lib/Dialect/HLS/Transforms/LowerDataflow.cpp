//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ConvertDispatchToSchedule : public OpRewritePattern<DispatchOp> {
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
struct ConvertTaskToNode : public OpRewritePattern<TaskOp> {
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
    node->setAttrs(task->getAttrs());
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
struct ConvertConstantToConstBuffer
    : public OpRewritePattern<bufferization::ToMemrefOp> {
  using OpRewritePattern<bufferization::ToMemrefOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(bufferization::ToMemrefOp op,
                                PatternRewriter &rewriter) const override {
    if (auto constant = op.getTensor().getDefiningOp<arith::ConstantOp>()) {
      rewriter.replaceOpWithNewOp<ConstBufferOp>(
          op, op.getType(), constant.getValue().cast<ElementsAttr>());
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

    // Convert dispatch, task, and to_memref operations.
    ConversionTarget target(*context);
    target.addIllegalOp<DispatchOp, TaskOp, YieldOp>();
    target.addLegalOp<ScheduleOp, NodeOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertDispatchToSchedule>(context);
    patterns.add<ConvertTaskToNode>(context);
    // patterns.add<ConvertConstantToConstBuffer>(context);
    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createLowerDataflowPass() {
  return std::make_unique<LowerDataflow>();
}
