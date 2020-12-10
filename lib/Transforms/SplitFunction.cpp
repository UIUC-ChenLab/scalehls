//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"
#include "mlir/IR/Builders.h"

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
    unsigned funcIdx = 0;
    top.walk([&](hlskernel::HLSKernelOpInterface kernelOp) {
      auto op = kernelOp.getOperation();
      std::string prefix = op->getName().getStringRef().str();
      std::replace(prefix.begin(), prefix.end(), '.', '_');

      // Add input types and values.
      SmallVector<Type, 4> inputTypes;
      SmallVector<Value, 4> inputValues;
      for (auto operand : op->getOperands()) {
        inputTypes.push_back(operand.getType());
        inputValues.push_back(operand);
      }

      // Add output types and values.
      SmallVector<Type, 4> outputTypes;
      SmallVector<Value, 4> outputValues;
      for (auto result : op->getResults()) {
        outputTypes.push_back(result.getType());
        outputValues.push_back(result);
      }

      // Create a new function for the current operation.
      builder.setInsertionPoint(top);
      auto func = builder.create<FuncOp>(
          top.getLoc(), prefix + "_" + std::to_string(funcIdx),
          builder.getFunctionType(inputTypes, outputTypes));

      // Create a function call and reconnect all inputs and outputs.
      builder.setInsertionPoint(op);
      auto call = builder.create<mlir::CallOp>(op->getLoc(), func, inputValues);
      unsigned outputIdx = 0;
      for (auto result : call.getResults())
        outputValues[outputIdx++].replaceAllUsesWith(result);

      // Move HLSKernel operation into the new created function.
      auto entry = func.addEntryBlock();
      op->moveBefore(entry, entry->end());
      op->setOperands(entry->getArguments());

      // Create new return operation in the new created function.
      builder.setInsertionPointToEnd(entry);
      builder.create<mlir::ReturnOp>(func.getLoc(), outputValues);

      funcIdx += 1;
    });
  }
  return;
}

std::unique_ptr<mlir::Pass> scalehls::createSplitFunctionPass() {
  return std::make_unique<SplitFunction>();
}
