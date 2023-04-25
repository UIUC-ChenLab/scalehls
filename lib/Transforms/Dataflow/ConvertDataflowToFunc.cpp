//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct SplitScheduleExternalBufferAccess : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    auto &scheduleBody = schedule.getBody();
    SmallVector<Value, 16> newOperands(schedule.getOperands());
    bool hasChanged = false;

    SmallVector<BlockArgument, 16> args(scheduleBody.getArguments());
    for (auto arg : args) {
      // If the buffer is not an external buffer or has zero or one node users,
      // we have nothing to do.
      auto uses = llvm::make_filter_range(arg.getUses(), [&](auto &use) {
        return isa<NodeOp>(use.getOwner());
      });
      if (!isExtBuffer(arg) || uses.empty() || llvm::hasSingleElement(uses))
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
      auto newSchedule = rewriter.create<ScheduleOp>(
          schedule.getLoc(), newOperands, schedule.getIsLegalAttr());
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

    SmallVector<BlockArgument, 16> inputArgs(node.getInputArgs());
    SmallVector<BlockArgument, 16> outputArgs(node.getOutputArgs());
    for (auto arg : inputArgs) {
      // If the buffer is not an external buffer or has zero or one schedule
      // users, we have nothing to do.
      auto uses = llvm::make_filter_range(arg.getUses(), [&](auto &use) {
        return isa<ScheduleOp>(use.getOwner());
      });
      if (!isExtBuffer(arg) || uses.empty() || llvm::hasSingleElement(uses))
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

    for (auto arg : llvm::enumerate(outputArgs)) {
      // If the buffer is not an external buffer or has zero or one schedule
      // users, we have nothing to do.
      auto uses =
          llvm::make_filter_range(arg.value().getUses(), [&](auto &use) {
            return isa<ScheduleOp>(use.getOwner());
          });
      if (!isExtBuffer(arg.value()) || uses.empty() ||
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
          newOutputs.push_back(newOutputs[arg.index()]);
          auto newArg = nodeBody.insertArgument(numInputs + numOutputs++,
                                                arg.value().getType(),
                                                arg.value().getLoc());
          use.set(newArg);
        } else {
          newInputs.push_back(newOutputs[arg.index()]);
          auto newArg = nodeBody.insertArgument(
              numInputs++, arg.value().getType(), arg.value().getLoc());
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
struct InlineSchedule : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    auto &scheduleOps = schedule.getBody().front().getOperations();
    auto &parentOps = schedule->getBlock()->getOperations();
    parentOps.splice(schedule->getIterator(), scheduleOps);

    for (auto t :
         llvm::zip(schedule.getBody().getArguments(), schedule.getOperands()))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

    if (schedule.getIsLegal()) {
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
    }
    rewriter.eraseOp(schedule);
    return success();
  }
};
} // namespace

namespace {
struct ConvertNodeToFunc : public OpRewritePattern<NodeOp> {
  ConvertNodeToFunc(MLIRContext *context, StringRef prefix, unsigned &nodeIdx)
      : OpRewritePattern<NodeOp>(context), prefix(prefix), nodeIdx(nodeIdx) {}

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    // Create a new sub-function.
    rewriter.setInsertionPoint(node->getParentOfType<func::FuncOp>());
    auto subFunc = rewriter.create<func::FuncOp>(
        node.getLoc(), prefix.str() + "_node" + std::to_string(nodeIdx++),
        rewriter.getFunctionType(node.getOperandTypes(), TypeRange()));

    // FIXME: A better method to judge whether to inline the node.
    if (!node.hasHierarchy() &&
        llvm::hasSingleElement(node.getOps<AffineForOp>()))
      subFunc->setAttr("inline", rewriter.getUnitAttr());

    // Inline the contents of the dataflow node.
    rewriter.inlineRegionBefore(node.getBodyRegion(), subFunc.getBody(),
                                subFunc.end());
    rewriter.setInsertionPointToEnd(&subFunc.front());
    rewriter.create<func::ReturnOp>(rewriter.getUnknownLoc());

    // Replace original with a function call.
    rewriter.setInsertionPoint(node);
    rewriter.replaceOpWithNewOp<func::CallOp>(node, subFunc,
                                              node.getOperands());
    return success();
  }

private:
  StringRef prefix;
  unsigned &nodeIdx;
};
} // namespace

namespace {
struct ConvertDataflowToFunc
    : public ConvertDataflowToFuncBase<ConvertDataflowToFunc> {
  ConvertDataflowToFunc() = default;
  explicit ConvertDataflowToFunc(bool argSplitExternalAccess) {
    splitExternalAccess = argSplitExternalAccess;
  }

  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    if (splitExternalAccess.getValue()) {
      mlir::RewritePatternSet patterns(context);
      patterns.add<SplitScheduleExternalBufferAccess>(context);
      patterns.add<SplitNodeExternalBufferAccess>(context);
      (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
    }

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      ConversionTarget target(*context);
      target.addIllegalOp<ScheduleOp, NodeOp>();
      target.addLegalOp<func::FuncOp, func::ReturnOp, func::CallOp>();

      unsigned nodeIdx = 0;
      mlir::RewritePatternSet patterns(context);
      patterns.add<InlineSchedule>(context);
      patterns.add<ConvertNodeToFunc>(context, func.getName(), nodeIdx);
      (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
      // if (failed(applyPartialConversion(func, target, std::move(patterns))))
      //   return signalPassFailure();
    }

    // Remove memref global operations.
    for (auto global :
         llvm::make_early_inc_range(module.getOps<memref::GlobalOp>()))
      global.erase();
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createConvertDataflowToFuncPass(bool splitExternalAccess) {
  return std::make_unique<ConvertDataflowToFunc>(splitExternalAccess);
}
