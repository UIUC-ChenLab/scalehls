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
    builder.setInsertionPointToEnd(mainBlock);

    // Move all the arguments of the top function to the main function.
    for (auto [funcArg, mainArg] :
         llvm::zip(func.getArguments(), mainBlock->getArguments()))
      funcArg.replaceAllUsesWith(mainArg);
    func.front().eraseArguments([](BlockArgument arg) { return true; });

    // A helper to handle vectorized buffers.
    auto getSelfOrVectorizedBuffer = [&](Value buffer) {
      if (llvm::any_of(buffer.getUses(), [](OpOperand &use) {
            return isa<BufferVectorizeOp>(use.getOwner());
          })) {
        if (!buffer.hasOneUse()) {
          emitError(buffer.getLoc(), "buffer can only be vectorized once");
          return signalPassFailure(), Value();
        }
        auto vectorize = cast<BufferVectorizeOp>(*buffer.user_begin());
        vectorize->remove();
        builder.insert(vectorize);
        return vectorize.getResult();
      }
      return buffer;
    };

    // Move buffer arguments of the top function to the main function. Collect
    // all buffers to be converted to AXI interfaces into "buffers". At the same
    // time, we also directly collect all scalar arguments into "funcPorts".
    SmallVector<Value, 32> buffers;
    SmallVector<Value, 32> funcPorts;
    for (auto arg : mainBlock->getArguments())
      if (arg.getType().isa<MemRefType, StreamType>()) {
        buffers.push_back(getSelfOrVectorizedBuffer(arg));
      } else if (arg.getType().isa<ShapedType>()) {
        emitError(arg.getLoc(), "unsupported argument type");
        return signalPassFailure();
      } else {
        funcPorts.push_back(arg);
        arg.replaceAllUsesWith(
            func.front().addArgument(arg.getType(), arg.getLoc()));
      }

    // Move buffers allocated in the top function to the main function. Collect
    // all buffers to be converted to AXI interfaces into "buffers".
    for (auto buffer :
         llvm::make_early_inc_range(func.getOps<hls::BufferLikeInterface>())) {
      if (!isExtBuffer(buffer.getMemref()))
        continue;
      buffer->remove();
      builder.insert(buffer);
      buffers.push_back(getSelfOrVectorizedBuffer(buffer.getMemref()));
    }

    // A helper to get AXI bundle type from a buffer.
    auto getBundleType = [&](Value buffer) {
      if (auto memrefType = buffer.getType().dyn_cast<MemRefType>())
        return BundleType::get(context, memrefType.getElementType(),
                               AxiKind::MM);
      if (auto streamType = buffer.getType().dyn_cast<StreamType>())
        return BundleType::get(context, streamType.getElementType(),
                               AxiKind::STREAM);
      llvm_unreachable("invalid buffer type");
    };

    // We always bundle buffers with the same element type into a single AXI
    // port. Therefore, we first construct a "bundleMap" to hold the mapping
    // from a bundle type to the AXI bundle operation.
    builder.setInsertionPointToStart(&func.front());
    auto insertPoint = builder.saveInsertionPoint();
    llvm::SmallDenseMap<Type, AxiBundleOp> bundleMap;
    unsigned bundleIndex = 0;
    for (auto buffer : buffers) {
      auto bundleType = getBundleType(buffer);

      if (!bundleMap.count(bundleType)) {
        auto bundle = builder.create<AxiBundleOp>(
            loc, bundleType, "axi_" + std::to_string(bundleIndex++));
        bundleMap[bundleType] = bundle;
        builder.setInsertionPointAfter(bundle);
        insertPoint = builder.saveInsertionPoint();
      }
    }

    // Convert collected buffers to AXI ports and collect them in "funcPorts".
    // Note that we create a separate AXI port for each buffer use to avoid
    // potential conflicts.
    for (auto buffer : buffers)
      for (auto &use : llvm::make_early_inc_range(buffer.getUses())) {
        builder.restoreInsertionPoint(insertPoint);
        auto axiType = AxiType::get(context, buffer.getType());
        auto axiPort = builder.create<AxiPortOp>(
            loc, buffer.getType(), bundleMap.lookup(getBundleType(buffer)),
            func.front().addArgument(axiType, buffer.getLoc()));
        use.set(axiPort);

        builder.setInsertionPointToEnd(mainBlock);
        funcPorts.push_back(builder.create<AxiPackOp>(loc, axiType, buffer));
      }

    // Update the top function and call.
    builder.setInsertionPointToEnd(mainBlock);
    auto call = builder.create<func::CallOp>(func.getLoc(), func.getName(),
                                             func.getResultTypes(), funcPorts);
    func.setType(call.getCalleeType());
    builder.create<func::ReturnOp>(loc, call.getResults());
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createCreateAxiInterfacePass(std::string hlsTopFunc) {
  return std::make_unique<CreateAxiInterface>(hlsTopFunc);
}
