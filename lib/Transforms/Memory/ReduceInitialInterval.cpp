//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Utils.h"
#include "scalehls/Transforms/Passes.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "scalehls-reduce-initial-interval"

using namespace mlir;
using namespace scalehls;

/// Find a chain of commutative operators starting from "headOps" and ended with
/// the "store". "headOps" is a list of single-use operations starting with "op"
/// that can be moved together during the transformation.
static bool findCommutativeChain(Operation *op, AffineWriteOpInterface store,
                                 SmallVectorImpl<Operation *> &headOps,
                                 SmallVectorImpl<Operation *> &chainOps) {
  assert((chainOps.empty() || op == chainOps.back()) && "invalid chaining");

  // Return true if we found the store op.
  if (llvm::any_of(op->getUsers(), [&](auto user) { return user == store; }))
    return true;

  for (auto user : op->getUsers()) {
    if (user->hasTrait<OpTrait::IsCommutative>() &&
        (chainOps.empty() || op->getName() == user->getName())) {
      LLVM_DEBUG(llvm::dbgs() << "Chain op: " << *user << "\n");

      chainOps.push_back(user);
      return findCommutativeChain(user, store, headOps, chainOps);
    }
  }

  if (op->hasOneUse()) {
    auto user = *op->user_begin();
    if (user->hasOneUse() && chainOps.empty()) {
      LLVM_DEBUG(llvm::dbgs() << "Head op: " << *user << "\n");

      headOps.push_back(user);
      return findCommutativeChain(user, store, headOps, chainOps);
    }
  }
  return false;
}

/// The rationale here is we transform the chain from this:
/// dst  1
///   \ /
///    +   2
///     \ /
///      +   3
///       \ /
///        +
///        |
///       src
///
/// To:
///  1   2
///   \ /
///    +   3
///     \ /
///      +  dst
///       \ /
///        +
///        |
///       src
///
/// In this way, the distance between the source store and destination
/// load is effectively reduced, such that potentially the initial
/// interval can be reduced as well.
/// TODO: It's possible to reshape the chain to a tree here.

/// "opsToMove" contains the operations to be moved along the "chain".
static bool optimizeCommutativeChain(SmallVectorImpl<Operation *> &headOps,
                                     SmallVectorImpl<Operation *> &chainOps,
                                     PatternRewriter &rewriter) {
  if (headOps.empty() || chainOps.empty())
    return false;

  // Get the first operator of the chain and the target operand to operate on.
  auto firstOp = *chainOps.begin();
  auto &targetOperand =
      firstOp->getOperand(0) == headOps.back()->getUses().begin()->get()
          ? firstOp->getOpOperand(1)
          : firstOp->getOpOperand(0);

  // Get the target operator the chain before which we can optimize.
  Operation *targetOp;
  for (auto op : chainOps)
    if (op == *std::prev(chainOps.end()) || !op->getResult(0).hasOneUse()) {
      targetOp = op;
      break;
    }
  if (targetOp == firstOp)
    return false;

  // Move the head ops and first commutative operator after the target operator.
  rewriter.setInsertionPointAfter(targetOp);
  for (auto op : headOps) {
    op->remove();
    rewriter.insert(op);
  }
  firstOp->remove();
  rewriter.insert(firstOp);

  // Reconnect the chain.
  firstOp->getResult(0).replaceAllUsesWith(targetOperand.get());
  targetOp->getResult(0).replaceAllUsesWith(firstOp->getResult(0));
  targetOperand.set(targetOp->getResult(0));
  return true;
}

namespace {
struct ReduceInitialIntervalPattern : public OpRewritePattern<AffineForOp> {
  using OpRewritePattern<AffineForOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineForOp loop,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    MemAccessesMap map;
    for (auto &op : *loop.getBody()) {
      if (isa<AffineReadOpInterface, AffineWriteOpInterface>(op))
        map[MemRefAccess(&op).memref].push_back(&op);
    }

    // Traverse all buffer accesses in the loop body.
    for (auto pair : map) {
      auto accesses = pair.second;

      // Only if a load depends on a dominated store (a back dependence), the
      // associated II constraint is possible to be optimized.
      for (unsigned i = 0, e = accesses.size(); i < e; ++i) {
        auto dstLoad = dyn_cast<AffineReadOpInterface>(accesses[i]);
        if (!dstLoad)
          continue;
        // To move the load op, we make a conservative assumption here that the
        // load op only has one use.
        if (!dstLoad->hasOneUse())
          break;
        LLVM_DEBUG(llvm::dbgs() << "\n==========Load: " << dstLoad << "\n");

        for (unsigned j = i + 1, e = accesses.size(); j < e; ++j) {
          auto srcStore = dyn_cast<AffineWriteOpInterface>(accesses[j]);
          if (!srcStore || MemRefAccess(srcStore) != MemRefAccess(dstLoad))
            continue;
          LLVM_DEBUG(llvm::dbgs() << "Store: " << srcStore << "\n");

          SmallVector<Operation *, 32> chainOps;
          SmallVector<Operation *, 4> headOps({dstLoad});
          if (findCommutativeChain(dstLoad, srcStore, headOps, chainOps))
            if (optimizeCommutativeChain(headOps, chainOps, rewriter)) {
              LLVM_DEBUG(llvm::dbgs() << "Optimize succeeded\n");
              hasChanged = true;
            }

          // We only consider the first dominated store op.
          break;
        }
      }
    }
    return success(hasChanged);
  }
};
} //  namespace

namespace {
struct ReduceInitialInterval
    : public ReduceInitialIntervalBase<ReduceInitialInterval> {
  void runOnOperation() override {
    auto func = getOperation();
    mlir::RewritePatternSet patterns(func.getContext());
    patterns.add<ReduceInitialIntervalPattern>(func.getContext());
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns),
                                       {false, true, 1});
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createReduceInitialIntervalPass() {
  return std::make_unique<ReduceInitialInterval>();
}
