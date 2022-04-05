//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct TokenCreatePattern : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    auto loc = rewriter.getUnknownLoc();

    for (auto node :
         llvm::make_early_inc_range(func.getOps<DataflowNodeOp>())) {
      // Collect consumers of the current node. For each consumer, we only need
      // to create one token flow.
      llvm::SmallDenseSet<Operation *, 4> consumers;
      for (auto &use : llvm::make_early_inc_range(node->getUses())) {
        // Skip non-tensor, buffer, and terminator users.
        if (isa<DataflowBufferOp>(use.getOwner()) ||
            !use.get().getType().isa<TensorType>() ||
            use.getOwner() == use.getOwner()->getBlock()->getTerminator())
          continue;

        if (auto consumer = use.getOwner()->getParentOfType<DataflowNodeOp>())
          consumers.insert(consumer);
        else
          return use.getOwner()->emitOpError(
              "doesn't have parent dataflow node");
      }

      // Create token source and sink operations.
      SmallVector<Operation *, 4> opsToFuse({node});
      for (auto consumer : consumers) {
        rewriter.setInsertionPointAfter(node);
        auto token =
            rewriter.create<DataflowSourceOp>(loc, rewriter.getI1Type());
        opsToFuse.push_back(token);

        rewriter.setInsertionPointToStart(
            &cast<DataflowNodeOp>(consumer).body().front());
        rewriter.create<DataflowSinkOp>(loc, token);
      }

      // Fuse the source operations and original dataflow node.
      fuseOpsIntoNewNode(opsToFuse, rewriter);
    }
    return success();
  }
};
} // namespace

namespace {
struct CreateTokenDepends : public CreateTokenDependsBase<CreateTokenDepends> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<TokenCreatePattern>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateTokenDependsPass() {
  return std::make_unique<CreateTokenDepends>();
}
