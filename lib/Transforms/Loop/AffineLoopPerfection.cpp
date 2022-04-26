//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/IR/IntegerSet.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// Apply loop perfection. Try to sink all operations between loop statements
/// into the innermost loop of the input loop band.
bool scalehls::applyAffineLoopPerfection(AffineLoopBand &band) {
  assert(!band.empty() && "no loops provided");

  auto innermostLoop = band.back();
  auto builder = OpBuilder(innermostLoop);

  for (unsigned i = band.size() - 1; i > 0; --i) {
    // Get the current loop and the child loop.
    auto loop = band[i - 1];
    auto childLoop = band[i];

    // If any prefix operation is consumed by users in the child loop, we need
    // to buffer the result in a memory on stack such that the users can fetch
    // the correct data from the stack.
    for (auto &op : llvm::make_early_inc_range(loop.getOps())) {
      if (&op == childLoop)
        break;
      for (auto result : op.getResults())
        if (llvm::any_of(result.getUsers(), [&](Operation *user) {
              return childLoop->isProperAncestor(user);
            })) {
          auto type = MemRefType::get({1}, result.getType());
          auto map = builder.getConstantAffineMap(0);

          builder.setInsertionPoint(band.front());
          auto alloc = builder.create<memref::AllocOp>(loop.getLoc(), type);
          builder.setInsertionPointAfter(&op);
          builder.create<AffineStoreOp>(loop.getLoc(), result, alloc, map,
                                        ValueRange({}));

          for (auto &use : llvm::make_early_inc_range(result.getUses())) {
            if (!childLoop->isProperAncestor(use.getOwner()))
              continue;
            builder.setInsertionPoint(use.getOwner());
            auto load = builder.create<AffineLoadOp>(loop.getLoc(), alloc, map,
                                                     ValueRange({}));
            use.set(load);
          }
        }
    }

    // Collect all operations before and after the child loop.
    SmallVector<Operation *, 4> prefixOps;
    SmallVector<Operation *, 4> suffixOps;
    bool isPrefix = true;
    for (auto &op : loop.getOps()) {
      // TODO: For now, any operations that generate memrefs should have been
      // hoisted. Otherwise, the perfection cannot be done.
      if (llvm::any_of(op.getResultTypes(),
                       [](Type type) { return type.isa<MemRefType>(); }))
        return false;

      // TODO: Fow now, call ops are always not be perfectized.
      if (isa<func::CallOp>(op))
        return false;

      if (&op == childLoop) {
        isPrefix = false;
        continue;
      }
      if (isPrefix)
        prefixOps.push_back(&op);
      else if (!isa<AffineYieldOp>(op))
        suffixOps.push_back(&op);
    }

    // Handle prefix operations.
    if (!prefixOps.empty()) {
      // Construct the condition of the if statement.
      SmallVector<AffineExpr, 4> ifExprs;
      SmallVector<bool, 4> ifEqFlags;
      SmallVector<Value, 4> ifOperands;
      unsigned dim = 0;
      for (auto innerLoop : llvm::drop_begin(band, i)) {
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

      // Move all operations before the child loop to the innermost loop.
      auto destOp = &innermostLoop.front();
      for (auto op : prefixOps) {
        if (isa<AffineWriteOpInterface, vector::TransferWriteOp>(op)) {
          // FIXME: Now we only consider affine store operations.
          builder.setInsertionPoint(destOp);
          auto ifOp = builder.create<AffineIfOp>(
              loop.getLoc(), ifCondition, ifOperands, /*withElseRegion=*/false);
          op->moveBefore(ifOp.getThenBlock()->getTerminator());
        } else
          op->moveBefore(destOp);
      }
    }

    // Handle suffix operations.
    if (!suffixOps.empty()) {
      // Construct the condition of the if statement.
      SmallVector<AffineExpr, 4> ifExprs;
      SmallVector<bool, 4> ifEqFlags;
      SmallVector<Value, 4> ifOperands;
      unsigned dim = 0;
      for (auto innerLoop : llvm::drop_begin(band, i)) {
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

      // Move all operations after the child loop to the innermost loop.
      auto destOp = innermostLoop.getBody()->getTerminator();
      for (auto op : suffixOps) {
        if (isa<AffineWriteOpInterface, vector::TransferWriteOp>(op)) {
          // FIXME: Now we only consider affine store operations.
          builder.setInsertionPoint(destOp);
          auto ifOp = builder.create<AffineIfOp>(
              loop.getLoc(), ifCondition, ifOperands, /*withElseRegion=*/false);
          op->moveBefore(ifOp.getThenBlock()->getTerminator());
        } else
          op->moveBefore(destOp);
      }
    }
  }
  return true;
}

namespace {
struct AffineLoopPerfection
    : public AffineLoopPerfectionBase<AffineLoopPerfection> {
  void runOnOperation() override {
    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(getOperation().front(), targetBands);

    // Apply loop order optimization to each loop band.
    for (auto &band : targetBands)
      applyAffineLoopPerfection(band);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createAffineLoopPerfectionPass() {
  return std::make_unique<AffineLoopPerfection>();
}
