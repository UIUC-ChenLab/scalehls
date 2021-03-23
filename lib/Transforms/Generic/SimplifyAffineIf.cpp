//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineStructures.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/IntegerSet.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

/// Replace all occurrences of AffineExpr at position `pos` in `set` by the
/// defining AffineApplyOp expression and operands.
/// When `dimOrSymbolPosition < dims.size()`, AffineDimExpr@[pos] is replaced.
/// When `dimOrSymbolPosition >= dims.size()`,
/// AffineSymbolExpr@[pos - dims.size()] is replaced.
/// Mutate `set`,`dims` and `syms` in place as follows:
///   1. `dims` and `syms` are only appended to.
///   2. `set` dim and symbols are gradually shifted to higer positions.
///   3. Old `dim` and `sym` entries are replaced by nullptr
/// This avoids the need for any bookkeeping.
static LogicalResult replaceDimOrSym(IntegerSet *set,
                                     unsigned dimOrSymbolPosition,
                                     SmallVectorImpl<Value> &dims,
                                     SmallVectorImpl<Value> &syms) {
  bool isDimReplacement = (dimOrSymbolPosition < dims.size());
  unsigned pos = isDimReplacement ? dimOrSymbolPosition
                                  : dimOrSymbolPosition - dims.size();
  Value &v = isDimReplacement ? dims[pos] : syms[pos];
  if (!v)
    return failure();

  auto affineApply = v.getDefiningOp<AffineApplyOp>();
  if (!affineApply)
    return failure();

  // At this point we will perform a replacement of `v`, set the entry in `dim`
  // or `sym` to nullptr immediately.
  v = nullptr;

  // Compute the map, dims and symbols coming from the AffineApplyOp.
  AffineMap composeMap = affineApply.getAffineMap();
  assert(composeMap.getNumResults() == 1 && "affine.apply with >1 results");
  AffineExpr composeExpr =
      composeMap.shiftDims(dims.size()).shiftSymbols(syms.size()).getResult(0);
  ValueRange composeDims =
      affineApply.getMapOperands().take_front(composeMap.getNumDims());
  ValueRange composeSyms =
      affineApply.getMapOperands().take_back(composeMap.getNumSymbols());

  // Perform the replacement and append the dims and symbols where relevant.
  MLIRContext *ctx = set->getContext();
  AffineExpr toReplace = isDimReplacement ? getAffineDimExpr(pos, ctx)
                                          : getAffineSymbolExpr(pos, ctx);

  SmallVector<AffineExpr, 4> newConstraints;
  newConstraints.reserve(set->getNumConstraints());
  for (AffineExpr e : set->getConstraints())
    newConstraints.push_back(e.replace(toReplace, composeExpr));
  *set = IntegerSet::get(dims.size(), syms.size(), newConstraints,
                         set->getEqFlags());

  dims.append(composeDims.begin(), composeDims.end());
  syms.append(composeSyms.begin(), composeSyms.end());

  return success();
}

static void composeIntegerSetAndOperands(IntegerSet *set,
                                         SmallVectorImpl<Value> *operands) {
  MLIRContext *ctx = set->getContext();
  SmallVector<Value, 4> dims(operands->begin(),
                             operands->begin() + set->getNumDims());
  SmallVector<Value, 4> syms(operands->begin() + set->getNumDims(),
                             operands->end());

  // Iterate over dims and symbols coming from AffineApplyOp and replace until
  // exhaustion. This iteratively mutates `set`, `dims` and `syms`. Both `dims`
  // and `syms` can only increase by construction.
  // The implementation uses a `while` loop to support the case of symbols
  // that may be constructed from dims ;this may be overkill.
  while (true) {
    bool changed = false;
    for (unsigned pos = 0; pos != dims.size() + syms.size(); ++pos)
      if ((changed |= succeeded(replaceDimOrSym(set, pos, dims, syms))))
        break;
    if (!changed)
      break;
  }

  // Clear operands so we can fill them anew.
  operands->clear();

  // At this point we may have introduced null operands, prune them out before
  // canonicalizing set and operands.
  unsigned nDims = 0, nSyms = 0;
  SmallVector<AffineExpr, 4> dimReplacements, symReplacements;
  dimReplacements.reserve(dims.size());
  symReplacements.reserve(syms.size());
  for (auto *container : {&dims, &syms}) {
    bool isDim = (container == &dims);
    auto &repls = isDim ? dimReplacements : symReplacements;
    for (auto en : llvm::enumerate(*container)) {
      Value v = en.value();
      if (!v) {
        repls.push_back(getAffineConstantExpr(0, ctx));
        continue;
      }
      repls.push_back(isDim ? getAffineDimExpr(nDims++, ctx)
                            : getAffineSymbolExpr(nSyms++, ctx));
      operands->push_back(v);
    }
  }
  *set = set->replaceDimsAndSymbols(dimReplacements, symReplacements, nDims,
                                    nSyms);

  // Canonicalize and simplify before returning.
  canonicalizeSetAndOperands(set, operands);
}

