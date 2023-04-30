//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Utils/Utils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct OutlineTopFunc : public OutlineTopFuncBase<OutlineTopFunc> {
  OutlineTopFunc() = default;
  OutlineTopFunc(std::string optTopFunc, std::string optRuntimeFunc) {
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

    // Create the runtime function.
    builder.setInsertionPointAfter(top);
    auto runtime =
        builder.create<func::FuncOp>(loc, runtimeFunc, top.getFunctionType());
    setRuntimeAttr(runtime);
    auto runtimeBlock = runtime.addEntryBlock();
    builder.setInsertionPointToEnd(runtimeBlock);

    // Move all the arguments of the top function to the runtime function.
    for (auto [topArg, runtimeArg] :
         llvm::zip(top.getArguments(), runtimeBlock->getArguments()))
      topArg.replaceAllUsesWith(runtimeArg);
    top.front().eraseArguments(0, top.getNumArguments());

    // Create top function ports for each runtime argument.
    SmallVector<Value, 32> topPorts;
    for (auto arg : runtimeBlock->getArguments()) {
      topPorts.push_back(arg);
      arg.replaceAllUsesWith(
          top.front().addArgument(arg.getType(), arg.getLoc()));
    }

    // Move buffers instantiated in the top function to the runtime function.
    // Create top function ports for each moved buffer.
    // TODO: Determine the movement based on memoryspace.
    builder.setInsertionPointToEnd(runtimeBlock);
    for (auto buffer :
         llvm::make_early_inc_range(top.getOps<hls::BufferLikeInterface>())) {
      if (buffer.getMemrefType().getNumElements() <= 1024)
        continue;
      buffer->remove();
      builder.insert(buffer);
      topPorts.push_back(buffer.getMemref());
      buffer.getMemref().replaceAllUsesWith(
          top.front().addArgument(buffer.getMemrefType(), buffer.getLoc()));
    }

    // Update the top function and call.
    auto call = builder.create<func::CallOp>(top.getLoc(), top.getName(),
                                             top.getResultTypes(), topPorts);
    top.setType(call.getCalleeType());
    builder.create<func::ReturnOp>(loc, call.getResults());
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createOutlineTopFuncPass(std::string optTopFunc,
                                   std::string optRuntimeFunc) {
  return std::make_unique<OutlineTopFunc>(optTopFunc, optRuntimeFunc);
}
