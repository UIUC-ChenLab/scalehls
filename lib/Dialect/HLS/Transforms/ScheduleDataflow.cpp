//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ScheduleFuncOp : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    auto funcSchedule = scheduleBlock(func.getName(), &func.front(), rewriter);
    if (!funcSchedule)
      return failure();

    unsigned loopId;
    func.walk([&](Operation *op) {
      if (isa<affine::AffineForOp, scf::ForOp>(op)) {
        std::string name =
            func.getName().str() + "_loop" + std::to_string(loopId++);
        auto loopBody = &op->getRegion(0).getBlocks().front();
        scheduleBlock(name, loopBody, rewriter);
      }
    });
    return success();
  }
};
} // namespace

namespace {
struct ScheduleDataflow : public ScheduleDataflowBase<ScheduleDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    // Schedule the current function to create the dataflow hierarchy.
    mlir::RewritePatternSet patterns(context);
    patterns.add<ScheduleFuncOp>(context);
    (void)applyOpPatternsAndFold({func}, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScheduleDataflowPass() {
  return std::make_unique<ScheduleDataflow>();
}
