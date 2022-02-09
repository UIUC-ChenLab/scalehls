//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Support/Utils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

static bool findCommutativeChain(mlir::AffineStoreOp store,
                                 SmallVectorImpl<Operation *> &chain) {
  auto op = chain.back();
  if (store == op)
    return true;

  if (!isa<arith::AddIOp, arith::AddFOp, arith::MulIOp, arith::MulFOp,
           arith::MaxUIOp, arith::MaxSIOp, arith::MaxFOp, arith::MinUIOp,
           arith::MinSIOp, arith::MinFOp, arith::AndIOp, arith::OrIOp,
           arith::XOrIOp, mlir::AffineLoadOp>(op))
    return false;

  for (auto user : op->getUsers()) {
    chain.push_back(user);
    if (findCommutativeChain(store, chain))
      return true;
    chain.pop_back();
  }
  return false;
}

namespace {
struct ReduceInitialIntervalPattern : public OpRewritePattern<AffineForOp> {
  using OpRewritePattern<AffineForOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineForOp loop,
                                PatternRewriter &rewriter) const override {
    MemAccessesMap map;
    for (auto &op : *loop.getBody()) {
      if (isa<mlir::AffineLoadOp, mlir::AffineStoreOp>(op))
        map[MemRefAccess(&op).memref].push_back(&op);
    }

    // Traverse all buffer accesses in the loop body.
    for (auto pair : map) {
      auto accesses = pair.second;

      // Only if a load depends on a dominated store (a back dependence), the
      // associated II constraint is possible to be optimized.
      for (unsigned i = 0, e = accesses.size(); i < e; ++i) {
        auto dstLoad = dyn_cast<mlir::AffineLoadOp>(accesses[i]);
        if (!dstLoad)
          continue;
        for (unsigned j = i + 1, e = accesses.size(); j < e; ++j) {
          auto srcStore = dyn_cast<mlir::AffineStoreOp>(accesses[j]);
          if (!srcStore || MemRefAccess(srcStore) != MemRefAccess(dstLoad))
            continue;

          // The rationale here is we transform the chain from this:
          // dst  1
          //   \ /
          //    +   2
          //     \ /
          //      +   3
          //       \ /
          //        +
          //        |
          //       src
          //
          // To:
          //  1   2
          //   \ /
          //    +   3
          //     \ /
          //      +  dst
          //       \ /
          //        +
          //        |
          //       src
          //
          // In this way, the distance between the source store and destination
          // load is effectively reduced, such that potentially the initial
          // interval can be reduced as well.
          // TODO: It's possible to reshape the chain to a tree here.

          // Create a op chain started from the load. If the chain only contains
          // one commutative operator, there's no space for optimization.
          SmallVector<Operation *, 32> chain({dstLoad});
          if (!findCommutativeChain(srcStore, chain) || chain.size() == 3)
            continue;
          assert(chain.front() == dstLoad && chain.back() == srcStore &&
                 "incorrect commutative chain");

          // Get the target operator the chain before which we can optimize.
          Operation *targetOperator;
          for (auto op : chain)
            if (op == *std::prev(chain.end(), 2) ||
                !llvm::hasSingleElement(op->getResult(0).getUsers())) {
              targetOperator = op;
              break;
            }

          // Get the first operator of the chain and the first operand.
          auto headOperator = *std::next(chain.begin());
          if (targetOperator == headOperator || targetOperator == dstLoad)
            continue;
          auto &headOperand = headOperator->getOperand(0) != dstLoad.result()
                                  ? headOperator->getOpOperand(0)
                                  : headOperator->getOpOperand(1);

          // Move the load and first commutative operator before the first user
          // of the target operator.
          // TODO: Should be moved before the first user.
          rewriter.setInsertionPointAfter(targetOperator);
          dstLoad->remove();
          rewriter.insert(dstLoad);
          headOperator->remove();
          rewriter.insert(headOperator);

          // Reconnect the chain.
          headOperator->getResult(0).replaceAllUsesWith(headOperand.get());
          targetOperator->getResult(0).replaceAllUsesWith(
              headOperator->getResult(0));
          headOperand.set(targetOperator->getResult(0));

          // We only consider the immediate dominated store op.
          break;
        }
      }
    }

    return success();
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
