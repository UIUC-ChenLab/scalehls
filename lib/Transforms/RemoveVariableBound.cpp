//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/LoopUtils.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct RemoveVariableBound : public RemoveVariableBoundBase<RemoveVariableBound> {
  void runOnOperation() override;
};
} // namespace

void RemoveVariableBound::runOnOperation() {
  auto func = getOperation();
  auto builder = OpBuilder(func);

  // Walk through all functions and loops.
  for (auto forOp : func.getOps<mlir::AffineForOp>()) {
    SmallVector<mlir::AffineForOp, 4> nestedLoops;
    // TODO: support imperfect loops.
    getPerfectlyNestedLoops(nestedLoops, forOp);

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
          auto ifCondition = IntegerSet::get(upperMap.getNumDims() + 1, 0,
                                             ifExpr, /*eqFlags=*/false);
          auto ifOperands = SmallVector<Value, 4>(loop.getUpperBoundOperands());
          ifOperands.push_back(loop.getInductionVar());

          // Create if operation in the front of the innermost perfect loop.
          builder.setInsertionPointToStart(nestedLoops.back().getBody());
          auto ifOp = builder.create<mlir::AffineIfOp>(
              func.getLoc(), ifCondition, ifOperands,
              /*withElseRegion=*/false);

          // Move all operations in the innermost perfect loop into the
          // new created AffineIf region.
          auto &ifBlock = ifOp.getBody()->getOperations();
          auto &loopBlock = nestedLoops.back().getBody()->getOperations();
          ifBlock.splice(ifBlock.begin(), loopBlock,
                         std::next(loopBlock.begin()),
                         std::prev(loopBlock.end(), 1));

          // Set constant variable bound.
          auto maximum = bound.getValue().second;
          loop.setConstantUpperBound(maximum);
        }
      }
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createRemoveVariableBoundPass() {
  return std::make_unique<RemoveVariableBound>();
}
