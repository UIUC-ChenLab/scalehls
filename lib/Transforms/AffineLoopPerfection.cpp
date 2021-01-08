//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/IR/IntegerSet.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct AffineLoopPerfection
    : public AffineLoopPerfectionBase<AffineLoopPerfection> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    // Walk through all loops.
    for (auto forOp : func.getOps<AffineForOp>()) {
      // Collect all loops that: (1) is the innermost loop (contains zero child
      // loop nest); or (2) contains more than one child loop nest.
      SmallVector<AffineForOp, 4> targetLoops;
      forOp.walk([&](AffineForOp loop) {
        if (getChildLoopNum(loop) != 1)
          targetLoops.push_back(loop);
      });

      // Apply loop perfection to each target loop.
      for (auto loop : targetLoops)
        applyAffineLoopPerfection(loop, builder);
    }
  }
};
} // namespace

/// Apply loop perfection to all outer loops of the input loop until the outer
/// operation is no longer a loop, or contains more than one child loop.
bool scalehls::applyAffineLoopPerfection(AffineForOp innermostLoop,
                                         OpBuilder &builder) {
  SmallVector<AffineForOp, 4> loops;
  loops.push_back(innermostLoop);

  while (true) {
    // Get the parent loop of the child loop.
    auto childLoop = loops.back();
    auto loop = childLoop.getParentOfType<AffineForOp>();

    // Break the procedure if the parent operation is no longer a loop.
    if (!loop)
      break;

    // Break if the parent loop contains more than one child loop.
    // TODO: how to handle this case? It seems possible.
    if (getChildLoopNum(loop) != 1)
      break;

    // Collect all operations before the child loop.
    SmallVector<Operation *, 4> frontOps;
    for (auto &op : loop.getBody()->getOperations()) {
      if (&op != childLoop)
        frontOps.push_back(&op);
      else
        break;
    }

    // All operations before the child loop should be moved to the innermost
    // loop, they are collected in frontOps.
    if (!frontOps.empty()) {
      // TODO: for now, we assume all users are inside of the current loop. This
      // is important because if any user is located at inner loops, it is
      // required to create a memref for holding the result.
      for (auto op : frontOps)
        for (auto user : op->getUsers())
          if (user->getParentOp() != loop)
            return true;

      // Create AffineIf in the front of the innermost loop.
      SmallVector<AffineExpr, 4> ifExprs;
      SmallVector<bool, 4> ifEqFlags;
      SmallVector<Value, 4> ifOperands;
      unsigned dim = 0;
      for (auto innerLoop : loops) {
        // Create all components required by constructing if operation.
        if (innerLoop.hasConstantLowerBound()) {
          ifExprs.push_back(builder.getAffineDimExpr(dim++) -
                            innerLoop.getConstantLowerBound());
          ifOperands.push_back(innerLoop.getInductionVar());
        } else {
          // Non-constant case requires to integrate the bound affine expression
          // and operands into the condition integer set.
          auto lowerExpr = innerLoop.getLowerBoundMap().getResult(0);
          auto lowerOperands = innerLoop.getLowerBoundOperands();
          SmallVector<AffineExpr, 4> newDims;
          for (unsigned i = 0, e = lowerOperands.size(); i < e; ++i)
            newDims.push_back(builder.getAffineDimExpr(i + dim + 1));
          lowerExpr = lowerExpr.replaceDimsAndSymbols(newDims, {});

          ifExprs.push_back(builder.getAffineDimExpr(dim++) - lowerExpr);
          ifOperands.push_back(innerLoop.getInductionVar());
          ifOperands.append(lowerOperands.begin(), lowerOperands.end());
          dim += lowerOperands.size();
        }
        ifEqFlags.push_back(true);
      }
      auto ifCondition = IntegerSet::get(dim, 0, ifExprs, ifEqFlags);

      // Set builder insertion point and create AffineIf operation.
      builder.setInsertionPointToStart(innermostLoop.getBody());
      auto ifOp =
          builder.create<AffineIfOp>(loop.getLoc(), ifCondition, ifOperands,
                                     /*withElseRegion=*/false);

      // Move all operations in frontOps into the innermost loop. Note that if
      // the operation has result, it will always be executed. However, if the
      // operation doesn't have result (e.g. AffineStore operation), it will be
      // putted into the generated AffineIf operation and conditionally
      // executed.
      for (auto op : frontOps) {
        if (op->getNumResults())
          op->moveBefore(ifOp);
        else
          op->moveBefore(ifOp.getThenBlock()->getTerminator());
      }
    }

    // Collect all operations after the inner loop.
    SmallVector<Operation *, 4> backOps;
    auto &opList = loop.getBody()->getOperations();
    for (auto opIt = opList.rbegin(); opIt != opList.rend(); ++opIt) {
      auto &op = *opIt;
      if (!isa<AffineYieldOp>(op)) {
        if (&op != childLoop.getOperation())
          backOps.push_back(&op);
        else
          break;
      }
    }

    // All operations after the inner loop should be moved to the
    // innermost loop, they are collected in backOps.
    if (!backOps.empty()) {
      // Create AffineIf in the back of the innermost loop (before the
      // terminator).
      SmallVector<AffineExpr, 4> ifExprs;
      SmallVector<bool, 4> ifEqFlags;
      SmallVector<Value, 4> ifOperands;
      unsigned dim = 0;
      for (auto innerLoop : loops) {
        // Create all components required by constructing if operation.
        if (innerLoop.hasConstantUpperBound()) {
          ifExprs.push_back(innerLoop.getConstantUpperBound() - 1 -
                            builder.getAffineDimExpr(dim++));
          ifOperands.push_back(innerLoop.getInductionVar());
        } else {
          // Non-constant case requires to integrate the bound affine expression
          // and operands into the condition integer set.
          auto upperExpr = innerLoop.getUpperBoundMap().getResult(0);
          auto upperOperands = innerLoop.getUpperBoundOperands();
          SmallVector<AffineExpr, 4> newDims;
          for (unsigned i = 0, e = upperOperands.size(); i < e; ++i)
            newDims.push_back(builder.getAffineDimExpr(i + dim + 1));
          upperExpr = upperExpr.replaceDimsAndSymbols(newDims, {});

          ifExprs.push_back(upperExpr - 1 - builder.getAffineDimExpr(dim++));
          ifOperands.push_back(innerLoop.getInductionVar());
          ifOperands.append(upperOperands.begin(), upperOperands.end());
          dim += upperOperands.size();
        }
        ifEqFlags.push_back(true);
      }
      auto ifCondition = IntegerSet::get(dim, 0, ifExprs, ifEqFlags);

      // Set builder insertion point and create AffineIf operation.
      builder.setInsertionPoint(innermostLoop.getBody()->getTerminator());
      auto ifOp =
          builder.create<AffineIfOp>(loop.getLoc(), ifCondition, ifOperands,
                                     /*withElseRegion=*/false);

      // Move all operations in backOps into the innermost loop. Note that if
      // the operation has result, it will always be executed. However, if the
      // operation doesn't have result (e.g. AffineStore operation), it will be
      // putted into the generated AffineIf operation and conditionally
      // executed.
      for (auto opIt = backOps.rbegin(); opIt < backOps.rend(); ++opIt) {
        auto op = *opIt;
        if (op->getNumResults())
          op->moveBefore(ifOp);
        else
          op->moveBefore(ifOp.getThenBlock()->getTerminator());
      }
    }

    // Push back the current loop as the new child loop.
    loops.push_back(loop);
  }

  // For now, this method will always success.
  return true;
}

std::unique_ptr<mlir::Pass> scalehls::createAffineLoopPerfectionPass() {
  return std::make_unique<AffineLoopPerfection>();
}
