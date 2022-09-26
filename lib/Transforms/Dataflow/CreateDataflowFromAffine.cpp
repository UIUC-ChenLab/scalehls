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
struct TaskPartition : public OpRewritePattern<DispatchOp> {
  using OpRewritePattern<DispatchOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DispatchOp dispatch,
                                PatternRewriter &rewriter) const override {
    if (llvm::any_of(dispatch.getOps(), [](Operation &op) {
          return isa<bufferization::BufferizationDialect, tosa::TosaDialect,
                     tensor::TensorDialect, linalg::LinalgDialect>(
                     op.getDialect()) ||
                 isa<func::CallOp, DispatchOp, TaskOp, ScheduleOp, NodeOp>(op);
        }))
      return failure();
    auto &block = dispatch.getRegion().front();

    // Fuse operations into dataflow tasks. TODO: We need more case study to
    // figure out any other operations need to be separately handled. For
    // example, how to handle AffineIfOp?
    SmallVector<Operation *, 4> opsToFuse;
    unsigned taskIdx = 0;
    for (auto &op : llvm::make_early_inc_range(block)) {
      if (hasEffect<MemoryEffects::Allocate>(&op)) {
        // Memory allocs are moved to the begining and skipped.
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

    dispatchBlock(&func.front());
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);
    for (auto &band : llvm::reverse(targetBands))
      dispatchBlock(band.back().getBody());

    mlir::RewritePatternSet patterns(context);
    patterns.add<TaskPartition>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromAffinePass() {
  return std::make_unique<CreateDataflowFromAffine>();
}
