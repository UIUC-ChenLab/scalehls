//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Transforms/Passes.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/LoopUtils.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct RemoveVariableBound
    : public RemoveVariableBoundBase<RemoveVariableBound> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    // Walk through all loops.
    for (auto loop : func.getOps<AffineForOp>())
      applyRemoveVariableBound(loop, builder);
  }
};
} // namespace

static Optional<std::pair<int64_t, int64_t>>
getBoundOfAffineBound(AffineBound bound, MLIRContext *context) {
  // For now, we can only handle one result affine bound.
  if (bound.getMap().getNumResults() != 1)
    return Optional<std::pair<int64_t, int64_t>>();

  SmallVector<int64_t, 4> lbs;
  SmallVector<int64_t, 4> ubs;
  for (auto operand : bound.getOperands()) {
    // Only if the affine bound operands are induction variable, the calculation
    // is possible.
    if (!isForInductionVar(operand))
      return Optional<std::pair<int64_t, int64_t>>();

    // Only if the owner for op of the induction variable has constant bound,
    // the calculation is possible.
    auto ifOp = getForInductionVarOwner(operand);
    if (!ifOp.hasConstantBounds())
      return Optional<std::pair<int64_t, int64_t>>();

    auto lb = ifOp.getConstantLowerBound();
    auto ub = ifOp.getConstantUpperBound();
    auto step = ifOp.getStep();

    lbs.push_back(lb);
    ubs.push_back(ub - 1 - (ub - 1 - lb) % step);
  }

  // TODO: maybe a more efficient algorithm.
  auto operandNum = bound.getNumOperands();
  SmallVector<int64_t, 16> results;
  for (unsigned i = 0, e = pow(2, operandNum); i < e; ++i) {
    SmallVector<AffineExpr, 4> replacements;
    for (unsigned pos = 0; pos < operandNum; ++pos) {
      if (i >> pos % 2 == 0)
        replacements.push_back(getAffineConstantExpr(lbs[pos], context));
      else
        replacements.push_back(getAffineConstantExpr(ubs[pos], context));
    }
    auto newExpr =
        bound.getMap().getResult(0).replaceDimsAndSymbols(replacements, {});

    if (auto constExpr = newExpr.dyn_cast<AffineConstantExpr>())
      results.push_back(constExpr.getValue());
    else
      return Optional<std::pair<int64_t, int64_t>>();
  }

  auto minmax = std::minmax_element(results.begin(), results.end());
  return std::pair<int64_t, int64_t>(*minmax.first, *minmax.second);
}

/// Apply remove variable bound to all inner loops of the input loop.
bool scalehls::applyRemoveVariableBound(AffineForOp loop, OpBuilder &builder) {
  SmallVector<AffineForOp, 4> nestedLoops;
  getPerfectlyNestedLoops(nestedLoops, loop);

  // Recursively apply remove variable bound for all child loops of the
  // innermost loop of nestedLoops.
  for (auto childLoop : nestedLoops.back().getOps<AffineForOp>())
    if (applyRemoveVariableBound(childLoop, builder))
      continue;
    else
      return false;

  // Remove all vairable loop bound if possible.
  for (auto loop : nestedLoops) {
    // TODO: support remove variable lower bound.
    if (!loop.hasConstantUpperBound()) {
      // TODO: support variable upper bound with more than one result in the
      // getBoundOfAffineBound() method.
      if (auto bound = getBoundOfAffineBound(loop.getUpperBound(),
                                             builder.getContext())) {
        // Collect all components for creating AffineIf operation.
        auto upperMap = loop.getUpperBoundMap();
        auto ifExpr = upperMap.getResult(0) -
                      builder.getAffineDimExpr(upperMap.getNumDims()) - 1;
        auto ifCondition = IntegerSet::get(upperMap.getNumDims() + 1, 0, ifExpr,
                                           /*eqFlags=*/false);
        auto ifOperands = SmallVector<Value, 4>(loop.getUpperBoundOperands());
        ifOperands.push_back(loop.getInductionVar());

        // Create if operation in the front of the innermost perfect loop.
        builder.setInsertionPointToStart(nestedLoops.back().getBody());
        auto ifOp =
            builder.create<AffineIfOp>(loop.getLoc(), ifCondition, ifOperands,
                                       /*withElseRegion=*/false);

        // Move all operations in the innermost perfect loop into the new
        // created AffineIf region.
        auto &ifBlock = ifOp.getBody()->getOperations();
        auto &loopBlock = nestedLoops.back().getBody()->getOperations();
        ifBlock.splice(ifBlock.begin(), loopBlock, std::next(loopBlock.begin()),
                       std::prev(loopBlock.end(), 1));

        // Set constant variable bound.
        auto maximum = bound.getValue().second;
        loop.setConstantUpperBound(maximum);
      }
    }
  }

  // For now, this method will always success.
  return true;
}

std::unique_ptr<Pass> scalehls::createRemoveVariableBoundPass() {
  return std::make_unique<RemoveVariableBound>();
}
