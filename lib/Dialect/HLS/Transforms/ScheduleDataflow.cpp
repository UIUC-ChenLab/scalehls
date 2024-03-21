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

/// Wrap the operations in the block with schedule op.
static ScheduleOp scheduleBlock(StringRef name, Block *block,
                                PatternRewriter &rewriter) {
  if (!block->getOps<ScheduleOp>().empty() ||
      !isa<func::FuncOp, affine::AffineForOp, scf::ForOp>(block->getParentOp()))
    return nullptr;

  auto loc = rewriter.getUnknownLoc();
  ValueRange returnValues(block->getTerminator()->getOperands());
  rewriter.setInsertionPointToStart(block);
  auto schedule = rewriter.create<ScheduleOp>(loc, returnValues);

  auto &scheduleBlock = schedule.getBody().emplaceBlock();
  rewriter.setInsertionPointToEnd(&scheduleBlock);
  rewriter.create<YieldOp>(loc, returnValues);

  auto &scheduleOps = scheduleBlock.getOperations();
  auto &parentOps = block->getOperations();
  scheduleOps.splice(scheduleBlock.begin(), parentOps,
                     std::next(parentOps.begin()), std::prev(parentOps.end()));
  block->getTerminator()->setOperands(schedule.getResults());

  unsigned taskId = 0;
  for (auto &op : llvm::make_early_inc_range(schedule.getOps())) {
    assert(!isa<hls::ITensorReadFullTensorOp>(op) &&
           !isa<hls::ITensorWriteFullTensorOp>(op) &&
           !isa<hls::ITensorBufferOp>(op) &&
           "itensor DMA op must be materialized before being scheduleed");
    assert(!isa<tensor::TensorDialect>(op.getDialect()) &&
           "tensor op must be bufferized before being scheduleed");
    if (isa<linalg::LinalgOp, affine::AffineForOp, scf::ForOp>(op)) {
      auto task = fuseOpsIntoTask({&op}, rewriter);
      std::string taskName = name.str() + "_" + std::to_string(taskId++);
      op.setAttr(taskName, rewriter.getUnitAttr());
      task->setAttr(taskName, rewriter.getUnitAttr());
    }
  }
  return schedule;
}

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
