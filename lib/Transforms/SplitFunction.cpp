//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"
#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/Linalg/IR/LinalgOps.h"
#include "llvm/ADT/SmallPtrSet.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct SplitFunction : public SplitFunctionBase<SplitFunction> {
  void runOnOperation() override {
    auto module = getOperation();
    auto builder = OpBuilder(module);

    SmallVector<FuncOp, 4> funcs;
    for (auto func : module.getOps<FuncOp>())
      funcs.push_back(func);

    for (auto func : funcs) {
      applySplitFunction(func, builder);
    }
  }
};
} // namespace

bool scalehls::applySplitFunction(FuncOp func, OpBuilder &builder) {
  Liveness liveness(func);

  DenseMap<int64_t, SmallVector<Operation *, 8>> dataflowOps;
  for (auto &op : func.front().getOperations())
    if (auto attr = op.getAttrOfType<IntegerAttr>("dataflow_level"))
      dataflowOps[attr.getInt()].push_back(&op);

  for (auto pair : dataflowOps) {
    auto name = "dataflow" + std::to_string(pair.first);
    auto ops = pair.second;

    // Collect output types and values.
    SmallVector<Type, 8> outputTypes;
    SmallVector<Value, 8> outputValues;
    SmallVector<Value, 8> internalValues;

    for (auto op : ops) {
      for (auto result : op->getResults()) {
        // Only add values that are used.
        if (result.getUses().empty())
          continue;

        // If the result is only used by operations in the same level, it is
        // an internal value and will not be returned.
        bool isInternalResult = true;
        for (auto user : result.getUsers())
          if (std::find(ops.begin(), ops.end(), user) == ops.end()) {
            isInternalResult = false;
            break;
          }

        if (isInternalResult) {
          internalValues.push_back(result);
          continue;
        }

        outputTypes.push_back(result.getType());
        outputValues.push_back(result);
      }
    }

    // Collect input types and values.
    SmallVector<Type, 8> inputTypes;
    SmallVector<Value, 8> inputValues;
    SmallVector<Operation *, 8> internalMemories;

    for (auto op : ops) {
      // Push back all operands and live ins as candidates.
      SmallVector<Value, 8> inputCandidates(op->getOperands());
      if (auto loop = dyn_cast<AffineForOp>(op)) {
        auto liveIns = liveness.getLiveIn(&loop.getLoopBody().front());
        for (auto liveIn : liveIns)
          if (!isForInductionVar(liveIn))
            inputCandidates.push_back(liveIn);
      }

      // Collect input types and values.
      for (auto input : inputCandidates) {
        // If the current input candidate is internal value, it does not need
        // to be passed in as argument.
        if (std::find(internalValues.begin(), internalValues.end(), input) !=
            internalValues.end())
          continue;

        // Internal memory defining operation should be moved into the sub
        // function, except TensorToMemrefOp.
        if (auto defOp = input.getDefiningOp()) {
          if (input.getType().isa<MemRefType>() &&
              !isa<TensorToMemrefOp>(defOp)) {
            bool isInternalMemory = true;
            for (auto user : input.getUsers()) {
              bool hasAncestor = false;
              for (auto op : ops)
                if (op->isAncestor(user))
                  hasAncestor = true;

              if (!hasAncestor) {
                isInternalMemory = false;
                break;
              }
            }

            if (isInternalMemory) {
              internalMemories.push_back(defOp);
              continue;
            }
          }
        }

        // Only unique inputs will be added.
        if (std::find(inputValues.begin(), inputValues.end(), input) !=
            inputValues.end())
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

    // Move same level operations into the new created function.
    for (auto op : ops) {
      op->moveBefore(returnOp);
      op->removeAttr("dataflow_level");
      // Connect operands to the arguments of the new created function.
      for (unsigned i = 0, e = inputValues.size(); i < e; ++i)
        inputValues[i].replaceUsesWithIf(
            entry->getArgument(i), [&](OpOperand &use) {
              return subFunc.getOperation()->isAncestor(use.getOwner());
            });
    }

    // Move internal memory defining operation into the new created function.
    for (auto memoryDefOp : internalMemories)
      memoryDefOp->moveBefore(&subFunc.front().front());

    // Remove redundant copy nodes. As lond as the defining operation of the
    // target memory is contained in the sub-function, the copy operation and
    // the target memory are redundant.
    SmallVector<Operation *, 4> opsToErase;
    for (auto copyOp : subFunc.front().getOps<linalg::CopyOp>())
      if (auto defOp = copyOp.getTarget().getDefiningOp()) {
        copyOp.getTarget().replaceAllUsesWith(copyOp.getSource());
        opsToErase.push_back(copyOp);
        opsToErase.push_back(defOp);
      }

    for (auto op : opsToErase)
      op->erase();
  }
  return true;
}

std::unique_ptr<Pass> scalehls::createSplitFunctionPass() {
  return std::make_unique<SplitFunction>();
}
