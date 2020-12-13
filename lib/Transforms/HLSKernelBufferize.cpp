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

    // Replace all tensor outputs of HLSKernel operations with memory reference.
    func.walk([&](hlskernel::HLSKernelOpInterface kernelOp) {
      auto op = kernelOp.getOperation();
      builder.setInsertionPoint(op);

      unsigned operandIndex = 0;
      for (auto operand : op->getOperands()) {
        if (auto operandType = operand.getType().dyn_cast<RankedTensorType>()) {
          auto memRefType = MemRefType::get(operandType.getShape(),
                                            operandType.getElementType());
          auto operandMemRef = builder.create<mlir::TensorToMemrefOp>(
              func.getLoc(), memRefType, operand);
          op->setOperand(operandIndex, operandMemRef);
        }
        operandIndex += 1;
      }

      if (op->getNumResults()) {
        auto resultType = op->getResult(0).getType().cast<RankedTensorType>();

        auto resultMemRef = builder.create<mlir::AllocOp>(
            op->getLoc(), MemRefType::get(resultType.getShape(),
                                          resultType.getElementType()));
        SmallVector<Value, 4> newOperands = op->getOperands();
        newOperands.push_back(resultMemRef);
        op->setOperands(newOperands);

        // Create a TensorLoad operaion to replace the original returned tensor.
        builder.setInsertionPointAfter(op);
        auto resultTensor =
            builder.create<mlir::TensorLoadOp>(func.getLoc(), resultMemRef);
        op->getResult(0).replaceAllUsesWith(resultTensor);
      }
    });
  }
}

std::unique_ptr<mlir::Pass> scalehls::createHLSKernelBufferizePass() {
  return std::make_unique<HLSKernelBufferize>();
}
