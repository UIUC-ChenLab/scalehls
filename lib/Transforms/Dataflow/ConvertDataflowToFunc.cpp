//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ScheduleConversionPattern : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    auto &scheduleOps = schedule.getBody()->getOperations();
    auto &parentOps = schedule->getBlock()->getOperations();
    parentOps.splice(schedule->getIterator(), scheduleOps, scheduleOps.begin(),
                     std::prev(scheduleOps.end()));

    if (schedule.isLegal()) {
      if (auto func = dyn_cast<func::FuncOp>(schedule->getParentOp()))
        setFuncDirective(func, /*pipeline=*/false, /*targetInterval=*/1,
                         /*dataflow=*/true);
      else if (auto loop = dyn_cast<mlir::AffineForOp>(schedule->getParentOp()))
        setLoopDirective(loop, /*pipeline=*/false, /*targetII=*/1,
                         /*dataflow=*/true, /*flattern=*/false);
    }
    rewriter.replaceOp(schedule, schedule.getReturnOp()->getOperands());
    return success();
  }
};
} // namespace

namespace {
struct TaskConversionPattern : public OpRewritePattern<TaskOp> {
  TaskConversionPattern(MLIRContext *context, StringRef prefix,
                        unsigned &taskIdx)
      : OpRewritePattern<TaskOp>(context), prefix(prefix), taskIdx(taskIdx) {}

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    // Create a new sub-function.
    rewriter.setInsertionPoint(task->getParentOfType<func::FuncOp>());
    auto subFunc = rewriter.create<func::FuncOp>(
        task.getLoc(), prefix.str() + "_task" + std::to_string(taskIdx++),
        rewriter.getFunctionType(task.getOperandTypes(),
                                 task.getResultTypes()));

    // Inline the contents of the dataflow task.
    rewriter.inlineRegionBefore(task.getBodyRegion(), subFunc.getBody(),
                                subFunc.end());

    // Replace original with a function call.
    rewriter.setInsertionPoint(task);
    rewriter.replaceOpWithNewOp<func::CallOp>(task, subFunc,
                                              task.getOperands());
    setFuncDirective(subFunc, false, 1, true);
    return success();
  }

private:
  StringRef prefix;
  unsigned &taskIdx;
};
} // namespace

namespace {
struct YieldConversionPattern : public OpRewritePattern<YieldOp> {
  using OpRewritePattern<YieldOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(YieldOp yield,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<func::ReturnOp>(yield, yield.getOperands());
    return success();
  }
};
} // namespace

namespace {
struct NodeConversionPattern : public OpRewritePattern<NodeOp> {
  NodeConversionPattern(MLIRContext *context, StringRef prefix,
                        unsigned &nodeIdx)
      : OpRewritePattern<NodeOp>(context), prefix(prefix), nodeIdx(nodeIdx) {}

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    // Create a new sub-function.
    rewriter.setInsertionPoint(node->getParentOfType<func::FuncOp>());
    auto subFunc = rewriter.create<func::FuncOp>(
        node.getLoc(), prefix.str() + "_node" + std::to_string(nodeIdx++),
        rewriter.getFunctionType(node.getOperandTypes(), TypeRange()));

    // Inline the contents of the dataflow node.
    rewriter.inlineRegionBefore(node.getBodyRegion(), subFunc.getBody(),
                                subFunc.end());
    rewriter.setInsertionPointToEnd(&subFunc.front());
    rewriter.create<func::ReturnOp>(rewriter.getUnknownLoc());

    // Replace original with a function call.
    rewriter.setInsertionPoint(node);
    rewriter.replaceOpWithNewOp<func::CallOp>(node, subFunc,
                                              node.getOperands());
    setFuncDirective(subFunc, false, 1, true);
    return success();
  }

private:
  StringRef prefix;
  unsigned &nodeIdx;
};
} // namespace

namespace {
struct BufferConversionPattern : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp buffer,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<memref::AllocOp>(buffer, buffer.getType());
    return success();
  }
};
} // namespace

namespace {
struct DemoteConstBufferPattern : public OpRewritePattern<ConstBufferOp> {
  using OpRewritePattern<ConstBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ConstBufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (auto node = buffer->getParentOfType<NodeOp>()) {
      buffer->moveBefore(node);
      SmallVector<Value, 8> inputs(node.inputs());
      inputs.push_back(buffer.memref());

      auto newArg = node.getBody()->insertArgument(
          node.getNumInputs(), buffer.getType(), buffer.getLoc());
      buffer.memref().replaceAllUsesWith(newArg);

      rewriter.setInsertionPoint(node);
      auto newNode =
          rewriter.create<NodeOp>(node.getLoc(), inputs, node.outputs());
      rewriter.inlineRegionBefore(node.body(), newNode.body(),
                                  newNode.body().end());
      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct ConvertDataflowToFunc
    : public ConvertDataflowToFuncBase<ConvertDataflowToFunc> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      // mlir::RewritePatternSet patterns(context);
      // patterns.add<DemoteConstBufferPattern>(context);
      // (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

      ConversionTarget target(*context);
      target.addIllegalOp<ScheduleOp, TaskOp, YieldOp, NodeOp>();
      target.addLegalOp<func::FuncOp, func::ReturnOp, func::CallOp>();

      unsigned nodeIdx = 0;
      mlir::RewritePatternSet patterns(context);
      patterns.add<ScheduleConversionPattern>(context);
      patterns.add<TaskConversionPattern>(context, func.getName(), nodeIdx);
      patterns.add<YieldConversionPattern>(context);
      patterns.add<NodeConversionPattern>(context, func.getName(), nodeIdx);
      // patterns.add<BufferConversionPattern>(context);
      if (failed(applyPartialConversion(func, target, std::move(patterns))))
        return signalPassFailure();
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertDataflowToFuncPass() {
  return std::make_unique<ConvertDataflowToFunc>();
}
