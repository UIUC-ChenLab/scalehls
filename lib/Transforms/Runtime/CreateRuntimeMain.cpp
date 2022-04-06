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

namespace {
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

    // Create a call to the original top function.
    builder.setInsertionPointToStart(entry);
    auto call = builder.create<func::CallOp>(builder.getUnknownLoc(), func,
                                             entry->getArguments());
    builder.create<func::ReturnOp>(builder.getUnknownLoc(), call.getResults());
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createCreateRuntimeMainPass(std::string hlsTopFunc) {
  return std::make_unique<CreateRuntimeMain>(hlsTopFunc);
}
