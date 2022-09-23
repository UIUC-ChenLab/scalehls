//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/AffineStructures.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Support/Utils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct RemoveRedundantIf : public OpRewritePattern<mlir::AffineIfOp> {
  using OpRewritePattern<mlir::AffineIfOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(mlir::AffineIfOp ifOp,
                                PatternRewriter &rewriter) const override {
    auto set = ifOp.getIntegerSet();
    auto operands = SmallVector<Value, 4>(ifOp.getOperands().begin(),
                                          ifOp.getOperands().end());

    // Compose all associated AffineApplyOp into the current if operation.
    while (llvm::any_of(operands, [](Value v) {
      return isa_and_nonnull<AffineApplyOp>(v.getDefiningOp());
    })) {
      composeSetAndOperands(set, operands);
    }

    // Replace the original integer set and operands with the composed integer
    // set and operands.
    ifOp.setIntegerSet(set);
    ifOp->setOperands(operands);

    // Construct the constraints of the if statement. For now, we only add the
    // loop induction constraints and integer set constraint.
    // TODO: handle unsuccessufl domain addition.
    FlatAffineValueConstraints constrs;
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

    bool hasChanged = false;
    if (alwaysFalse) {
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
      rewriter.eraseOp(ifOp);
      hasChanged = true;
    }

    if (alwaysTrue) {
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
      rewriter.eraseOp(ifOp);
      hasChanged = true;
    }
    return success(hasChanged);
  }
};
} // namespace

bool scalehls::checkSameIfStatement(AffineIfOp lhsOp, AffineIfOp rhsOp) {
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

namespace {
/// FIXME: More conprehensive intervening operation analysis.
struct MergeSameIf : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    // Merge if operations with the same statement.
    SmallVector<AffineIfOp, 32> ifOpsToErase;
    func.walk([&](Block *block) {
      SmallVector<Operation *, 32> inBetweenOps;
      AffineIfOp lastIfOp;

      for (auto &op : block->getOperations()) {
        if (auto ifOp = dyn_cast<AffineIfOp>(op)) {
          // Check whether the operations between the current and the last if
          // operation are memory stores.
          // TODO: is this check enough?
          bool notMemoryStore = true;
          for (auto op : inBetweenOps)
            if (isa<AffineWriteOpInterface, vector::TransferWriteOp>(op))
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
    });
    for (auto ifOp : ifOpsToErase)
      ifOp.erase();
    return success(!ifOpsToErase.empty());
  }
};
} // namespace

static bool applySimplifyAffineIf(func::FuncOp func) {
  auto context = func.getContext();

  mlir::RewritePatternSet patterns(context);
  patterns.add<RemoveRedundantIf>(context);
  patterns.add<MergeSameIf>(context);
  (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
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
