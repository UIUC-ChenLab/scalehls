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

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_SCHEDULEDATAFLOW
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

static Operation *getParentInBlock(Operation *op, Block *block) {
  while (op->getBlock() != block)
    op = op->getParentOp();
  return op;
}

static void ensureSingleUse(Operation *op, OpBuilder &builder) {
  if (op->use_empty() || op->hasOneUse())
    return;
  builder.setInsertionPoint(op);
  for (auto [idx, result] : llvm::enumerate(op->getResults()))
    for (auto &use : llvm::make_early_inc_range(result.getUses()))
      use.set(builder.clone(*op)->getResult(idx));
  op->erase();
}

static bool isDestinationStyleOp(Operation *op) {
  return isa<hls::TaskOp, scf::ForOp, DestinationStyleOpInterface,
             hls::ITensorWriteLikeOpInterface>(op);
}

/// Wrap a list of operations into a task. The task is created after the last
/// operation in the list. The order of the list is preserved without any
/// domination check. Therefore, this method may lead to incorrect results if
/// the input list is not topologically sorted.
static hls::TaskOp wrapOpsIntoTask(SmallVectorImpl<Operation *> &ops,
                                   StringRef taskName, StringRef taskLocation,
                                   OpBuilder &builder) {
  if (ops.empty())
    return nullptr;
  llvm::SmallDenseSet<Operation *> opSet(ops.begin(), ops.end());

  builder.setInsertionPointAfter(ops.back());
  SmallVector<Value> destOperands;
  SmallVector<Value> results;
  for (auto op : ops)
    if (auto task = dyn_cast<hls::TaskOp>(op))
      if (llvm::any_of(task->getUsers(), [&](Operation *user) {
            return !opSet.count(getParentInBlock(user, builder.getBlock()));
          })) {
        destOperands.append(task.getInits().begin(), task.getInits().end());
        results.append(task.result_begin(), task.result_end());
      }

  auto task = builder.create<hls::TaskOp>(builder.getUnknownLoc(), destOperands,
                                          builder.getStringAttr(taskName),
                                          builder.getStringAttr(taskLocation));
  auto taskBlock = builder.createBlock(
      &task.getBody(), task.getBody().begin(), TypeRange(destOperands),
      llvm::map_to_vector(destOperands, [&](Value destOperand) {
        return destOperand.getLoc();
      }));

  builder.setInsertionPointToEnd(taskBlock);
  auto yieldOp = builder.create<YieldOp>(builder.getUnknownLoc(), results);
  for (auto op : ops)
    op->moveBefore(yieldOp);

  for (auto [destOperand, taskBlockArg] :
       llvm::zip(destOperands, taskBlock->getArguments()))
    destOperand.replaceUsesWithIf(taskBlockArg, [&](OpOperand &use) {
      return task->isProperAncestor(use.getOwner());
    });
  for (auto [result, taskResult] : llvm::zip(results, task.getResults()))
    result.replaceUsesWithIf(taskResult, [&](OpOperand &use) {
      return !task->isProperAncestor(use.getOwner());
    });
  return task;
}

