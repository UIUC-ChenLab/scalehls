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
// ParamOp
//===----------------------------------------------------------------------===//

namespace {
struct SpecializeParamToConstant : public OpRewritePattern<ParamOp> {
  using OpRewritePattern<ParamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ParamOp op,
                                PatternRewriter &rewriter) const override {
    Attribute constValue;
    if (op.isCandidateConstrained()) {
      if (op.getCandidates().value().size() == 1)
        constValue = op.getCandidates().value()[0];

    } else if (op.isRangeConstrained()) {
      if (auto constLb = op.getLowerBound().dyn_cast<AffineConstantExpr>()) {
        auto ub = op.getUpperBound();
        auto diff = simplifyAffineExpr(ub - constLb, op.getNumOperands(), 0);
        if (auto constDiff = diff.dyn_cast<AffineConstantExpr>())
          if (constDiff.getValue() <= op.getStepAttr().getInt())
            constValue =
                Builder(op.getContext()).getIndexAttr(constLb.getValue());
      }
    }
    if (constValue) {
      for (auto getParam : op.getGetParamOps())
        rewriter.replaceOpWithNewOp<ConstParamOp>(getParam, op.getType(),
                                                  op.getKind(), constValue);
      rewriter.replaceOpWithNewOp<ConstParamOp>(op, op.getType(), op.getKind(),
                                                constValue);
      return success();
    }
    return failure();
  }
};
} // namespace

void ParamOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                          MLIRContext *context) {
  results.add<SpecializeParamToConstant>(context);
}

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
  if (auto uses = getSymbolUses(*this))
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
  auto param = table.lookupNearestSymbolFrom<ParamOp>(*this, getParamAttr());
  return success(param);
}

/// Get the parent require op.
RequireOp GetParamOp::getRequireOp() {
  return (*this)->getParentOfType<RequireOp>();
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
