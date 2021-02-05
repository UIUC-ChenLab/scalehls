//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

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
      if (auto bound = getBoundOfAffineBound(loop.getUpperBound())) {
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
        auto &ifBlock = ifOp.getThenBlock()->getOperations();
        auto &loopBlock = nestedLoops.back().getBody()->getOperations();
        ifBlock.splice(ifBlock.begin(), loopBlock, std::next(loopBlock.begin()),
                       std::prev(loopBlock.end(), 1));

        // Set constant variable bound.
        auto maximum = bound.getValue().second;
        loop.setConstantUpperBound(maximum);
      } else
        return false;
    }
  }
  return true;
}

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

std::unique_ptr<Pass> scalehls::createRemoveVariableBoundPass() {
  return std::make_unique<RemoveVariableBound>();
}
