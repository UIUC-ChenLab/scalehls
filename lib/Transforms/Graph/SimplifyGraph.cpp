//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct AllocOpRewritePattern : public OpRewritePattern<memref::AllocOp> {
  AllocOpRewritePattern(MLIRContext *context, DominanceInfo &DT)
      : OpRewritePattern(context), DT(DT) {}
  using OpRewritePattern<memref::AllocOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::AllocOp alloc,
                                PatternRewriter &rewriter) const override {
    // Check whether the alloc is the target memory of a copy op.
    memref::CopyOp copy;
    for (auto user : alloc->getUsers())
      if (auto copyUser = dyn_cast<memref::CopyOp>(user))
        if (alloc.memref() == copyUser.getTarget()) {
          copy = copyUser;
          break;
        }

    // If copy op is not found or any user of the copy source memory is not
    // dominating the copy op, which means the source memory is used after the
    // copy op, we cannot perform the rewriting.
    if (!copy ||
        llvm::any_of(copy.getSource().getUsers(), [&](Operation *user) {
          return !DT.dominates(user, copy);
        }))
      return failure();

    rewriter.replaceOp(alloc, copy.getSource());
    rewriter.eraseOp(copy);
    return success();
  }

private:
  DominanceInfo &DT;
};
} // namespace

namespace {
struct SimplifyGraph : public SimplifyGraphBase<SimplifyGraph> {
  void runOnOperation() override {
    auto module = getOperation();
    auto DT = DominanceInfo(module);

    mlir::RewritePatternSet patterns(module.getContext());
    patterns.add<AllocOpRewritePattern>(module.getContext(), DT);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSimplifyGraphPass() {
  return std::make_unique<SimplifyGraph>();
}
