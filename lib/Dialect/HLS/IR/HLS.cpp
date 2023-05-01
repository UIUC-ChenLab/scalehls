//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/IntegerSet.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// HLS dialect
//===----------------------------------------------------------------------===//

void HLSDialect::initialize() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "scalehls/Dialect/HLS/IR/HLSOpsTypes.cpp.inc"
      >();

  addAttributes<
#define GET_ATTRDEF_LIST
#include "scalehls/Dialect/HLS/IR/HLSOpsAttributes.cpp.inc"
      >();

  addOperations<
#define GET_OP_LIST
#include "scalehls/Dialect/HLS/IR/HLSOps.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// Affine SelectOp
//===----------------------------------------------------------------------===//

void AffineSelectOp::build(OpBuilder &builder, OperationState &result,
                           IntegerSet set, ValueRange args, Value trueValue,
                           Value falseValue) {
  assert(trueValue.getType() == falseValue.getType() &&
         "true and false must have the same type");
  result.addTypes(trueValue.getType());
  result.addOperands(args);
  result.addOperands(trueValue);
  result.addOperands(falseValue);
  result.addAttribute(getConditionAttrStrName(), IntegerSetAttr::get(set));
}

namespace {
struct AlwaysTrueOrFalseSelect : public OpRewritePattern<AffineSelectOp> {
  using OpRewritePattern<AffineSelectOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineSelectOp op,
                                PatternRewriter &rewriter) const override {
    auto set = op.getIntegerSet();
    bool alwaysTrue = false;
    bool alwaysFalse = false;

    if (set.isEmptyIntegerSet())
      alwaysFalse = true;

    else if (set.getNumInputs() == 0) {
      SmallVector<bool, 4> flagList;
      for (auto expr : llvm::enumerate(set.getConstraints())) {
        auto constValue = expr.value().cast<AffineConstantExpr>().getValue();
        flagList.push_back(set.isEq(expr.index()) ? constValue == 0
                                                  : constValue >= 0);
      }
      alwaysTrue = llvm::all_of(flagList, [](bool flag) { return flag; });
      alwaysFalse = !alwaysTrue;

    } else {
      // Create the base constraints from the integer set attached to
      // SelectOp.
      FlatAffineValueConstraints constrs(set);

      // Bind vars in the constraints to SelectOp args.
      auto args = SmallVector<Value, 4>(op.getArgs());
      constrs.setValues(0, constrs.getNumDimAndSymbolVars(), args);

      // Add induction variable constraints.
      for (auto arg : args)
        if (isAffineForInductionVar(arg))
          (void)constrs.addAffineForOpDomain(getForInductionVarOwner(arg));

      // Always false if there's no known solution for the constraints.
      alwaysFalse = constrs.isEmpty();
    }

    // Replace uses if always-false or true is proved.
    if (alwaysFalse)
      rewriter.replaceOp(op, op.getFalseValue());
    else if (alwaysTrue)
      rewriter.replaceOp(op, op.getTrueValue());
    else
      return failure();
    return success();
  }
};
} // namespace

void AffineSelectOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                                 MLIRContext *context) {
  results.add<AlwaysTrueOrFalseSelect>(context);
}

/// Canonicalize an affine if op's conditional (integer set + operands).
OpFoldResult AffineSelectOp::fold(FoldAdaptor adaptor) {
  auto set = getIntegerSet();
  SmallVector<Value, 4> operands(getArgs());
  composeSetAndOperands(set, operands);
  canonicalizeSetAndOperands(&set, &operands);
  return {};
}

LogicalResult AffineSelectOp::verify() {
  // Verify that we have a condition attribute.
  // FIXME: This should be specified in the arguments list in ODS.
  auto conditionAttr =
      (*this)->getAttrOfType<IntegerSetAttr>(getConditionAttrStrName());
  if (!conditionAttr)
    return emitOpError("requires an integer set attribute named 'condition'");

  // Verify that there are enough operands for the condition.
  IntegerSet condition = conditionAttr.getValue();
  if (getArgs().size() != condition.getNumInputs())
    return emitOpError("operand count and condition integer set dimension and "
                       "symbol count must match");

  // Verify that the operands are valid dimension/symbols.
  unsigned opIt = 0;
  for (auto operand : getArgs()) {
    if (opIt++ < condition.getNumDims()) {
      if (!isValidDim(operand, getAffineScope(*this)))
        return emitOpError("operand cannot be used as a dimension id");
    } else if (!isValidSymbol(operand, getAffineScope(*this))) {
      return emitOpError("operand cannot be used as a symbol");
    }
  }
  return success();
}

ParseResult AffineSelectOp::parse(OpAsmParser &parser, OperationState &result) {
  // Parse the condition attribute set.
  IntegerSetAttr conditionAttr;
  unsigned numDims;
  if (parser.parseAttribute(conditionAttr,
                            AffineSelectOp::getConditionAttrStrName(),
                            result.attributes) ||
      parseDimAndSymbolList(parser, result.operands, numDims))
    return failure();

  // Verify the condition operands.
  auto set = conditionAttr.getValue();
  if (set.getNumDims() != numDims)
    return parser.emitError(
        parser.getNameLoc(),
        "dim operand count and integer set dim count must match");
  if (numDims + set.getNumSymbols() != result.operands.size())
    return parser.emitError(
        parser.getNameLoc(),
        "symbol operand count and integer set symbol count must match");

  SmallVector<OpAsmParser::UnresolvedOperand, 4> values;
  SMLoc valuesLoc = parser.getCurrentLocation();
  Type resultType;
  if (parser.parseOperandList(values) ||
      parser.parseOptionalAttrDict(result.attributes) ||
      parser.parseColonType(resultType))
    return failure();
  result.types.push_back(resultType);

  if (values.size() != 2)
    return parser.emitError(valuesLoc, "should only have two input values");
  if (parser.resolveOperands(values, {resultType, resultType}, valuesLoc,
                             result.operands))
    return failure();
  return success();
}

void AffineSelectOp::print(OpAsmPrinter &p) {
  auto conditionAttr =
      (*this)->getAttrOfType<IntegerSetAttr>(getConditionAttrStrName());
  p << " " << conditionAttr;
  printDimAndSymbolList(getArgs().begin(), getArgs().end(),
                        conditionAttr.getValue().getNumDims(), p);

  p << " ";
  p.printOperand(getTrueValue());
  p << ", ";
  p.printOperand(getFalseValue());
  p << " : ";
  p.printType(getType());

  // Print the attribute list.
  p.printOptionalAttrDict((*this)->getAttrs(),
                          /*elidedAttrs=*/getConditionAttrStrName());
}

IntegerSet AffineSelectOp::getIntegerSet() {
  return (*this)
      ->getAttrOfType<IntegerSetAttr>(getConditionAttrStrName())
      .getValue();
}

void AffineSelectOp::setIntegerSet(IntegerSet newSet) {
  (*this)->setAttr(getConditionAttrStrName(), IntegerSetAttr::get(newSet));
}

/// Sets the integer set with its operands.
void AffineSelectOp::setConditional(IntegerSet set, ValueRange operands) {
  setIntegerSet(set);
  getArgsMutable().assign(operands);
}

//===----------------------------------------------------------------------===//
// Include tablegen classes
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/IR/HLSOpsDialect.cpp.inc"
#include "scalehls/Dialect/HLS/IR/HLSOpsEnums.cpp.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsAttributes.cpp.inc"

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsTypes.cpp.inc"

#include "scalehls/Dialect/HLS/IR/HLSOpsInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOps.cpp.inc"
