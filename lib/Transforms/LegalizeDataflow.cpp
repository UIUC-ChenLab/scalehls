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
struct LegalizeDataflow : public LegalizeDataflowBase<LegalizeDataflow> {
  void runOnOperation() override;
};
} // namespace

void LegalizeDataflow::runOnOperation() {
  auto module = getOperation();
  auto builder = OpBuilder(module);

  for (auto func : module.getOps<FuncOp>()) {
    // TODO: support non-HLSKernel operations, such as loops.
    // TODO: support non-CNNOps.
    for (auto kernelOp :
         func.front().getOps<hlskernel::HLSKernelOpInterface>()) {
      auto op = kernelOp.getOperation();

      // Walk through all operands to establish an ASAP dataflow schedule.
      int64_t dataflowLevel = 0;
      for (auto operand : op->getOperands()) {
        if (operand.getKind() == Value::Kind::BlockArgument)
          continue;
        else {
          auto predOp = operand.getDefiningOp();
          if (auto attr = predOp->getAttrOfType<IntegerAttr>("dataflow_level"))
            dataflowLevel = max(dataflowLevel, attr.getInt());
          else
            op->emitError("has unexpected dominator");
        }
      }

      // Set an attribute for indicating the scheduled dataflow level.
      op->setAttr("dataflow_level", builder.getIntegerAttr(builder.getI64Type(),
                                                           dataflowLevel + 1));
    }

    // Eliminate bypass paths between non-successive dataflow levels. Dummy
    // nodes will be inserted into the bypass paths.
    for (auto kernelOp :
         func.front().getOps<hlskernel::HLSKernelOpInterface>()) {
      auto op = kernelOp.getOperation();
      auto dataflowLevel =
          op->getAttrOfType<IntegerAttr>("dataflow_level").getInt();

      auto result = op->getResult(0);
      for (auto &use : result.getUses()) {
        if (auto attr =
                use.getOwner()->getAttrOfType<IntegerAttr>("dataflow_level")) {
          if (attr.getInt() != dataflowLevel + 1) {
            // Insert a dummy CopyOp if required.
            builder.setInsertionPointAfter(op);
            auto copyOp = builder.create<hlskernel::CopyOp>(
                op->getLoc(), result.getType(), result);
            copyOp.setAttr("dataflow_level",
                           builder.getIntegerAttr(builder.getI64Type(),
                                                  dataflowLevel + 1));

            // Replace the operand with the result of CopyOp.
            use.getOwner()->setOperand(use.getOperandNumber(),
                                       copyOp.getResult(0));
          }
        }
      }
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
