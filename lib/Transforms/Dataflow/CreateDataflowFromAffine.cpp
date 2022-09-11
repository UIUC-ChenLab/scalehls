//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

/// Fuse the given operations into a new task. The new task will be created
/// before the first operation and each operation will be inserted in order.
/// This method always succeeds even if the resulting IR is invalid.
static TaskOp fuseOps(ArrayRef<Operation *> ops, PatternRewriter &rewriter) {
  assert(!ops.empty() && "must fuse at least one op");
  SmallPtrSet<Operation *, 4> opsSet(ops.begin(), ops.end());

  llvm::SetVector<Value> inputValues;
  llvm::SetVector<Value> outputValues;
  for (auto op : ops) {
    // Collect input values.
    for (auto operand : op->getOperands())
      if (!opsSet.count(operand.getDefiningOp()))
        inputValues.insert(operand);

    // Collect input values of sub-regions through liveness analysis.
    if (op->getNumRegions() != 0) {
      auto liveness = Liveness(op);
      op->walk([&](Block *block) {
        for (auto livein : liveness.getLiveIn(block))
          if (auto arg = livein.dyn_cast<BlockArgument>()) {
            if (!op->isAncestor(arg.getParentBlock()->getParentOp()))
              inputValues.insert(livein);
          } else if (!opsSet.count(livein.getDefiningOp()) &&
                     !op->isAncestor(livein.getDefiningOp()))
            inputValues.insert(livein);
      });
    }

    // Collect output values. This is not sufficient and may lead to empty-used
    // outputs, which will be removed furing cononicalization.
    for (auto result : op->getResults())
      if (llvm::any_of(result.getUsers(),
                       [&](Operation *user) { return !opsSet.count(user); }))
        outputValues.insert(result);
  }

  // Create new graph task with all inputs and outputs.
  auto loc = rewriter.getUnknownLoc();
  rewriter.setInsertionPoint(ops.front());
  auto task = rewriter.create<TaskOp>(
      loc, ValueRange(outputValues.getArrayRef()), inputValues.getArrayRef());
  auto taskBlock = rewriter.createBlock(&task.body());

  // Move each targeted op into the new graph task.
  rewriter.setInsertionPointToEnd(taskBlock);
  auto yield = rewriter.create<YieldOp>(loc, outputValues.getArrayRef());
  for (auto op : ops)
    op->moveBefore(yield);

  // Replace internal input uses with task arguments.
  for (auto input : inputValues) {
    auto arg = taskBlock->addArgument(input.getType(), input.getLoc());
    input.replaceUsesWithIf(arg, [&](OpOperand &use) {
      return task->isProperAncestor(use.getOwner());
    });
  }

  // Replace external output uses with the task results.
  unsigned idx = 0;
  for (auto output : outputValues) {
    output.replaceUsesWithIf(task.getResult(idx++), [&](OpOperand &use) {
      return !task->isProperAncestor(use.getOwner());
    });
  }
  return task;
}

namespace {
/// Wrap operations in the front block into dataflow nodes based on heuristic if
/// they have not. FuncOp and AffineForOp are supported.
template <typename OpType>
struct DataflowNodeCreatePattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType target,
                                PatternRewriter &rewriter) const override {
    if (!llvm::hasSingleElement(target.getRegion()))
      return target.emitOpError("target region has multiple blocks");
    auto &block = target.getRegion().front();

    // Collect all constants in the block.
    SmallVector<Operation *, 16> constants;
    block.walk([&](arith::ConstantOp op) { constants.push_back(op); });

    // Localize constants to each of its use.
    for (auto constant : constants) {
      for (auto &use : llvm::make_early_inc_range(constant->getUses())) {
        rewriter.setInsertionPoint(use.getOwner());
        auto cloneConstant = cast<arith::ConstantOp>(rewriter.clone(*constant));
        use.set(cloneConstant.getResult());
      }
      constant->erase();
    }

    // Fuse operations into dataflow nodes. TODO: We need more case study to
    // figure out any other operations need to be separately handled. For
    // example, how to handle AffineIfOp?
    SmallVector<Operation *, 4> opsToFuse;
    for (auto &op : llvm::make_early_inc_range(block)) {
      if (isa<tosa::TosaDialect, tensor::TensorDialect, linalg::LinalgDialect,
              bufferization::BufferizationDialect>(op.getDialect()) ||
          isa<func::CallOp, TaskOp, NodeOp>(op)) {
        return failure();

      } else if (isa<BufferOp, ConstBufferOp, arith::ConstantOp,
                     memref::AllocOp, memref::AllocaOp>(op)) {
        // Constant or memory operations are moved to the begining and skipped.
        op.moveBefore(&block, block.begin());

      } else if (isa<AffineForOp, scf::ForOp>(op)) {
        // We always take loop as root operation and fuse all the collected
        // operations so far.
        opsToFuse.push_back(&op);
        fuseOps(opsToFuse, rewriter);
        opsToFuse.clear();

      } else if (&op == block.getTerminator()) {
        if (opsToFuse.empty())
          continue;
        fuseOps(opsToFuse, rewriter);
        opsToFuse.clear();

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

    mlir::RewritePatternSet patterns(context);
    patterns.add<DataflowNodeCreatePattern<func::FuncOp>>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));

    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);

    // Create loop dataflow to each innermost loop.
    patterns.clear();
    patterns.add<DataflowNodeCreatePattern<mlir::AffineForOp>>(context);
    FrozenRewritePatternSet frozenPatterns(std::move(patterns));
    for (auto &band : llvm::reverse(targetBands))
      (void)applyOpPatternsAndFold(band.back(), frozenPatterns);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromAffinePass() {
  return std::make_unique<CreateDataflowFromAffine>();
}
