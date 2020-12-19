//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct LegalizeDataflow : public LegalizeDataflowBase<LegalizeDataflow> {
  void runOnOperation() override;
};
} // namespace

void LegalizeDataflow::runOnOperation() {
  auto func = getOperation();
  auto builder = OpBuilder(func);

  // TODO: support non-HLSKernel operations, such as loops.
  // TODO: support non-CNNOps.
  for (auto kernelOp : func.front().getOps<hlskernel::HLSKernelOpInterface>()) {
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
  for (auto kernelOp : func.front().getOps<hlskernel::HLSKernelOpInterface>()) {
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
          copyOp.setAttr(
              "dataflow_level",
              builder.getIntegerAttr(builder.getI64Type(), dataflowLevel + 1));

          // Replace the operand with the result of CopyOp.
          use.getOwner()->setOperand(use.getOperandNumber(),
                                     copyOp.getResult(0));
        }
      }
    }
  }

  // Reorder operations that are legalized.
  DenseMap<int64_t, SmallVector<Operation *, 2>> dataflowOps;
  func.walk([&](hlskernel::HLSKernelOpInterface kernelOp) {
    if (auto attr = kernelOp.getAttrOfType<IntegerAttr>("dataflow_level"))
      dataflowOps[attr.getInt()].push_back(kernelOp.getOperation());
  });

  for (auto pair : dataflowOps) {
    auto ops = pair.second;
    auto firstOp = ops.front();

    for (auto op : llvm::drop_begin(ops, 1)) {
      op->moveBefore(firstOp);
      firstOp = op;
    }
  }

  // Set dataflow attribute.
  func.setAttr("dataflow", builder.getBoolAttr(true));
}

std::unique_ptr<mlir::Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