namespace {
struct ScheduleDataflow
    : public hls::impl::ScheduleDataflowBase<ScheduleDataflow> {
  /// Verify that all tasks are located. Meanwhile, all sub-tasks of a task
  /// should have the same location as the task.
  bool checkTaskLocations() {
    for (auto task : getOperation().getOps<hls::TaskOp>()) {
      if (!task.getLocation())
        return false;
      auto verifyResult = task.walk([&](hls::TaskOp subTask) {
        if (subTask.getLocation() != task.getLocation())
          return WalkResult::interrupt();
        return WalkResult::advance();
      });
      if (verifyResult.wasInterrupted())
        return false;
    }
    return true;
  }

  /// A default task grouping strategy that locates tasks based on the semantics
  /// of the input/output types.
  void applyDefaultTaskLocations() {
    for (auto task : getOperation().getOps<hls::TaskOp>()) {
      SmallVector<Value> values(task.getBody().getArguments());
      auto liveIns = task.getLiveIns();
      values.append(liveIns.begin(), liveIns.end());

      unsigned numITensor = 0;
      for (auto value : values)
        numITensor += isa<ITensorType>(value.getType());

      // For now, we locate the task on the "cpu" if there is no input/output
      // with itensor semantics.
      auto location = numITensor ? "pl" : "cpu";
      task.walk([&](hls::TaskOp subTask) {
        if (!subTask.getLocation())
          subTask.setLocation(location);
      });
    }
  }

  /// Infer and apply the locations of tensor/itensor instance ops based on the
  /// locations of the tasks.
  void applyTensorITensorInstanceLocations() {
    SmallVector<hls::MemoryInstanceOpInterface> instances;
    getOperation().walk([&](hls::MemoryInstanceOpInterface instance) {
      instances.push_back(instance);
    });

    for (auto instance : instances) {
      auto task = instance.getSingleUser<hls::TaskOp>();
      auto taskResult =
          task.getResult(instance.getSingleUse()->getOperandNumber());

      instance->moveBefore(task);
      if (auto parentTask = instance->getParentOfType<hls::TaskOp>())
        instance.setLocation(parentTask.getLocation());
      else if (llvm::any_of(taskResult.getUsers(), [&](Operation *user) {
                 if (auto userParentTask = user->getParentOfType<hls::TaskOp>())
                   return userParentTask.getLocation() == "cpu";
                 return false;
               }))
        instance.setLocation("cpu");
      else
        instance.setLocation(task.getLocation());
    }
  }

  // Recursively add the task to the group, and create a new group if the task
  // is not in the group.
  void dfsScheduleDefiningOp(Value value, size_t prevLevel) {
    // We may need to recalculate the level of the defining op if it is not
    // scheduled at a higher level.
    auto definingOp = value.getDefiningOp();
    if (!definingOp || definingOp->hasTrait<OpTrait::ConstantLike>() ||
        opToLevelMap.lookup(definingOp) > prevLevel)
      return;

    assert(!isa<hls::MemoryInstanceOpInterface>(definingOp) &&
           "tensor/itensor instance op should not be scheduled at all");

    if (auto task = dyn_cast<hls::TaskOp>(definingOp)) {
      auto newLevel = prevLevel;
      while (levelToLocationMap.size() > newLevel &&
             levelToLocationMap[newLevel] != task.getLocation())
        newLevel++;
      opToLevelMap[task] = newLevel;
      if (newLevel == levelToLocationMap.size())
        levelToLocationMap.push_back(*task.getLocation());
      for (auto liveIn : task.getLiveIns())
        dfsScheduleDefiningOp(liveIn, newLevel);
    } else if (!isDestinationStyleOp(definingOp) && prevLevel == 0) {
      for (auto operand : definingOp->getOperands())
        dfsScheduleDefiningOp(operand, prevLevel);
    } else {
      opToLevelMap[definingOp] = prevLevel;
      for (auto operand : definingOp->getOperands())
        dfsScheduleDefiningOp(operand, prevLevel);
    }
  }

  /// A helper function to annotate the level to the op.
  void annotateLevelToOp() {
    OpBuilder builder(&getContext());
    for (auto [op, level] : opToLevelMap)
      op->setAttr("level", builder.getI64IntegerAttr(level));
  }

  void runOnOperation() override {
    auto func = getOperation();
    OpBuilder builder(&getContext());

    // If the task locations are not set, apply the default task locations.
    if (!checkTaskLocations())
      applyDefaultTaskLocations();

    // Ensure single use of non-destination-style ops. The rationale is that
    // task op should always directly yield the tensor or itensor generated by a
    // destination-style op, e.g. a sub-task, an scf loop, etc. Therefore, a
    // non-destination-style op should always be ensured single use to maintain
    // the semantics of task op.
    SmallVector<Operation *> opsToEnsureSingleUse;
    for (auto &op : llvm::make_early_inc_range(func.getOps()))
      if (!isDestinationStyleOp(&op) && !op.hasTrait<OpTrait::ConstantLike>())
        opsToEnsureSingleUse.push_back(&op);

    // We ensure single use in a reversed order to make sure the cascaded
    // non-destination-style ops are also ensured single use.
    for (auto op : llvm::reverse(opsToEnsureSingleUse))
      ensureSingleUse(op, builder);

    // Start the depth-first search from the return operation.
    levelToLocationMap.push_back("cpu");
    for (auto result : func.front().getTerminator()->getOperands())
      dfsScheduleDefiningOp(result, 0);

    // Collect ops of each level in a topo-sorted order.
    SmallVector<SmallVector<Operation *>> levelToOpsMap(
        levelToLocationMap.size());
    for (auto &op : func.getOps())
      if (opToLevelMap.count(&op))
        levelToOpsMap[opToLevelMap.lookup(&op)].push_back(&op);

    // Wrap the ops of each level into a seperate task.
    unsigned taskId = 0;
    for (auto [location, ops] : llvm::zip(levelToLocationMap, levelToOpsMap)) {
      auto taskName =
          func.getName().str() + "_schedule_" + std::to_string(taskId++);
      wrapOpsIntoTask(ops, taskName, location, builder);
    }

    applyTensorITensorInstanceLocations();
  }

private:
  llvm::SmallDenseMap<Operation *, size_t> opToLevelMap;
  llvm::SmallVector<StringRef> levelToLocationMap;
};
} // namespace
