//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;
using namespace affine;

namespace {
struct InlineSchedule : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    auto &scheduleOps = schedule.getBody().front().getOperations();
    auto &parentOps = schedule->getBlock()->getOperations();
    parentOps.splice(schedule->getIterator(), scheduleOps, scheduleOps.begin(),
                     std::prev(scheduleOps.end()));

    if (auto func = dyn_cast<func::FuncOp>(schedule->getParentOp()))
      setFuncDirective(func, /*pipeline=*/false, /*targetInterval=*/1,
                       /*dataflow=*/true);
    else if (auto loop = dyn_cast<AffineForOp>(schedule->getParentOp())) {
      // If the schedule is located inside of a loop nest, try to coalesce
      // them into a flattened loop.
      AffineLoopBand band;
      getLoopBandFromInnermost(loop, band);
      auto dataflowLoop = loop;
      if (isPerfectlyNested(band) && succeeded(coalesceLoops(band)))
        dataflowLoop = band.front();
      setLoopDirective(dataflowLoop, /*pipeline=*/false, /*targetII=*/1,
                       /*dataflow=*/true, /*flattern=*/false);
    }
    rewriter.eraseOp(schedule);
    return success();
  }
};
} // namespace

namespace {
struct ConvertTaskToFunc : public OpRewritePattern<TaskOp> {
  ConvertTaskToFunc(MLIRContext *context, StringRef prefix, unsigned &taskIdx)
      : OpRewritePattern<TaskOp>(context), prefix(prefix), taskIdx(taskIdx) {}

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    if (task.getNumResults())
      return task.emitOpError("should not yield any results");

    // Collect all live-ins of the task.
    SmallVector<Value, 8> operands;
    SmallVector<Location, 8> operandLocs;
    auto liveins = Liveness(task).getLiveIn(&task.getBody().front());
    for (auto livein : liveins) {
      if (task.getBody().isAncestor(livein.getParentRegion()))
        continue;
      operands.push_back(livein);
      operandLocs.push_back(livein.getLoc());
    }

    // Create a new sub-function.
    rewriter.setInsertionPoint(task->getParentOfType<func::FuncOp>());
    auto subFunc = rewriter.create<func::FuncOp>(
        task.getLoc(), prefix.str() + "_task" + std::to_string(taskIdx++),
        rewriter.getFunctionType(TypeRange(operands), TypeRange()));
    subFunc->setAttrs(task->getAttrs());

    // FIXME: A better method to judge whether to inline the node.
    if (!task.hasHierarchy() &&
        llvm::hasSingleElement(task.getOps<AffineForOp>()))
      subFunc->setAttr("inline", rewriter.getUnitAttr());

    // Construct the body and arguments of the sub-function.
    auto subFuncBlock = rewriter.createBlock(&subFunc.getBody());
    auto args = subFuncBlock->addArguments(TypeRange(operands), operandLocs);
    for (auto [operand, arg] : llvm::zip(operands, args))
      operand.replaceUsesWithIf(arg, [&](OpOperand &use) {
        return task->isAncestor(use.getOwner());
      });

    // Inline the task body into the sub-function.
    auto &subFuncOps = subFuncBlock->getOperations();
    auto &taskOps = task.getBody().front().getOperations();
    subFuncOps.splice(subFuncOps.begin(), taskOps, taskOps.begin(),
                      std::prev(taskOps.end()));
    rewriter.setInsertionPointToEnd(subFuncBlock);
    rewriter.create<func::ReturnOp>(task.getYieldOp().getLoc());

    // Replace original with a function call.
    rewriter.setInsertionPoint(task);
    rewriter.replaceOpWithNewOp<func::CallOp>(task, subFunc, operands);
    return success();
  }

private:
  StringRef prefix;
  unsigned &taskIdx;
};
} // namespace

namespace {
struct ConvertDataflowToFunc
    : public ConvertDataflowToFuncBase<ConvertDataflowToFunc> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    auto builder = OpBuilder(context);

    // Collect all constants in the function and localize them to uses.
    SmallVector<Operation *, 16> constants;
    module.walk([&](arith::ConstantOp op) { constants.push_back(op); });
    for (auto constant : constants) {
      for (auto &use : llvm::make_early_inc_range(constant->getUses())) {
        builder.setInsertionPoint(use.getOwner());
        auto cloneConstant = cast<arith::ConstantOp>(builder.clone(*constant));
        use.set(cloneConstant.getResult());
      }
      constant->erase();
    }

    // Fold all stream reassociate ops.
    module.walk([&](hls::StreamReassociateOp reassociateOp) {
      reassociateOp.getResult().replaceAllUsesWith(reassociateOp.getSource());
    });

    // Strip iteration information of all streams.
    module.walk([&](StreamOp stream) {
      stream.getResult().setType(hls::StreamType::get(
          stream.getType().getElementType(), stream.getType().getDepth()));
    });

    // Convert all tasks and schedules into sub-functions.
    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      unsigned taskIdx = 0;
      mlir::RewritePatternSet patterns(context);
      patterns.add<InlineSchedule>(context);
      patterns.add<ConvertTaskToFunc>(context, func.getName(), taskIdx);
      (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createConvertDataflowToFuncPass() {
  return std::make_unique<ConvertDataflowToFunc>();
}
