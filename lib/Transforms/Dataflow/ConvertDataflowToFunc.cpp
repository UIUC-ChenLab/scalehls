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
      else if (auto loop =
                   dyn_cast<mlir::AffineForOp>(schedule->getParentOp())) {
        // If the schedule is located insided of a loop nest, try to coalesce
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

    // Inline the contents of the dataflow node.
    rewriter.inlineRegionBefore(node.getBodyRegion(), subFunc.getBody(),
                                subFunc.end());
    rewriter.setInsertionPointToEnd(&subFunc.front());
    rewriter.create<func::ReturnOp>(rewriter.getUnknownLoc());

    // Replace original with a function call.
    rewriter.setInsertionPoint(node);
    rewriter.replaceOpWithNewOp<func::CallOp>(node, subFunc,
                                              node.getOperands());
    // setFuncDirective(subFunc, false, 1, true);
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
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      ConversionTarget target(*context);
      target.addIllegalOp<ScheduleOp, NodeOp>();
      target.addLegalOp<func::FuncOp, func::ReturnOp, func::CallOp>();

      unsigned nodeIdx = 0;
      mlir::RewritePatternSet patterns(context);
      patterns.add<InlineSchedule>(context);
      patterns.add<ConvertNodeToFunc>(context, func.getName(), nodeIdx);
      if (failed(applyPartialConversion(func, target, std::move(patterns))))
        return signalPassFailure();
    }

    // Remove memref global operations.
    for (auto global :
         llvm::make_early_inc_range(module.getOps<memref::GlobalOp>()))
      global.erase();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertDataflowToFuncPass() {
  return std::make_unique<ConvertDataflowToFunc>();
}
