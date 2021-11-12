//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "scalehls/Conversion/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

bool scalehls::applyLegalizeToHLSCpp(FuncOp func, bool isTopFunc) {
  auto builder = OpBuilder(func);

  // We constain functions to only contain one block.
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  // Set function pragma attributes.
  if (!getFuncDirective(func))
    setFuncDirective(func, false, 1, false, isTopFunc);

  // Walk through all operations in the function.
  SmallPtrSet<Value, 16> memrefs;
  func.walk([&](Operation *op) {
    // Collect all memrefs.
    for (auto operand : op->getOperands())
      if (operand.getType().isa<MemRefType>())
        memrefs.insert(operand);

    // Set loop directive attributes.
    if (auto forOp = dyn_cast<AffineForOp>(op)) {
      if (!getLoopDirective(forOp))
        setLoopDirective(forOp, false, 1, false, false, isLoopParallel(forOp));
    }
  });

  // Set array directives.
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
    if (operand.dyn_cast<BlockArgument>()) {
      auto value = builder.create<AssignOp>(returnOp->getLoc(),
                                            operand.getType(), operand);
      returnOp->setOperand(idx, value);
    } else if (isa<arith::ConstantOp>(operand.getDefiningOp())) {
      auto value = builder.create<AssignOp>(returnOp->getLoc(),
                                            operand.getType(), operand);
      returnOp->setOperand(idx, value);
    }
    ++idx;
  }

  return true;
}

namespace {
struct LegalizeToHLSCpp : public LegalizeToHLSCppBase<LegalizeToHLSCpp> {
public:
  void runOnOperation() override {
    auto func = getOperation();
    applyLegalizeToHLSCpp(func, func.getName() == topFunc);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeToHLSCppPass() {
  return std::make_unique<LegalizeToHLSCpp>();
}
