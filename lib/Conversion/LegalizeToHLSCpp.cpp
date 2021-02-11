//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "scalehls/Conversion/Passes.h"
#include "scalehls/Dialect/HLSCpp/HLSCpp.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct LegalizeToHLSCpp : public LegalizeToHLSCppBase<LegalizeToHLSCpp> {
public:
  void runOnOperation() override;
};
} // namespace

void LegalizeToHLSCpp::runOnOperation() {
  auto func = getOperation();
  auto builder = OpBuilder(func);

  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  // Set function pragma attributes.
  if (!func->getAttr("dataflow"))
    func->setAttr("dataflow", builder.getBoolAttr(false));

  if (func.getName() == topFunc)
    func->setAttr("top_function", builder.getBoolAttr(true));
  else
    func->setAttr("top_function", builder.getBoolAttr(false));

  SmallPtrSet<Value, 16> memrefs;

  // Walk through all operations in the function.
  func.walk([&](Operation *op) {
    // Collect all memrefs.
    for (auto operand : op->getOperands())
      if (operand.getType().isa<MemRefType>())
        memrefs.insert(operand);

    // Set loop pragma attributes.
    if (auto forOp = dyn_cast<AffineForOp>(op)) {
      // Set loop pragma attributes.
      if (!forOp->getAttr("pipeline"))
        forOp->setAttr("pipeline", builder.getBoolAttr(false));

      if (!forOp->getAttr("flatten"))
        forOp->setAttr("flatten", builder.getBoolAttr(false));
    }
  });

  // Set array pragma attributes.
  for (auto memref : memrefs) {
    auto type = memref.getType().cast<MemRefType>();

    if (type.getMemorySpace() == 0) {
      // TODO: determine memory kind according to data type.
      MemoryKind kind = MemoryKind::BRAM_S2P;

      auto newType = MemRefType::get(type.getShape(), type.getElementType(),
                                     type.getAffineMaps(), (unsigned)kind);
      memref.setType(newType);
    }
  }

  // Align function type with entry block argument types.
  auto resultTypes = func.front().getTerminator()->getOperandTypes();
  auto inputTypes = func.front().getArgumentTypes();
  func.setType(builder.getFunctionType(inputTypes, resultTypes));

  // Insert AssignOp when an arguments or result of ConstantOp are directly
  // connected to ReturnOp.
  auto returnOp = func.front().getTerminator();
  builder.setInsertionPoint(returnOp);
  unsigned idx = 0;
  for (auto operand : returnOp->getOperands()) {
    if (operand.getKind() == Value::Kind::BlockArgument) {
      auto value = builder.create<AssignOp>(returnOp->getLoc(),
                                            operand.getType(), operand);
      returnOp->setOperand(idx, value);
    } else if (isa<ConstantOp>(operand.getDefiningOp())) {
      auto value = builder.create<AssignOp>(returnOp->getLoc(),
                                            operand.getType(), operand);
      returnOp->setOperand(idx, value);
    }
    ++idx;
  }
}

std::unique_ptr<Pass> scalehls::createLegalizeToHLSCppPass() {
  return std::make_unique<LegalizeToHLSCpp>();
}
