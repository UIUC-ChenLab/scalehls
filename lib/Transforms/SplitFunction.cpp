//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"

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
    DenseMap<int64_t, SmallVector<Operation *, 2>> dataflowOps;
    top.walk([&](hlskernel::HLSKernelOpInterface kernelOp) {
      if (auto attr = kernelOp.getAttrOfType<IntegerAttr>("dataflow_level"))
        dataflowOps[attr.getInt()].push_back(kernelOp.getOperation());
    });

    for (auto pair : dataflowOps) {
      auto name = "dataflow" + std::to_string(pair.first);
      auto ops = pair.second;

      // Collect input and output information.
      DenseMap<int64_t, SmallVector<int64_t, 8>> inputMap;
      SmallVector<Type, 4> inputTypes;
      SmallVector<Value, 4> inputValues;

      SmallVector<Type, 4> outputTypes;
      SmallVector<Value, 4> outputValues;

      unsigned opIndex = 0;
      for (auto op : ops) {
        // Add input types and values.
        for (auto operand : op->getOperands()) {
          // Record the index of the operand.
          auto operandFound =
              std::find(inputValues.begin(), inputValues.end(), operand);
          auto operandIndex = operandFound - inputValues.begin();
          inputMap[opIndex].push_back(operandIndex);

          // Only add unique values.
          if (operandFound == inputValues.end()) {
            inputTypes.push_back(operand.getType());
            inputValues.push_back(operand);
          }
        }
        opIndex += 1;

        // Add output types and values.
        for (auto result : op->getResults()) {
          // Only add values that are used.
          if (!result.getUses().empty()) {
            outputTypes.push_back(result.getType());
            outputValues.push_back(result);
          }
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

      // Move HLSKernel operation into the new created function.
      opIndex = 0;
      for (auto op : ops) {
        op->moveBefore(returnOp);
        // Connect operands to the arguments of the new created function.
        for (unsigned i = 0, e = op->getNumOperands(); i < e; ++i)
          op->setOperand(i, entry->getArgument(inputMap[opIndex][i]));
        opIndex += 1;
      }
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createSplitFunctionPass() {
  return std::make_unique<SplitFunction>();
}
