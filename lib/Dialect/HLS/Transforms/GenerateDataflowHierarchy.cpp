//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_GENERATEDATAFLOWHIERARCHY
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

static hls::TaskOp wrapOpIntoTask(Operation *op, StringRef taskName,
                                  MutableOperandRange destOperandsMutable,
                                  OpBuilder &builder) {
  auto destOperands = destOperandsMutable.getAsOperandRange();
  builder.setInsertionPoint(op);
  auto task = builder.create<TaskOp>(op->getLoc(), destOperands,
                                     builder.getStringAttr(taskName));
  op->replaceAllUsesWith(task.getResults());

  auto taskBlock = builder.createBlock(
      &task.getBody(), task.getBody().end(), TypeRange(destOperands),
      llvm::map_to_vector(destOperands, [&](Value v) { return v.getLoc(); }));
  for (auto [destOperand, taskBlockArg] :
       llvm::zip(destOperandsMutable, taskBlock->getArguments()))
    destOperand.set(taskBlockArg);

  builder.setInsertionPointToEnd(taskBlock);
  auto yieldOp = builder.create<YieldOp>(op->getLoc(), op->getResults());
  op->moveBefore(yieldOp);
  return task;
}

static LogicalResult generateTasksInBlock(StringRef prefix, Block *block,
                                          OpBuilder &builder) {
  if (!isa<func::FuncOp, scf::ForOp>(block->getParentOp()))
    return block->getParentOp()->emitOpError("expected a FuncOp or a ForOp");

  // Collect all ops that need to be wrapped into tasks.
  SmallVector<std::pair<Operation *, MutableOperandRange>> opsToWrap;
  for (auto &op : *block) {
    if (auto loop = dyn_cast<scf::ForOp>(op)) {
      opsToWrap.push_back({loop, loop.getInitArgsMutable()});

    } else if (auto writeOp = dyn_cast<ITensorWriteLikeOpInterface>(op)) {
      // We only consider itensor with tensor type elements.
      if (isa<TensorType>(writeOp.getDestType().getElementType()))
        opsToWrap.push_back({writeOp, writeOp.getDestMutable()});

    } else if (auto destStyleOp = dyn_cast<DestinationStyleOpInterface>(op)) {
      // Because tensor insertion-like ops will be eliminated in the tensor
      // bufferization pass, we don't need to wrap them into tasks. Also, we
      // don't need to wrap ops that have no destination operands.
      if (destStyleOp.getNumDpsInits() != 0 &&
          !isa<tensor::InsertOp, tensor::InsertSliceOp>(op))
        opsToWrap.push_back({destStyleOp, destStyleOp.getDpsInitsMutable()});
    }
  }

  // Handle cases when there is no op to wrap or only one op to wrap.
  if (opsToWrap.empty())
    return success();
  else if (llvm::hasSingleElement(opsToWrap)) {
    if (auto loop = dyn_cast<scf::ForOp>(opsToWrap.front().first))
      return generateTasksInBlock(prefix, loop.getBody(), builder);
    else
      return success();
  }

  // Generate tasks for all ops that need to be wrapped.
  unsigned taskId = 0;
  for (auto [op, destOperands] : opsToWrap) {
    std::string taskName = prefix.str() + "_" + std::to_string(taskId++);
    if (auto loop = dyn_cast<scf::ForOp>(op))
      if (failed(generateTasksInBlock(taskName, loop.getBody(), builder)))
        return failure();
    wrapOpIntoTask(op, taskName, destOperands, builder);
  }
  return success();
}

namespace {
struct GenerateDataflowHierarchy
    : public hls::impl::GenerateDataflowHierarchyBase<
          GenerateDataflowHierarchy> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);
    if (failed(generateTasksInBlock(func.getName(), &func.front(), builder))) {
      signalPassFailure();
    }
  }
};
} // namespace
