//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/LoopUtils.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct RemoveVarLoopBound : public RemoveVarLoopBoundBase<RemoveVarLoopBound> {
  void runOnOperation() override;
};
} // namespace

void RemoveVarLoopBound::runOnOperation() {
  auto func = getOperation();
  auto builder = OpBuilder(func);

  // Walk through all functions and loops.
  for (auto forOp : func.getOps<mlir::AffineForOp>()) {
    SmallVector<mlir::AffineForOp, 4> nestedLoops;
    getPerfectlyNestedLoops(nestedLoops, forOp);

    SmallVector<Value, 4> inductionVars;
    for (auto loop : nestedLoops) {
      // TODO: support affine expression with more than one operand as
      // variable loop bound.
      // TODO: support remove variable lower bound.
      if (!loop.hasConstantUpperBound() &&
          loop.getUpperBoundMap().getResult(0).getKind() ==
              AffineExprKind::DimId) {
        auto val = loop.getUpperBoundOperands()[0];

        // For now, only if the variable bound is the induction variable of
        // one of the outer loops, the removal is possible.
        unsigned idx = 0;
        for (auto inductionVar : inductionVars) {
          if (val == inductionVar) {
            if (nestedLoops[idx].hasConstantUpperBound()) {
              // Set new constant loop bound.
              auto maximum = nestedLoops[idx].getConstantUpperBound();
              loop.setConstantUpperBound(maximum);

              // Collect all components for creating AffineIf operation.
              auto ifExpr = getAffineDimExpr(0, func.getContext()) -
                            getAffineDimExpr(1, func.getContext()) -
                            getAffineConstantExpr(1, func.getContext());
              auto ifCondition =
                  IntegerSet::get(2, 0, ifExpr, /*eqFlags=*/false);

              // Create AffineIf operation in the front of the innermost
              // perfect loop.
              builder.setInsertionPointToStart(nestedLoops.back().getBody());
              auto ifOp = builder.create<mlir::AffineIfOp>(
                  func.getLoc(), ifCondition,
                  ArrayRef<Value>({val, loop.getInductionVar()}),
                  /*withElseRegion*/ false);

              // Move all operations in the innermost perfect loop into the
              // new created AffineIf region.
              auto &ifBlock = ifOp.getBody()->getOperations();
              auto &loopBlock = nestedLoops.back().getBody()->getOperations();
              ifBlock.splice(ifBlock.begin(), loopBlock,
                             std::next(loopBlock.begin()),
                             std::prev(loopBlock.end(), 1));
            }
          }
          idx += 1;
        }
      }
      inductionVars.push_back(loop.getInductionVar());
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createRemoveVarLoopBoundPass() {
  return std::make_unique<RemoveVarLoopBound>();
}
