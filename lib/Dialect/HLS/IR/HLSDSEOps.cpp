//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/IntegerSet.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// DSE Operations
//===----------------------------------------------------------------------===//

LogicalResult ParamOp::verify() { return success(); }

/// Get all constraints of the parameter.
SmallVector<Operation *> getConstraints() { return SmallVector<Operation *>(); }

LogicalResult RequireOp::verify() { return success(); }

/// Get the terminator condition op.
ConditionOp RequireOp::getConditionOp() {
  return cast<ConditionOp>(getBody().front().getTerminator());
}

LogicalResult GetParamOp::verify() { return success(); }

LogicalResult GetParamOp::verifySymbolUses(mlir::SymbolTableCollection &table) {
  auto param = table.lookupNearestSymbolFrom<ParamOp>(*this, getParamAttr());
  return success(param);
}

/// Get the parent require op.
RequireOp GetParamOp::getRequireOp() {
  return (*this)->getParentOfType<RequireOp>();
}

void ConditionOp::build(OpBuilder &builder, OperationState &result,
                        IntegerSet set, ValueRange args) {
  result.addOperands(args);
  result.addAttribute(getConditionAttrStrName(), IntegerSetAttr::get(set));
}

LogicalResult ConditionOp::verify() { return success(); }

/// Get the parent require op.
RequireOp ConditionOp::getRequireOp() {
  return (*this)->getParentOfType<RequireOp>();
}

IntegerSet ConditionOp::getIntegerSet() {
  return (*this)
      ->getAttrOfType<IntegerSetAttr>(getConditionAttrStrName())
      .getValue();
}

void ConditionOp::setIntegerSet(IntegerSet newSet) {
  (*this)->setAttr(getConditionAttrStrName(), IntegerSetAttr::get(newSet));
}

/// Sets the integer set with its operands.
void ConditionOp::setConditional(IntegerSet set, ValueRange operands) {
  setIntegerSet(set);
  getArgsMutable().assign(operands);
}
