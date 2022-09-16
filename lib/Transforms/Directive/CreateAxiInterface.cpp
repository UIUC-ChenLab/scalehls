//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct CreateAxiInterface : public CreateAxiInterfaceBase<CreateAxiInterface> {
  CreateAxiInterface() = default;
  CreateAxiInterface(std::string hlsTopFunc) { topFunc = hlsTopFunc; }

  void runOnOperation() override {
    auto module = getOperation();
    OpBuilder builder(module);
    auto context = builder.getContext();
    auto loc = builder.getUnknownLoc();

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
    auto mainFunc =
        builder.create<func::FuncOp>(loc, "main", func.getFunctionType());
    setRuntimeAttr(mainFunc);
    auto mainBlock = mainFunc.addEntryBlock();

    for (auto t : llvm::zip(func.getArguments(), mainBlock->getArguments()))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
    func.front().eraseArguments([](BlockArgument arg) { return true; });

    // Move each buffers allocated in the top function to the runtime function.
    // Collect all values that will be converted to AXI.
    SmallVector<Value, 32> targets(mainBlock->args_begin(),
                                   mainBlock->args_end());
    builder.setInsertionPointToEnd(mainBlock);
    for (auto &op : llvm::make_early_inc_range(func.front()))
      if (isa<BufferOp, ConstBufferOp>(op)) {
        auto memrefType = op.getResult(0).getType().cast<MemRefType>();
        // TODO: We use a magic number to determine whether to store the result
        // in external memory.
        if (memrefType.getNumElements() < 1024)
          continue;
        op.remove();
        builder.insert(&op);
        targets.push_back(op.getResult(0));
      }

    // Add new AXI ports to the top function.
    SmallVector<Value, 32> axiPorts;
    unsigned axiIdx = 0;
    for (auto value : targets) {
      for (auto &use : llvm::make_early_inc_range(value.getUses())) {

        auto axiName = "axi" + std::to_string(axiIdx++);
        auto axiKind =
            value.getType().isa<ShapedType>() ? AxiKind::MM : AxiKind::LITE;
        auto axiType = AxiType::get(context, value.getType(),
                                    AxiKindAttr::get(context, axiKind));
        auto bundleType =
            BundleType::get(context, AxiKindAttr::get(context, axiKind));

        builder.setInsertionPointToEnd(mainBlock);
        axiPorts.push_back(builder.create<AxiPackOp>(loc, axiType, value));
        auto axiArg = func.front().addArgument(axiType, value.getLoc());

        builder.setInsertionPointToStart(&func.front());
        auto bundle = builder.create<AxiBundleOp>(loc, bundleType, axiName);
        use.set(
            builder.create<AxiPortOp>(loc, value.getType(), bundle, axiArg));
      }
    }

    // Update the top function and call.
    builder.setInsertionPointToEnd(mainBlock);
    auto call = builder.create<func::CallOp>(func.getLoc(), func.getName(),
                                             func.getResultTypes(), axiPorts);
    func.setType(call.getCalleeType());
    builder.create<func::ReturnOp>(loc, call.getResults());
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createCreateAxiInterfacePass(std::string hlsTopFunc) {
  return std::make_unique<CreateAxiInterface>(hlsTopFunc);
}
