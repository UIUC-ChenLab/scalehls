//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/HLSKernelToAffine.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Dialect/HLSKernel/Visitor.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Pass/Pass.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace scalehls;
using namespace hlskernel;

//===----------------------------------------------------------------------===//
// HLSKernelVisitor Class
//===----------------------------------------------------------------------===//

namespace {
class HLSKernelVisitor : public HLSKernelVisitorBase<HLSKernelVisitor, bool> {
public:
  explicit HLSKernelVisitor() {}

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSKernelVisitorBase::visitOp;
  bool visitOp(ConvOp op);
};
} // namespace

bool HLSKernelVisitor::visitOp(ConvOp op) {
  llvm::outs() << "test\n";
  return true;
}

//===----------------------------------------------------------------------===//
// HLSCppAnalyzer Class
//===----------------------------------------------------------------------===//

namespace {
class HLSKernelToAffinePass
    : public mlir::PassWrapper<HLSKernelToAffinePass, OperationPass<ModuleOp>> {
public:
  void runOnOperation() override;
};
} // namespace

void HLSKernelToAffinePass::runOnOperation() {
  HLSKernelVisitor visitor;

  for (auto &op : getOperation()) {
    if (auto func = dyn_cast<FuncOp>(op)) {
      func.walk([&](HLSKernelOpInterface kernelOp) {
        if (visitor.dispatchVisitor(kernelOp))
          return;
        op.emitError("can't be correctly lowered.");
      });
    } else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("is unsupported operation.");
  }
}

void hlskernel::registerHLSKernelToAffinePass() {
  PassRegistration<HLSKernelToAffinePass>(
      "hlskernel-to-affine",
      "Lower hlskernel operations to corresponding affine representation.");
}
