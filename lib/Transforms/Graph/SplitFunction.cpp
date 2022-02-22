//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

static bool applySplitFunction(FuncOp func, ArrayRef<Operation *> ops,
                               StringRef name, bool splitSubFunc) {
  Liveness liveness(func);
  auto builder = OpBuilder(func);

  // A helper that checks whether a value is a liveout value.
  auto isLiveOut = [&](Value value) {
    return any_of(value.getUsers(), [&](auto user) {
      return all_of(ops, [&](auto op) { return !op->isAncestor(user); });
    });
  };

  // Output types and values of the sub-function.
  SmallVector<Type, 8> outputTypes;
  SmallVector<Value, 8> outputValues;

  // Internal values of the sub-function.
  llvm::SmallDenseSet<Value, 16> internalValues;

  for (auto op : ops)
    for (auto result : op->getResults()) {
      internalValues.insert(result);
      if (isLiveOut(result)) {
        outputTypes.push_back(result.getType());
        outputValues.push_back(result);
      }
    }

  // Input types and values of the sub-function.
  SmallVector<Type, 8> inputTypes;
  SmallVector<Value, 8> inputValues;

  // Local buffers of the sub-function.
  llvm::SmallDenseSet<Operation *, 8> localBufs;

  for (auto op : ops) {
    // Push back all operands and liveins as candidates.
    SmallVector<Value, 8> inputCandidates(op->getOperands());
    for (auto &region : op->getRegions()) {
      auto entryBlock = &region.front();
      auto args = entryBlock->getArguments();

      for (auto liveIn : liveness.getLiveIn(entryBlock))
        if (llvm::find(args, liveIn) == args.end())
          inputCandidates.push_back(liveIn);
    }

    for (auto input : inputCandidates) {
      // If the current input is a induction variable or internal value, it
      // doesn't needs to be passed in as argument.
      if (isForInductionVar(input) || internalValues.count(input))
        continue;

      // If the current input is not a liveout and it's defined by an memref
      // alloc op, it is a local buffer and can be localized later.
      if (!isLiveOut(input))
        if (auto alloc = input.getDefiningOp<memref::AllocOp>()) {
          localBufs.insert(alloc);
          continue;
        }

      // Only unique inputs will be added.
      if (llvm::find(inputValues, input) != inputValues.end())
        continue;

      inputTypes.push_back(input.getType());
      inputValues.push_back(input);
    }
  }

  // Create a new function for the current dataflow level.
  builder.setInsertionPoint(func);
  auto subFunc = builder.create<FuncOp>(
      func.getLoc(), name, builder.getFunctionType(inputTypes, outputTypes));

  // Create a function call and reconnect all inputs and outputs.
  builder.setInsertionPointAfter(ops.back());
  auto call = builder.create<CallOp>(func.getLoc(), subFunc, inputValues);
  unsigned outputIdx = 0;
  for (auto result : call.getResults())
    outputValues[outputIdx++].replaceAllUsesWith(result);

  // Create new return operation in the new created function.
  auto entry = subFunc.addEntryBlock();
  builder.setInsertionPointToEnd(entry);
  auto returnOp = builder.create<ReturnOp>(subFunc.getLoc(), outputValues);

  // Move local buffers into the new created function.
  for (auto alloc : localBufs)
    alloc->moveBefore(&subFunc.front().front());

  // Move same level operations into the new created function.
  for (auto op : ops) {
    op->moveBefore(returnOp);
    op->removeAttr("dataflow_level");
  }

  // Connect operands to the arguments of the new created function.
  for (unsigned i = 0, e = inputValues.size(); i < e; ++i)
    inputValues[i].replaceUsesWithIf(
        entry->getArgument(i),
        [&](OpOperand &use) { return subFunc->isAncestor(use.getOwner()); });

  // Remove redundant copy nodes. As long as the defining operation of the
  // target memory is contained in the sub-function, the copy operation and
  // the target memory are redundant.
  SmallVector<Operation *, 4> opsToErase;
  for (auto copyOp : subFunc.front().getOps<memref::CopyOp>())
    if (auto defOp = copyOp.getTarget().getDefiningOp()) {
      copyOp.getTarget().replaceAllUsesWith(copyOp.getSource());
      opsToErase.push_back(copyOp);
      opsToErase.push_back(defOp);
    }

  for (auto op : opsToErase)
    op->erase();

  // Further split each loop band into a function if required.
  if (splitSubFunc) {
    SmallVector<Operation *, 4> loops;
    for (auto &op : subFunc.front().getOperations()) {
      if (isa<AffineForOp, memref::CopyOp>(op))
        loops.push_back(&op);
    }

    if (loops.size() > 1) {
      unsigned index = 0;
      for (auto loop : loops) {
        auto loopName = std::string(name) + "_loop" + std::to_string(index);
        applySplitFunction(subFunc, {loop}, loopName, splitSubFunc);
        ++index;
      }
    }
  }

  return true;
}

namespace {
struct SplitFunction : public SplitFunctionBase<SplitFunction> {
  void runOnOperation() override {
    auto module = getOperation();

    SmallVector<FuncOp, 4> funcs;
    for (auto func : module.getOps<FuncOp>())
      funcs.push_back(func);

    for (auto func : funcs) {
      DenseMap<int64_t, SmallVector<Operation *, 8>> dataflowOps;
      for (auto &op : func.front().getOperations())
        if (auto attr = op.getAttrOfType<IntegerAttr>("dataflow_level"))
          dataflowOps[attr.getInt()].push_back(&op);

      for (auto pair : dataflowOps) {
        auto name = "dataflow" + std::to_string(pair.first);
        applySplitFunction(func, pair.second, name, splitSubFunc);
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSplitFunctionPass() {
  return std::make_unique<SplitFunction>();
}
