//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/IntegerSet.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct MergeAffineIf : public MergeAffineIfBase<MergeAffineIf> {
  void runOnOperation() override { applyMergeAffineIf(getOperation()); }
};
} // namespace

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

bool scalehls::applyMergeAffineIf(FuncOp func) {
  SmallVector<AffineIfOp, 32> ifOpsToErase;

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
              if (isa<AffineWriteOpInterface, StoreOp>(op))
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

std::unique_ptr<Pass> scalehls::createMergeAffineIfPass() {
  return std::make_unique<MergeAffineIf>();
}
