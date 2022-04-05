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
using namespace hls;

static SmallVector<arith::ConstantOp, 8>
collectConstantsAndUpdateFuncionType(FuncOp func) {
  SmallVector<arith::ConstantOp, 8> constants;
  SmallVector<Type, 8> newInputTypes(func.getFunctionType().getInputs().begin(),
                                     func.getFunctionType().getInputs().end());

  // Traverse all constants in the function.
  for (auto constant : func.getOps<arith::ConstantOp>()) {
    // Here we set a threshold to a magic number, which is the size of a Xilinx
    // BRAM instance, to control the location of constants allocation.
    auto type = constant.getType().dyn_cast<TensorType>();
    if (!type || type.getNumElements() * type.getElementTypeBitWidth() <= 16384)
      continue;

    // Construct the constants list and input types list.
    constants.push_back(constant);
    newInputTypes.push_back(constant.getType());
    auto arg = func.front().addArgument(constant.getType(), constant.getLoc());
    constant.replaceAllUsesWith(arg);
  }

  // Set the new type of the function.
  func.setType(FunctionType::get(func.getContext(), newInputTypes,
                                 func.getResultTypes()));
  return constants;
}

namespace {
// FIXME: A known issue is when a constant is read multiple times in the top
// function, we can no longer create correct number of AXI interfaces later.
struct CreateRuntimeMain : public CreateRuntimeMainBase<CreateRuntimeMain> {
  CreateRuntimeMain() = default;
  CreateRuntimeMain(std::string hlsTopFunc) { topFunc = hlsTopFunc; }

  void runOnOperation() override {
    auto module = getOperation();
    OpBuilder builder(module);

    // Get the top function of the module.
    auto func = getTopFunc(module, topFunc);
    if (!func) {
      emitError(module.getLoc(), "fail to find the top function");
      return signalPassFailure();
    }
    setTopFuncAttr(func);

    // Create the main function of runtime.
    // FIXME: Make sure there's no function called "main" already.
    builder.setInsertionPointAfter(func);
    auto mainFunc = builder.create<FuncOp>(builder.getUnknownLoc(), "main",
                                           func.getFunctionType());
    setRuntimeAttr(mainFunc);
    auto entry = mainFunc.addEntryBlock();

    auto constants = collectConstantsAndUpdateFuncionType(func);

    // Create a call to the original top function.
    SmallVector<Value, 32> inputs(entry->getArguments().begin(),
                                  entry->getArguments().end());
    inputs.append(constants.begin(), constants.end());
    builder.setInsertionPointToStart(entry);
    auto call =
        builder.create<func::CallOp>(builder.getUnknownLoc(), func, inputs);
    builder.create<func::ReturnOp>(builder.getUnknownLoc(), call.getResults());

    // Move all selected constants to the front of the call.
    for (auto constant : constants)
      constant->moveBefore(call);
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createCreateRuntimeMainPass(std::string hlsTopFunc) {
  return std::make_unique<CreateRuntimeMain>(hlsTopFunc);
}
