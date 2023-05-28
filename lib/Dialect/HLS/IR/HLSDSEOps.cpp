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
using namespace affine;

//===----------------------------------------------------------------------===//
// SpaceOp
//===----------------------------------------------------------------------===//

SpacePackOp SpaceOp::getSpacePackOp() {
  return cast<SpacePackOp>(getBody().front().getTerminator());
}

//===----------------------------------------------------------------------===//
// SpacePackOp
//===----------------------------------------------------------------------===//

SpaceOp SpacePackOp::getSpaceOp() {
  return (*this)->getParentOfType<SpaceOp>();
}

//===----------------------------------------------------------------------===//
// SpaceSelectOp
//===----------------------------------------------------------------------===//

OpFoldResult SpaceSelectOp::fold(FoldAdaptor adaptor) {
  // For now, we always don't fold this to avoid losing the information of task
  // implementation.
  // if (getSpaces().size() == 1)
  //   return getSpaces()[0];
  return {};
}

//===----------------------------------------------------------------------===//
// ParamOp
//===----------------------------------------------------------------------===//

void ParamOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                          MLIRContext *context) {}

OpFoldResult ParamOp::fold(FoldAdaptor adaptor) {
  if (isRangeConstrained()) {
    auto bounds = getBounds().value();
    SmallVector<Value, 4> operands(getArgs());
    fullyComposeAffineMapAndOperands(&bounds, &operands);
    canonicalizeMapAndOperands(&bounds, &operands);
    setBoundsAttr(AffineMapAttr::get(bounds));
    getArgsMutable().assign(operands);
  }
  return {};
}

LogicalResult ParamOp::verify() { return success(); }

SmallVector<GetParamOp, 8> ParamOp::getGetParamOps() {
  SmallVector<GetParamOp, 8> users;
  if (auto uses = getSymbolUses((*this)->getParentOfType<ModuleOp>()))
    for (auto &use : uses.value()) {
      auto getParam = dyn_cast<GetParamOp>(use.getUser());
      assert(getParam && "param can only be used by get_param");
      users.push_back(getParam);
    }
  return users;
}

//===----------------------------------------------------------------------===//
// ConstParamOp
//===----------------------------------------------------------------------===//

LogicalResult ConstParamOp::verify() { return success(); }

OpFoldResult ConstParamOp::fold(FoldAdaptor adaptor) { return getValueAttr(); }

//===----------------------------------------------------------------------===//
// GetSpaceOp
//===----------------------------------------------------------------------===//

LogicalResult GetSpaceOp::verifySymbolUses(mlir::SymbolTableCollection &table) {
  auto param = table.lookupNearestSymbolFrom<SpaceOp>(
      (*this)->getParentOfType<ModuleOp>(), getNameAttr());
  if (!param)
    return (*this)->emitOpError("unknown space ") << getNameAttr();
  return success(param);
}

//===----------------------------------------------------------------------===//
// RequireOp
//===----------------------------------------------------------------------===//

LogicalResult RequireOp::verify() { return success(); }

/// Get the terminator condition op.
ConditionOp RequireOp::getConditionOp() {
  return cast<ConditionOp>(getBody().front().getTerminator());
}

//===----------------------------------------------------------------------===//
// GetParamOp
//===----------------------------------------------------------------------===//

LogicalResult GetParamOp::verify() { return success(); }

LogicalResult GetParamOp::verifySymbolUses(mlir::SymbolTableCollection &table) {
  auto param = table.lookupNearestSymbolFrom<ParamOp>(
      (*this)->getParentOfType<ModuleOp>(), getNameAttr());
  if (!param)
    return (*this)->emitOpError("unknown param ") << getNameAttr();
  return success(param);
}

//===----------------------------------------------------------------------===//
// ConditionOp
//===----------------------------------------------------------------------===//

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
