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

namespace {
/// Wrap operations in the front block into dataflow nodes based on heuristic if
/// they have not.
struct TaskCreatePattern : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    if (llvm::any_of(schedule.getOps(), [](Operation &op) {
          return isa<bufferization::BufferizationDialect, tosa::TosaDialect,
                     tensor::TensorDialect, linalg::LinalgDialect>(
                     op.getDialect()) ||
                 isa<func::CallOp, TaskOp, NodeOp, ScheduleOp>(op);
        }))
      return failure();
    auto &block = schedule.getRegion().front();

    // Fuse operations into dataflow nodes. TODO: We need more case study to
    // figure out any other operations need to be separately handled. For
    // example, how to handle AffineIfOp?
    SmallVector<Operation *, 4> opsToFuse;
    unsigned taskIdx = 0;
    for (auto &op : llvm::make_early_inc_range(block)) {
      if (isa<BufferOp, ConstBufferOp, memref::AllocOp, memref::AllocaOp>(op)) {
        // Memories are moved to the begining and skipped.
        op.moveBefore(&block, block.begin());

      } else if (isa<AffineForOp, scf::ForOp>(op)) {
        // We always take loop as root operation and fuse all the collected
        // operations so far.
        opsToFuse.push_back(&op);
        fuseOpsIntoTask(opsToFuse, rewriter);
        opsToFuse.clear();
        taskIdx++;

      } else if (&op == block.getTerminator()) {
        // If the block will only generate one task, stop it.
        if (opsToFuse.empty() || taskIdx == 0)
          continue;
        fuseOpsIntoTask(opsToFuse, rewriter);
        opsToFuse.clear();
        taskIdx++;

      } else {
        // Otherwise, we push back the current operation to the list.
        opsToFuse.push_back(&op);
      }
    }
    return success();
  }
};
} // namespace

namespace {
struct CreateDataflowFromAffine
    : public CreateDataflowFromAffineBase<CreateDataflowFromAffine> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto builder = OpBuilder(context);

    // Generate dataflow schedules.
    wrapWithSchedule(&func.front());
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);
    for (auto &band : llvm::reverse(targetBands))
      wrapWithSchedule(band.back().getBody());

    // Collect all constants in the block and localize them to uses.
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

    mlir::RewritePatternSet patterns(context);
    patterns.add<TaskCreatePattern>(context);
    auto frozenPatterns = FrozenRewritePatternSet(std::move(patterns));
    func.walk([&](ScheduleOp schedule) {
      (void)applyOpPatternsAndFold(schedule, frozenPatterns);
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromAffinePass() {
  return std::make_unique<CreateDataflowFromAffine>();
}
