//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"
#include "mlir/Analysis/Liveness.h"
#include "llvm/ADT/SmallPtrSet.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct SplitFunction : public SplitFunctionBase<SplitFunction> {
  void runOnOperation() override;
};
} // namespace

void SplitFunction::runOnOperation() {
  auto module = getOperation();
  auto builder = OpBuilder(module);

  SmallVector<FuncOp, 4> funcs;
  for (auto func : module.getOps<FuncOp>())
    funcs.push_back(func);

  for (auto top : funcs) {
    Liveness liveness(top);

    DenseMap<int64_t, SmallVector<Operation *, 8>> dataflowOps;
    for (auto &op : top.front().getOperations())
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
        if (auto loop = dyn_cast<mlir::AffineForOp>(op)) {
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
      builder.setInsertionPoint(top);
      auto func = builder.create<FuncOp>(
          top.getLoc(), name, builder.getFunctionType(inputTypes, outputTypes));

      // Create a function call and reconnect all inputs and outputs.
      builder.setInsertionPointAfter(ops.back());
      auto call = builder.create<mlir::CallOp>(top.getLoc(), func, inputValues);
      unsigned outputIdx = 0;
      for (auto result : call.getResults())
        outputValues[outputIdx++].replaceAllUsesWith(result);

      // Create new return operation in the new created function.
      auto entry = func.addEntryBlock();
      builder.setInsertionPointToEnd(entry);
      auto returnOp =
          builder.create<mlir::ReturnOp>(func.getLoc(), outputValues);

      // Move same level operations into the new created function.
      for (auto op : ops) {
        op->moveBefore(returnOp);
        op->removeAttr("dataflow_level");
        // Connect operands to the arguments of the new created function.
        for (unsigned i = 0, e = inputValues.size(); i < e; ++i)
          inputValues[i].replaceUsesWithIf(
              entry->getArgument(i), [&](mlir::OpOperand &use) {
                return func.getOperation()->isAncestor(use.getOwner());
              });
      }

      // Move internal memory defining operation into the new created function.
      for (auto memoryDefOp : internalMemories)
        memoryDefOp->moveBefore(&func.front().front());
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createSplitFunctionPass() {
  return std::make_unique<SplitFunction>();
}
