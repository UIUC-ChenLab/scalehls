//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/Passes.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct ConvertToHLSCpp : public ConvertToHLSCppBase<ConvertToHLSCpp> {
public:
  void runOnOperation() override;
};
} // namespace

void ConvertToHLSCpp::runOnOperation() {
  auto func = getOperation();
  auto builder = OpBuilder(func);

  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  // Set function pragma attributes.
  if (!func.getAttr("dataflow"))
    func.setAttr("dataflow", builder.getBoolAttr(false));

  if (func.getName() == topFunction)
    func.setAttr("top_function", builder.getBoolAttr(true));
  else
    func.setAttr("top_function", builder.getBoolAttr(false));

  // Insert AssignOp when an arguments or result of ConstantOp are directly
  // connected to ReturnOp.
  if (auto returnOp = dyn_cast<ReturnOp>(func.front().getTerminator())) {
    builder.setInsertionPoint(returnOp);
    unsigned idx = 0;
    for (auto operand : returnOp.getOperands()) {
      if (operand.getKind() == Value::Kind::BlockArgument) {
        auto value = builder.create<AssignOp>(returnOp.getLoc(),
                                              operand.getType(), operand);
        returnOp.setOperand(idx, value);
      } else if (isa<ConstantOp>(operand.getDefiningOp())) {
        auto value = builder.create<AssignOp>(returnOp.getLoc(),
                                              operand.getType(), operand);
        returnOp.setOperand(idx, value);
      }
      idx += 1;
    }
  } else
    func.emitError("doesn't have a return as terminator.");

  // Recursively convert every for loop body blocks.
  func.walk([&](Operation *op) {
    // ArrayOp will be inserted after each ShapedType value from declaration
    // or function signature.
    for (auto operand : op->getOperands()) {
      if (auto arrayType = operand.getType().dyn_cast<ShapedType>()) {
        bool insertArrayOp = false;
        if (operand.getKind() == Value::Kind::BlockArgument)
          insertArrayOp = true;
        else if (!isa<ArrayOp>(operand.getDefiningOp()) &&
                 !isa<AssignOp>(operand.getDefiningOp())) {
          insertArrayOp = true;
          if (!arrayType.hasStaticShape())
            operand.getDefiningOp()->emitError(
                "is unranked or has dynamic shape which is illegal.");
        }

        if (isa<ArrayOp>(op))
          insertArrayOp = false;

        if (insertArrayOp) {
          // Insert array operation and set attributes.
          builder.setInsertionPointAfterValue(operand);
          auto arrayOp =
              builder.create<ArrayOp>(op->getLoc(), operand.getType(), operand);
          operand.replaceAllUsesExcept(arrayOp.getResult(),
                                       SmallPtrSet<Operation *, 1>{arrayOp});

          // Set array pragma attributes.
          // TODO: A known bug is if ArrayOp is connected to ReturnOp through
          // an AssignOp, it will always not be annotated as interface. This
          // is acceptable because AssignOp is only used to handle some weird
          // corner cases that rarely happen.
          if (!arrayOp.getAttr("interface") && func.getName() == topFunction) {
            // Only if when the array is an block arguments or a returned
            // value, it will be annotated as interface.
            bool interfaceFlag =
                operand.getKind() == Value::Kind::BlockArgument;
            for (auto user : arrayOp.getResult().getUsers())
              if (isa<mlir::ReturnOp>(user))
                interfaceFlag = true;

            arrayOp.setAttr("interface", builder.getBoolAttr(interfaceFlag));
          } else
            arrayOp.setAttr("interface", builder.getBoolAttr(false));

          if (!arrayOp.getAttr("storage"))
            arrayOp.setAttr("storage", builder.getBoolAttr(false));

          if (!arrayOp.getAttr("partition"))
            arrayOp.setAttr("partition", builder.getBoolAttr(false));
        }
      }
    }

    if (auto forOp = dyn_cast<AffineForOp>(op)) {
      if (forOp.getLoopBody().getBlocks().size() != 1)
        forOp.emitError("has zero or more than one basic blocks");

      // Set loop pragma attributes.
      if (!forOp.getAttr("pipeline"))
        forOp.setAttr("pipeline", builder.getBoolAttr(false));

      if (!forOp.getAttr("unroll"))
        forOp.setAttr("unroll", builder.getBoolAttr(false));

      if (!forOp.getAttr("flatten"))
        forOp.setAttr("flatten", builder.getBoolAttr(false));
    }
  });
}

std::unique_ptr<mlir::Pass> scalehls::createConvertToHLSCppPass() {
  return std::make_unique<ConvertToHLSCpp>();
}
