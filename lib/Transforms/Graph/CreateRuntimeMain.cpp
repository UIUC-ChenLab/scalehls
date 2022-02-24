//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct CreateRuntimeMain : public CreateRuntimeMainBase<CreateRuntimeMain> {
  CreateRuntimeMain() = default;
  CreateRuntimeMain(const ScaleHLSPyTorchPipelineOptions &opts) {
    topFunc = opts.hlscppTopFunc;
  }

  void runOnOperation() override {
    auto module = getOperation();
    OpBuilder builder(module);

    auto getTopFunc = [&]() {
      for (auto func : module.getOps<FuncOp>())
        if (func.getName() == topFunc)
          return func;
      return FuncOp();
    };

    // Get the top function of the module.
    auto func = getTopFunc();
    if (!func) {
      emitError(module.getLoc(), "fail to find the top function");
      return signalPassFailure();
    }

    // Create the main function of runtime.
    // FIXME: Make sure there's no function called "main" already.
    builder.setInsertionPointAfter(func);
    auto mainFunc =
        builder.create<FuncOp>(builder.getUnknownLoc(), "main", func.getType());
    auto entry = mainFunc.addEntryBlock();

    // Collect all constants the need to be moved.
    SmallVector<Type, 32> newInputTypes(func.getType().getInputs().begin(),
                                        func.getType().getInputs().end());
    SmallVector<tosa::ConstOp, 32> constants;
    for (auto constant : func.getOps<tosa::ConstOp>()) {
      // TODO: Now we just set a simple threshold to determine whether the
      // constant tensor should be stored on chip.
      if (constant.getType().getNumElements() > 256) {
        constants.push_back(constant);
        newInputTypes.push_back(constant.getType());
        auto arg =
            func.front().addArgument(constant.getType(), constant.getLoc());
        constant.replaceAllUsesWith(arg);
      }
    }

    // Set the new type of the original top function.
    auto newFuncType =
        builder.getFunctionType(newInputTypes, func.getResultTypes());
    func.setType(newFuncType);

    // Create a call to the original top function.
    SmallVector<Value, 32> inputs(entry->getArguments().begin(),
                                  entry->getArguments().end());
    inputs.append(constants.begin(), constants.end());
    builder.setInsertionPointToStart(entry);
    auto call = builder.create<CallOp>(builder.getUnknownLoc(), func, inputs);
    builder.create<ReturnOp>(builder.getUnknownLoc(), call.getResults());

    // Move all selected constants to the front of the call.
    for (auto constant : constants)
      constant->moveBefore(call);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateRuntimeMainPass() {
  return std::make_unique<CreateRuntimeMain>();
}
std::unique_ptr<Pass> scalehls::createCreateRuntimeMainPass(
    const ScaleHLSPyTorchPipelineOptions &opts) {
  return std::make_unique<CreateRuntimeMain>(opts);
}
