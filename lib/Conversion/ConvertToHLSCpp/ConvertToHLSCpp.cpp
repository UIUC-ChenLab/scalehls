//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/ConvertToHLSCpp.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
class ConvertToHLSCppPass
    : public mlir::PassWrapper<ConvertToHLSCppPass, OperationPass<ModuleOp>> {
public:
  void runOnOperation() override;
};
} // namespace

void ConvertToHLSCppPass::runOnOperation() {
  for (auto func : getOperation().getOps<FuncOp>()) {
    if (func.getBlocks().size() != 1)
      func.emitError("has zero or more than one basic blocks");

    auto b = OpBuilder(func);

    // Insert AssignOp.
    if (auto returnOp = dyn_cast<ReturnOp>(func.front().getTerminator())) {
      b.setInsertionPoint(returnOp);
      unsigned idx = 0;
      for (auto operand : returnOp.getOperands()) {
        if (operand.getKind() == Value::Kind::BlockArgument) {
          auto value =
              b.create<AssignOp>(returnOp.getLoc(), operand.getType(), operand);
          returnOp.setOperand(idx, value);
        } else if (isa<ConstantOp>(operand.getDefiningOp())) {
          auto value =
              b.create<AssignOp>(returnOp.getLoc(), operand.getType(), operand);
          returnOp.setOperand(idx, value);
        }
        idx += 1;
      }
    } else
      func.emitError("doesn't have a return as terminator.");

    // Set function pragma attributes.
    func.setAttr("dataflow", b.getBoolAttr(false));

    for (auto &op : func.front()) {
      if (auto forOp = dyn_cast<AffineForOp>(op)) {
        if (forOp.getLoopBody().getBlocks().size() != 1)
          forOp.emitError("has zero or more than one basic blocks");

        // Set loop pragma attributes.
        forOp.setAttr("pipeline", b.getBoolAttr(false));
        forOp.setAttr("pipeline_II", b.getUI32IntegerAttr(1));
        forOp.setAttr("unroll_factor", b.getUI32IntegerAttr(1));
      }

      for (auto operand : op.getOperands()) {
        if (auto arrayType = operand.getType().dyn_cast<ShapedType>()) {
          bool insertArrayOp = false;
          if (operand.getKind() == Value::Kind::BlockArgument)
            insertArrayOp = true;
          else if (!isa<ArrayOp>(operand.getDefiningOp())) {
            insertArrayOp = true;
            if (!arrayType.hasStaticShape())
              operand.getDefiningOp()->emitError(
                  "is unranked or has dynamic shape which is illegal.");
          }

          if (insertArrayOp) {
            // Insert array operation and set attributes.
            b.setInsertionPointAfterValue(operand);
            auto arrayOp =
                b.create<ArrayOp>(op.getLoc(), operand.getType(), operand);
            operand.replaceAllUsesExcept(arrayOp.getResult(),
                                         SmallPtrSet<Operation *, 1>{arrayOp});

            // Set array pragma attributes, default array instance is ram_1p
            // bram. Other attributes are not set here since they requires more
            // analysis to be determined.
            arrayOp.setAttr("interface", b.getBoolAttr(false));
            arrayOp.setAttr("storage_type", b.getStringAttr("ram_1p"));
            arrayOp.setAttr("storage_impl", b.getStringAttr("bram"));
            arrayOp.setAttr("partition", b.getBoolAttr(false));
          }
        }
      }
    }
  }
}

void hlscpp::registerConvertToHLSCppPass() {
  PassRegistration<ConvertToHLSCppPass>(
      "convert-to-hlscpp", "Convert to HLS C++ emittable representation.");
}
