//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct CreateAxiInterface
    : public scalehls::CreateAxiInterfaceBase<CreateAxiInterface> {
  void runOnOperation() override {
    auto module = getOperation();
    OpBuilder builder(module);

    // Get the top function of the module.
    auto func = getTopFunc(module);
    if (!func) {
      emitError(module.getLoc(), "fail to find the top function");
      return signalPassFailure();
    }

    // Convert each argument memory kind to DRAM and buffer each of them.
    for (auto arg : func.getArguments()) {
      if (auto type = arg.getType().dyn_cast<MemRefType>()) {
        arg.setType(MemRefType::get(type.getShape(), type.getElementType(),
                                    type.getLayout().getAffineMap(),
                                    (unsigned)MemoryKind::DRAM));
      }
    }

    // Finally, update the type of the function.
    func.setType(builder.getFunctionType(func.front().getArgumentTypes(),
                                         func.getResultTypes()));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateAxiInterfacePass() {
  return std::make_unique<CreateAxiInterface>();
}
