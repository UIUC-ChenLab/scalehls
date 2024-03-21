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

namespace {
struct GenerateRuntimeFunc
    : public GenerateRuntimeFuncBase<GenerateRuntimeFunc> {
  GenerateRuntimeFunc() = default;
  GenerateRuntimeFunc(std::string optTopFunc, std::string optRuntimeFunc) {
    topFunc = optTopFunc;
    runtimeFunc = optRuntimeFunc;
  }

  void runOnOperation() override {
    auto module = getOperation();
    OpBuilder builder(module);
    auto loc = builder.getUnknownLoc();

    // Get the top HLS function.
    auto top = getTopFunc(module, topFunc);
    if (!top) {
      emitError(module.getLoc(), "fail to find the top function");
      return signalPassFailure();
    }
    setTopFuncAttr(top);
    auto topReturn = top.back().getTerminator();

    // Create the runtime function.
    builder.setInsertionPointAfter(top);
    auto runtime =
        builder.create<func::FuncOp>(loc, runtimeFunc, top.getFunctionType());
    setRuntimeAttr(runtime);
    builder.setInsertionPointToEnd(runtime.addEntryBlock());
    auto runtimeReturn = builder.clone(*topReturn);

    // Record the new inputs of the top function.
    SmallVector<Value, 32> topInputs(runtime.getArguments());

    // A helper to demote a buffer to the runtime function.
    auto demoteBuffer = [&](hls::BufferOp buffer) {
      buffer->moveBefore(runtimeReturn);
      topInputs.push_back(buffer.getMemref());
      buffer.getMemref().replaceAllUsesExcept(
          top.front().addArgument(buffer.getMemrefType(), buffer.getLoc()),
          runtimeReturn);
    };

    // If a buffer is returned by the top function, it should always be demoted
    // and then erased from the returning values.
    BitVector eraseIndices;
    for (auto returnedValue : topReturn->getOperands()) {
      if (auto buffer = returnedValue.getDefiningOp<hls::BufferOp>()) {
        demoteBuffer(buffer);
        eraseIndices.push_back(true);
      } else
        eraseIndices.push_back(false);
    }
    topReturn->eraseOperands(eraseIndices);

    // For now, we demote a buffer if it exceeds a threshold.
    for (auto buffer : llvm::make_early_inc_range(top.getOps<hls::BufferOp>()))
      if (buffer.getMemrefType().getNumElements() > 1024)
        demoteBuffer(buffer);

    // Update the top function and call.
    builder.setInsertionPoint(runtimeReturn);
    auto call = builder.create<func::CallOp>(
        top.getLoc(), top.getName(), topReturn->getOperandTypes(), topInputs);
    top.setType(call.getCalleeType());

    for (auto [returnedValue, callResult] :
         llvm::zip(topReturn->getOperands(), call.getResults())) {
      returnedValue.replaceUsesWithIf(callResult, [&](OpOperand &operand) {
        return operand.getOwner() == runtimeReturn;
      });
    }
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::hls::createGenerateRuntimeFuncPass(std::string optTopFunc,
                                             std::string optRuntimeFunc) {
  return std::make_unique<GenerateRuntimeFunc>(optTopFunc, optRuntimeFunc);
}