static bool checkSameIfStatement(AffineIfOp lhsOp, AffineIfOp rhsOp) {
  if (lhsOp == nullptr || rhsOp == nullptr)
    return false;

  auto lhsIntegerSet = lhsOp.getIntegerSet();
  auto rhsIntegerSet = rhsOp.getIntegerSet();

  // TODO: support if statement with return values.
  if (lhsOp.getNumResults() != 0 || rhsOp.getNumResults() != 0 ||
      lhsOp.getNumOperands() != rhsOp.getNumOperands() ||
      lhsIntegerSet.getNumConstraints() != rhsIntegerSet.getNumConstraints())
    return false;

  // Check whether all operands are the same.
  auto lhsOperands = lhsOp.getOperands();
  auto rhsOperands = rhsOp.getOperands();
  unsigned operandIdx = 0;
  for (auto operand : lhsOperands)
    if (operand != rhsOperands[operandIdx++])
      return false;

  // Check whether constraint expressions are the same.
  auto lhsExprs = lhsIntegerSet.getConstraints();
  auto rhsExprs = rhsIntegerSet.getConstraints();
  unsigned exprIdx = 0;
  for (auto expr : lhsExprs)
    if (expr != rhsExprs[exprIdx++])
      return false;

  // Check whether equivalent flags are the same.
  auto lhsEqFlags = lhsIntegerSet.getEqFlags();
  auto rhsEqFlags = rhsIntegerSet.getEqFlags();
  unsigned eqFlagIdx = 0;
  for (auto flag : lhsEqFlags)
    if (flag != rhsEqFlags[eqFlagIdx++])
      return false;

  return true;
}

