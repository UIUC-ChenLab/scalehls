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

/// A helper to get corresponding DRAM memref type from normal memref type.
static Type getDramType(Type type) {
  if (auto memrefType = type.dyn_cast<MemRefType>())
    return MemRefType::get(memrefType.getShape(), memrefType.getElementType(),
                           memrefType.getLayout().getAffineMap(),
                           (unsigned)MemoryKind::DRAM);
  return type;
}

/// A helper to update function type recursively.
void updateFuncType(func::FuncOp func, OpBuilder &builder) {
  func.setType(
      builder.getFunctionType(func.front().getArgumentTypes(),
                              func.back().getTerminator()->getOperandTypes()));
  for (auto subCall : func.getOps<func::CallOp>()) {
    auto subFunc = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
        subCall, subCall.getCalleeAttr());
    for (auto t : llvm::zip(subFunc.getArguments(), subCall.getOperandTypes()))
      std::get<0>(t).setType(std::get<1>(t));
    updateFuncType(subFunc, builder);
  }
  for (auto task : func.getOps<TaskOp>())
    for (auto t :
         llvm::zip(task.getBody()->getArguments(), task.getOperandTypes()))
      std::get<0>(t).setType(std::get<1>(t));
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
    if (!func || !runtime || func.getNumResults() || runtime.getNumResults() ||
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

    // Move each allocs, buffer primitives, and constant primitives, allocated
    // in the top function to the runtime function. As each AXI interface only
    // has one read and one write channel, we need to avoid interface conflicts
    // by analyzing the memroy access pattern of sub-functions.
    SmallVector<Value, 32> inputs(call.getOperands());
    for (auto &op : llvm::make_early_inc_range(func.front())) {
      if (!isa<memref::AllocOp, BufferOp, ConstBufferOp>(op))
        continue;
      auto memref = op.getResult(0);
      auto type = memref.getType().cast<MemRefType>();
      op.moveBefore(call);

      // Add a new AXI interface to the top function.
      inputs.push_back(memref);
      auto interface = func.front().addArgument(type, op.getLoc());
      bool writeChannel = true, readChannel = true;

      for (auto &use : llvm::make_early_inc_range(op.getUses())) {
        if (auto task = dyn_cast<TaskOp>(use.getOwner())) {
          auto arg = task.getBody()->getArgument(use.getOperandNumber());

          auto readFlag = llvm::any_of(arg.getUsers(), [](Operation *op) {
            return isa<mlir::AffineReadOpInterface, func::CallOp>(op);
          });
          auto writeFlag = llvm::any_of(arg.getUsers(), [](Operation *op) {
            return isa<mlir::AffineWriteOpInterface, func::CallOp>(op);
          });

          // If the read/write is already occupied, add a new AXI interface.
          if ((readFlag && !readChannel) || (writeFlag && !writeChannel)) {
            inputs.push_back(memref);
            interface = func.front().addArgument(type, op.getLoc());
            writeChannel = true, readChannel = true;
          }

          // Occupy the current read/write channel.
          if (readFlag)
            readChannel = false;
          if (writeFlag)
            writeChannel = false;
        } else {
          use.getOwner()->emitOpError("memref must be used by call op");
          return signalPassFailure();
        }

        // Set the current use to the current interface argument.
        use.set(interface);
      }
    }

    // Update the top function and call.
    builder.setInsertionPoint(call);
    auto newCall = builder.create<func::CallOp>(call.getLoc(), func.getName(),
                                                func.getResultTypes(), inputs);
    call.replaceAllUsesWith(newCall);
    call.erase();
    func.setType(newCall.getCalleeType());

    // Convert each memory in the runtime function to DRAM type.
    for (auto arg : runtime.getArguments())
      arg.setType(getDramType(arg.getType()));
    for (auto &op : runtime.front())
      for (auto result : op.getResults())
        result.setType(getDramType(result.getType()));

    // Update function type recursively.
    updateFuncType(runtime, builder);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateAxiInterfacePass() {
  return std::make_unique<CreateAxiInterface>();
}
