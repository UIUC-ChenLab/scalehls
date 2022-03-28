//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

// A helper to get corresponding DRAM memref type from normal memref type.
static MemRefType getDramType(MemRefType type) {
  return MemRefType::get(type.getShape(), type.getElementType(),
                         type.getLayout().getAffineMap(),
                         (unsigned)MemoryKind::DRAM);
}

namespace {
struct CreateAxiInterface
    : public scalehls::CreateAxiInterfaceBase<CreateAxiInterface> {
  void runOnOperation() override {
    auto module = getOperation();
    OpBuilder builder(module);

    // Get the top and runtime function of the module.
    auto func = getTopFunc(module);
    auto runtime = getRuntimeFunc(module);
    if (!func || !runtime ||
        !llvm::hasSingleElement(runtime.getOps<func::CallOp>())) {
      emitError(module.getLoc(), "fail to find legal top/runtime function");
      return signalPassFailure();
    }

    // Get the top function call.
    auto call = *runtime.getOps<func::CallOp>().begin();
    if (call.getCallee() != func.getName()) {
      call.emitOpError("must reference the top function");
      return signalPassFailure();
    };

    // First, convert the type of the runtime function.
    for (auto arg : runtime.getArguments())
      if (auto type = arg.getType().dyn_cast<MemRefType>())
        arg.setType(getDramType(type));
    runtime.setType(builder.getFunctionType(runtime.front().getArgumentTypes(),
                                            runtime.getResultTypes()));

    // Then, convert each constant to DRAM type.
    for (auto toMemref : runtime.getOps<bufferization::ToMemrefOp>())
      toMemref.memref().setType(
          getDramType(toMemref.getType().cast<MemRefType>()));

    // Third, move each allocated memory in the top function to the runtime
    // function, and convert it to DRAM type.
    SmallVector<Value, 32> inputs(call.getOperands());
    for (auto alloc :
         llvm::make_early_inc_range(func.getOps<memref::AllocOp>())) {
      alloc.memref().setType(getDramType(alloc.getType()));
      alloc->moveBefore(call);

      // Create a new interface
      inputs.push_back(alloc);
      auto arg = func.front().addArgument(alloc.getType(), alloc.getLoc());
      bool hasWriteChannel = true;
      bool hasReadChannel = true;

      for (auto &use : llvm::make_early_inc_range(alloc->getUses())) {
        if (auto subCall = dyn_cast<func::CallOp>(use.getOwner())) {
          auto subFunc = module.lookupSymbol<FuncOp>(subCall.getCallee());
          auto memref = subFunc.getArgument(use.getOperandNumber());

          auto readFlag = llvm::any_of(memref.getUsers(), [](Operation *op) {
            return isa<mlir::AffineReadOpInterface, memref::LoadOp,
                       func::CallOp>(op);
          });
          auto writeFlag = llvm::any_of(memref.getUsers(), [](Operation *op) {
            return isa<mlir::AffineWriteOpInterface, memref::StoreOp,
                       func::CallOp>(op);
          });

          // If the read/write is already occupied, create a new interface.
          if ((readFlag && !hasReadChannel) ||
              (writeFlag && !hasWriteChannel)) {
            inputs.push_back(alloc);
            arg = func.front().addArgument(alloc.getType(), alloc.getLoc());
            hasReadChannel = true;
            hasWriteChannel = true;
          }

          // Occupy read/write channel if applicable.
          if (readFlag)
            hasReadChannel = false;
          if (writeFlag)
            hasWriteChannel = false;
        } else
          llvm_unreachable("memref must be used by call op");

        // Set the current use to the current interface argument.
        use.set(arg);
      }
    }

    // Forth, update the top function call.
    builder.setInsertionPoint(call);
    auto newCall = builder.create<func::CallOp>(call.getLoc(), func.getName(),
                                                func.getResultTypes(), inputs);
    call.replaceAllUsesWith(newCall);
    call.erase();

    // Fifth, convert the type of top function.
    for (auto zip : llvm::zip(func.getArguments(), newCall.getOperandTypes()))
      std::get<0>(zip).setType(std::get<1>(zip));
    func.setType(newCall.getCalleeType());

    // Finally, convert the type of each sub-function.
    for (auto subCall : func.getOps<func::CallOp>()) {
      auto subFunc = module.lookupSymbol<FuncOp>(subCall.getCallee());
      for (auto zip :
           llvm::zip(subFunc.getArguments(), subCall.getOperandTypes()))
        std::get<0>(zip).setType(std::get<1>(zip));
      subFunc.setType(subCall.getCalleeType());
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateAxiInterfacePass() {
  return std::make_unique<CreateAxiInterface>();
}
