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

hls::TaskOp wrapOpIntoTask(Operation *op, StringRef taskName,
                           ValueRange destOperands, OpBuilder &builder) {
  auto destTypes = TypeRange(destOperands);

  builder.setInsertionPoint(op);
  auto task = builder.create<TaskOp>(op->getLoc(), destTypes, destOperands);
  task->setAttr(taskName, builder.getUnitAttr());
  auto taskBlock = builder.createBlock(
      &task.getBody(), task.getBody().end(), destTypes,
      llvm::map_to_vector(destOperands, [&](Value v) { return v.getLoc(); }));
  IRMapping mapper;
  for (auto [destOperand, taskBlockArg] :
       llvm::zip(destOperands, taskBlock->getArguments()))
    mapper.map(destOperand, taskBlockArg);

  builder.setInsertionPointToStart(taskBlock);
  auto newOp = builder.clone(*op, mapper);
  builder.create<YieldOp>(op->getLoc(), newOp->getResults());
  op->replaceAllUsesWith(task.getResults());
  op->erase();
  return task;
}

static LogicalResult scheduleBlock(StringRef prefix, Block *block,
                                   OpBuilder &builder) {
  if (!isa<func::FuncOp, scf::ForOp>(block->getParentOp()))
    return block->getParentOp()->emitOpError("expected a FuncOp or a ForOp");

  unsigned taskId = 0;
  for (auto &op : llvm::make_early_inc_range(block->getOperations())) {
    std::string taskName = prefix.str() + "_" + std::to_string(taskId);

    ValueRange destOperands;

    if (auto loop = dyn_cast<scf::ForOp>(op)) {
      if (failed(scheduleBlock(taskName, loop.getBody(), builder)))
        return failure();
      destOperands = loop.getInitArgs();
    } else if (isa<tensor::InsertOp, tensor::InsertSliceOp,
                   tensor::ParallelInsertSliceOp>(op)) {
      continue;
    } else if (auto destStyleOp = dyn_cast<DestinationStyleOpInterface>(op)) {
      destOperands = destStyleOp.getDpsInits();
    } else if (auto writeOp = dyn_cast<ITensorWriteLikeOpInterface>(op)) {
      destOperands = writeOp.getDest();
    } else
      continue;

    wrapOpIntoTask(&op, taskName, destOperands, builder);
    taskId++;
  }
  return success();
}

namespace {
struct ScheduleDataflow : public ScheduleDataflowBase<ScheduleDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);
    if (failed(scheduleBlock(func.getName(), &func.front(), builder))) {
      signalPassFailure();
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createScheduleDataflowPass() {
  return std::make_unique<ScheduleDataflow>();
}
