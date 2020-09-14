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
  void runOnOperation() override {
    for (auto &funcOp : getOperation()) {
      if (auto func = dyn_cast<FuncOp>(funcOp)) {
        if (func.getBlocks().size() != 1)
          func.emitError("has zero or more than one basic blocks");

        if (auto returnOp = dyn_cast<ReturnOp>(func.front().getTerminator())) {
          auto builder = OpBuilder(returnOp);
          unsigned operandIdx = 0;
          for (auto operand : returnOp.getOperands()) {
            if (operand.getKind() == Value::Kind::BlockArgument) {
              auto newValue = builder.create<AssignOp>(
                  returnOp.getLoc(), operand.getType(), operand);
              returnOp.setOperand(operandIdx, newValue);
            }
            operandIdx += 1;
          }
        } else
          func.emitError("doesn't have a return operation as terminator");
      }
    }
  }
};
} // namespace

void hlscpp::registerConvertToHLSCppPass() {
  PassRegistration<ConvertToHLSCppPass>(
      "convert-to-hlscpp", "Convert to HLS C++ emittable representation.");
}
