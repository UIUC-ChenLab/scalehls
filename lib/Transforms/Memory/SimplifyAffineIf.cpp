//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/AffineStructures.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Utils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct RemoveRedundantIf : public OpRewritePattern<AffineIfOp> {
  using OpRewritePattern<AffineIfOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineIfOp ifOp,
                                PatternRewriter &rewriter) const override {
    auto result = ifAlwaysTrueOrFalse(ifOp);

    bool hasChanged = false;
    if (result.second) {
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

    if (result.first) {
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