static bool applySimplifyAffineIf(FuncOp func) {
  SmallVector<AffineIfOp, 32> ifOpsToErase;

  // Remove redundant affine if statements.
  func.walk([&](mlir::AffineIfOp ifOp) {
    auto set = ifOp.getIntegerSet();
    auto operands = SmallVector<Value, 4>(ifOp.getOperands().begin(),
                                          ifOp.getOperands().end());

    // Compose all associated AffineApplyOp into the current if operation.
    while (llvm::any_of(operands, [](Value v) {
      return isa_and_nonnull<AffineApplyOp>(v.getDefiningOp());
    })) {
      composeIntegerSetAndOperands(&set, &operands);
    }

    // Replace the original integer set and operands with the composed integer
    // set and operands.
    ifOp.setIntegerSet(set);
    ifOp->setOperands(operands);

    // Construct the constraints of the if statement. For now, we only add the
    // loop induction constraints and integer set constraint.
    // TODO: handle unsuccessufl domain addition.
    FlatAffineConstraints constrs;
    constrs.addAffineIfOpDomain(ifOp);
    for (auto operand : operands)
      if (isForInductionVar(operand)) {
        auto iv = getForInductionVarOwner(operand);
        if (failed(constrs.addAffineForOpDomain(iv)))
          continue;
      }

    bool alwaysTrue = false;
    bool alwaysFalse = false;

    if (set.getNumInputs() == 0) {
      // If the integer set is pure constant set, determine whether the
      // condition is always true or always false.
      SmallVector<bool, 4> flagList;
      unsigned idx = 0;
      for (auto expr : set.getConstraints()) {
        bool eqFlag = set.isEq(idx++);
        auto constValue = expr.cast<AffineConstantExpr>().getValue();

        if (eqFlag)
          flagList.push_back(constValue == 0);
        else
          flagList.push_back(constValue >= 0);
      }

      // Only when all sub-conditions are met, the if statement is always true.
      // Otherwise, the statement if always false.
      if (llvm::all_of(flagList, [&](bool flag) { return flag; }))
        alwaysTrue = true;
      else
        alwaysFalse = true;

    } else if (constrs.isEmpty()) {
      // If there is no solution for the constraints, the condition will always
      // be false.
      alwaysFalse = true;
    }

    // Assert only one of the two flags are true.
    assert((!alwaysTrue || !alwaysFalse) && "unexpected if condition");

    if (alwaysFalse) {
      ifOpsToErase.push_back(ifOp);

      if (ifOp.hasElse()) {
        // Replace all uses of the if operation.
        auto yieldOp = ifOp.getElseBlock()->getTerminator();
        unsigned idx = 0;
        for (auto result : ifOp.getResults())
          result.replaceAllUsesWith(yieldOp->getOperand(idx++));

        // Move all operations except the terminator of the else block into the
        // parent block.
        if (&ifOp.getElseBlock()->front() != yieldOp) {
          auto &elseBlock = ifOp.getElseBlock()->getOperations();
          auto &parentBlock = ifOp->getBlock()->getOperations();
          parentBlock.splice(ifOp->getIterator(), elseBlock, elseBlock.begin(),
                             std::prev(elseBlock.end(), 1));
        }
      }
    }

    if (alwaysTrue) {
      ifOpsToErase.push_back(ifOp);

      // Replace all uses of the if operation.
      auto yieldOp = ifOp.getThenBlock()->getTerminator();
      unsigned idx = 0;
      for (auto result : ifOp.getResults())
        result.replaceAllUsesWith(yieldOp->getOperand(idx++));

      // Move all operations except the terminator of the else block into the
      // parent block.
      if (&ifOp.getThenBlock()->front() != yieldOp) {
        auto &thenBlock = ifOp.getThenBlock()->getOperations();
        auto &parentBlock = ifOp->getBlock()->getOperations();
        parentBlock.splice(ifOp->getIterator(), thenBlock, thenBlock.begin(),
                           std::prev(thenBlock.end(), 1));
      }
    }
  });

  for (auto ifOp : ifOpsToErase)
    ifOp.erase();
  ifOpsToErase.clear();

  // Merge if operations with the same statement.
  func.walk([&](Operation *op) {
    for (auto &region : op->getRegions())
      for (auto &block : region) {
        SmallVector<Operation *, 32> inBetweenOps;
        AffineIfOp lastIfOp;

        for (auto &op : block) {
          if (auto ifOp = dyn_cast<AffineIfOp>(op)) {
            // Check whether the operations between the current and the last if
            // operation are memory stores.
            // TODO: is this check enough?
            bool notMemoryStore = true;
            for (auto op : inBetweenOps)
              if (isa<AffineWriteOpInterface, memref::StoreOp>(op))
                notMemoryStore = false;

            // Only if the two if operations have identical statement while the
            // in between operations have no memory effect, the two if
            // operations can be merged.
            if (checkSameIfStatement(lastIfOp, ifOp) && notMemoryStore) {
              // Moving all operations in the last if operation to the current
              // one except the terminator.
              auto &lastIfBlock = lastIfOp.getBody()->getOperations();
              auto &ifBlock = ifOp.getBody()->getOperations();
              ifBlock.splice(ifBlock.begin(), lastIfBlock, lastIfBlock.begin(),
                             std::prev(lastIfBlock.end()));

              // Erase the last if operation in the end.
              ifOpsToErase.push_back(lastIfOp);
            }

            lastIfOp = ifOp;
            inBetweenOps.clear();
          } else
            inBetweenOps.push_back(&op);
        }
      }
  });

  for (auto ifOp : ifOpsToErase)
    ifOp.erase();
  return true;
}

namespace {
struct SimplifyAffineIf : public SimplifyAffineIfBase<SimplifyAffineIf> {
  void runOnOperation() override { applySimplifyAffineIf(getOperation()); }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSimplifyAffineIfPass() {
  return std::make_unique<SimplifyAffineIf>();
}
