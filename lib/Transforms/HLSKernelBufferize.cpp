//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"
#include "mlir/IR/Builders.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct HLSKernelBufferize : public HLSKernelBufferizeBase<HLSKernelBufferize> {
  void runOnOperation() override;
};
} // namespace

void HLSKernelBufferize::runOnOperation() {
  auto module = getOperation();
  auto builder = OpBuilder(module);

  for (auto func : module.getOps<FuncOp>()) {
    builder.setInsertionPointToStart(&func.front());

    // Store tensor arguments to local memref.
    for (auto &arg : func.getArguments()) {
      if (auto argType = arg.getType().dyn_cast<RankedTensorType>()) {
        auto argMemRef = builder.create<mlir::AllocOp>(
            func.getLoc(),
            MemRefType::get(argType.getShape(), argType.getElementType()));
        arg.replaceAllUsesWith(argMemRef);
        builder.create<mlir::TensorStoreOp>(func.getLoc(), arg, argMemRef);
      }
    }

    // Replace all tensor outputs of HLSKernel operations with memory reference.
    func.walk([&](hlskernel::HLSKernelOpInterface kernelOp) {
      auto op = kernelOp.getOperation();
      builder.setInsertionPoint(op);

      if (op->getNumResults()) {
        auto resultType = op->getResult(0).getType().cast<RankedTensorType>();

        auto resultMemRef = builder.create<mlir::AllocOp>(
            op->getLoc(), MemRefType::get(resultType.getShape(),
                                          resultType.getElementType()));
        op->getResult(0).replaceAllUsesWith(resultMemRef);

        SmallVector<Value, 4> newOperands = op->getOperands();
        newOperands.push_back(resultMemRef);
        op->setOperands(newOperands);
        op->dropAllUses();
        op->getResults().drop_front(1);
      }
    });

    // Load tensor from memref and pass to return operation.
    auto returnOp = func.front().getTerminator();
    builder.setInsertionPoint(returnOp);

    unsigned resultIdx = 0;
    for (auto &result : func.getType().getResults()) {
      if (result.isa<RankedTensorType>()) {
        // If the returned value should be tensor type but has been replace with
        // memref type, we will creat a TensorLoadOp here.
        auto returnVal = returnOp->getOperands()[resultIdx];
        if (!returnVal.getType().isa<RankedTensorType>()) {
          auto resultTensor =
              builder.create<mlir::TensorLoadOp>(func.getLoc(), returnVal);
          returnOp->setOperand(resultIdx, resultTensor);
        }
      }
      resultIdx += 1;
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createHLSKernelBufferizePass() {
  return std::make_unique<HLSKernelBufferize>();
}
