//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"
#include "mlir/Dialect/Linalg/IR/LinalgOps.h"

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

  //===--------------------------------------------------------------------===//
  // HLSKernel Handler
  //===--------------------------------------------------------------------===//

  // Handle HLSKernel operations. Note that HLSKernel operations must have not
  // been bufferized at this point.
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
          op->emitError(
              "HLSKernelOp has unexpected successor, legalization failed");
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

  //===--------------------------------------------------------------------===//
  // AffineForLoop Handler
  //===--------------------------------------------------------------------===//

  // Handle loops. Note that this assume all operations have been bufferized at
  // this point. Therefore, HLSKernel ops and loops will never have dependencies
  // with each other in this pass.
  // TODO: analyze live ins.
  SuccessorsMap successorsMap;
  getSuccessorsMap(func.front(), successorsMap);

  for (auto it = func.front().rbegin(); it != func.front().rend(); ++it) {
    if (auto loop = dyn_cast<mlir::AffineForOp>(*it)) {
      int64_t dataflowLevel = 0;

      // Walk through all successor loops.
      for (auto pair : successorsMap[loop]) {
        auto successor = pair.second;
        if (auto attr = successor->getAttrOfType<IntegerAttr>("dataflow_level"))
          dataflowLevel = max(dataflowLevel, attr.getInt());
        else {
          loop.emitError("loop has unexpected successor, legalization failed");
          return;
        }
      }

      // Set an attribute for indicating the scheduled dataflow level.
      loop.setAttr(
          "dataflow_level",
          builder.getIntegerAttr(builder.getI64Type(), dataflowLevel + 1));

      // Eliminate bypass paths.
      for (auto pair : successorsMap[loop]) {
        auto mem = pair.first;
        auto successor = pair.second;
        auto successorDataflowLevel =
            successor->getAttrOfType<IntegerAttr>("dataflow_level").getInt();

        // Insert CopyOps if required.
        SmallVector<Value, 4> mems;
        mems.push_back(mem);
        builder.setInsertionPoint(successor);

        for (auto i = dataflowLevel; i > successorDataflowLevel; --i) {
          // Create CopyOp.
          auto newMem = builder.create<mlir::AllocOp>(
              loop.getLoc(), mem.getType().cast<MemRefType>());
          auto copyOp = builder.create<linalg::CopyOp>(loop.getLoc(),
                                                       mems.back(), newMem);

          // Set CopyOp dataflow level.
          copyOp.setAttr("dataflow_level",
                         builder.getIntegerAttr(builder.getI64Type(), i));

          // Chain created CopyOps.
          if (i == successorDataflowLevel + 1)
            mem.replaceUsesWithIf(newMem, [&](mlir::OpOperand &use) {
              return successor->isProperAncestor(use.getOwner());
            });
          else
            mems.push_back(newMem);
        }
      }
    }
  }

  // Reorder operations that are legalized, including HLSKernel ops or loops.
  DenseMap<int64_t, SmallVector<Operation *, 2>> dataflowOps;
  func.walk([&](Operation *dataflowOp) {
    if (auto attr = dataflowOp->getAttrOfType<IntegerAttr>("dataflow_level"))
      dataflowOps[attr.getInt()].push_back(dataflowOp);
  });

  for (auto pair : dataflowOps) {
    auto ops = pair.second;
    auto lastOp = ops.back();

    for (auto it = ops.begin(); it < std::prev(ops.end()); ++it) {
      auto op = *it;
      op->moveBefore(lastOp);
    }
  }

  // Set dataflow attribute.
  func.setAttr("dataflow", builder.getBoolAttr(true));
}

std::unique_ptr<mlir::Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
