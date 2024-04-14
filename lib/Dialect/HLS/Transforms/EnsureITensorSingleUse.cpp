//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_ENSUREITENSORSINGLEUSE
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
template <typename OpTy>
struct FoldForkOpIntoInstanceLikeOp : public OpRewritePattern<ITensorForkOp> {
  using OpRewritePattern<ITensorForkOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(ITensorForkOp fork,
                                PatternRewriter &rewriter) const override {
    if (auto inst = fork.getSource().template getDefiningOp<OpTy>()) {
      for (auto result : fork.getResults())
        rewriter.replaceAllUsesWith(result, inst.getResult());
      rewriter.eraseOp(fork);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct FoldForkOpIntoForkOp : public OpRewritePattern<ITensorForkOp> {
  using OpRewritePattern<ITensorForkOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(ITensorForkOp fork,
                                PatternRewriter &rewriter) const override {
    auto prevFork = fork.getSource().getDefiningOp<ITensorForkOp>();
    if (!prevFork)
      return failure();

    rewriter.setInsertionPoint(prevFork);
    auto resultTypes =
        SmallVector<Type>(fork.getNumResults() + prevFork.getNumResults() - 1,
                          prevFork.getSourceType());
    auto newFork = rewriter.create<ITensorForkOp>(fork.getLoc(), resultTypes,
                                                  prevFork.getSource());

    // Replace the uses of the original fork results with the new fork results.
    for (auto [result, newResult] :
         llvm::zip(fork.getResults(),
                   newFork.getResults().take_front(fork.getNumResults())))
      rewriter.replaceAllUsesWith(result, newResult);

    // Replace the uses of the previous fork results with the new fork results.
    for (auto [result, newResult] :
         llvm::zip(llvm::make_filter_range(
                       prevFork.getResults(),
                       [&](Value v) { return v != fork.getSource(); }),
                   newFork.getResults().drop_front(fork.getNumResults())))
      rewriter.replaceAllUsesWith(result, newResult);

    rewriter.eraseOp(fork);
    rewriter.eraseOp(prevFork);
    return success();
  }
};
} // namespace

namespace {
struct FoldForkOpIntoViewLikeOp : public OpRewritePattern<ITensorForkOp> {
  using OpRewritePattern<ITensorForkOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(ITensorForkOp fork,
                                PatternRewriter &rewriter) const override {
    auto view = fork.getSource().getDefiningOp<ITensorViewLikeOpInterface>();
    if (!view)
      return failure();

    auto resultTypes =
        SmallVector<Type>(fork.getNumResults(), view.getSourceType());
    auto newFork = rewriter.create<ITensorForkOp>(fork.getLoc(), resultTypes,
                                                  view.getSource());

    // Clone the original view-like op after the new fork op.
    for (auto [result, newResult] :
         llvm::zip(fork.getResults(), newFork.getResults())) {
      IRMapping mapping;
      mapping.map(view.getSource(), newResult);
      auto newView =
          cast<ITensorViewLikeOpInterface>(rewriter.clone(*view, mapping));
      rewriter.replaceAllUsesWith(result, newView.getResult());
    }

    rewriter.eraseOp(fork);
    rewriter.eraseOp(view);
    return success();
  }
};
} // namespace

namespace {
struct FoldForkOpIntoWriteLikeOp : public OpRewritePattern<ITensorForkOp> {
  using OpRewritePattern<ITensorForkOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(ITensorForkOp fork,
                                PatternRewriter &rewriter) const override {
    auto write = fork.getSource().getDefiningOp<ITensorWriteLikeOpInterface>();
    if (!write)
      return failure();

    auto resultTypes =
        SmallVector<Type>(fork.getNumResults(), write.getDestType());
    auto newFork = rewriter.create<ITensorForkOp>(fork.getLoc(), resultTypes,
                                                  write.getDest());

    // Clone the original view-like op after the new fork op.
    for (auto [result, newResult] :
         llvm::zip(fork.getResults(), newFork.getResults())) {
      IRMapping mapping;
      mapping.map(write.getDest(), newResult);
      auto newWrite =
          cast<ITensorWriteLikeOpInterface>(rewriter.clone(*write, mapping));
      rewriter.replaceAllUsesWith(result, newWrite.getResult());
    }

    rewriter.eraseOp(fork);
    rewriter.eraseOp(write);
    return success();
  }
};
} // namespace

namespace {
struct FoldForkOpIntoForOp : public OpRewritePattern<ITensorForkOp> {
  using OpRewritePattern<ITensorForkOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(ITensorForkOp fork,
                                PatternRewriter &rewriter) const override {
    auto loop = fork.getSource().getDefiningOp<scf::ForOp>();
    if (!loop)
      return failure();

    auto forkTypes = fork->getResultTypes();
    auto numForks = fork.getNumResults();
    auto index = cast<OpResult>(fork.getSource()).getResultNumber();

    // Fork the init operand of the loop.
    auto initOperand = loop.getInitArgs()[index];
    rewriter.setInsertionPoint(loop);
    auto initOperandFork = rewriter.create<ITensorForkOp>(
        initOperand.getLoc(), forkTypes, initOperand);
    rewriter.replaceAllUsesExcept(initOperand, initOperandFork.getResult(0),
                                  initOperandFork);

    // Fork the yielded value of the loop.
    auto yieldedValue = loop.getYieldedValues()[index];
    auto yieldOp = loop.getBody()->getTerminator();
    rewriter.setInsertionPoint(yieldOp);
    auto yieldedValueFork = rewriter.create<ITensorForkOp>(
        yieldedValue.getLoc(), forkTypes, yieldedValue);
    rewriter.replaceAllUsesExcept(yieldedValue, yieldedValueFork.getResult(0),
                                  yieldedValueFork);

    // Replace the loop with a new loop with forked init operands and yielded
    // values.
    auto loopRewriteResult = loop.replaceWithAdditionalYields(
        rewriter, initOperandFork.getResults().drop_front(), true,
        [&](OpBuilder &, Location, ArrayRef<BlockArgument>) {
          return yieldedValueFork.getResults().drop_front();
        });
    if (failed(loopRewriteResult))
      return failure();
    auto newLoop = cast<scf::ForOp>(loopRewriteResult->getOperation());

    // Join the iter args of the new loop.
    auto iterArg = newLoop.getRegionIterArg(index);
    SmallVector<Value> iterArgsToJoin({iterArg});
    for (auto newIterArg : newLoop.getRegionIterArgs().take_back(numForks - 1))
      iterArgsToJoin.push_back(newIterArg);

    rewriter.setInsertionPointToStart(newLoop.getBody());
    auto iterArgJoin = rewriter.create<ITensorJoinOp>(
        iterArg.getLoc(), iterArg.getType(), iterArgsToJoin);
    rewriter.replaceAllUsesExcept(iterArg, iterArgJoin.getResult(),
                                  iterArgJoin);

    // Replace the uses of the fork results with the new loop results.
    auto result = newLoop.getResult(index);
    SmallVector<Value> resultToReplace({result});
    for (auto newResult : newLoop.getResults().take_back(numForks - 1))
      resultToReplace.push_back(newResult);

    for (auto [forkResult, loopResult] :
         llvm::zip(fork.getResults(), resultToReplace))
      rewriter.replaceAllUsesWith(forkResult, loopResult);
    rewriter.eraseOp(fork);
    return success();
  }
};
} // namespace

namespace {
struct EnsureITensorSingleUse
    : public hls::impl::EnsureITensorSingleUseBase<EnsureITensorSingleUse> {
  void generateITensorFork() {
    auto builder = OpBuilder(&getContext());
    getOperation().walk([&](Operation *op) {
      builder.setInsertionPointAfter(op);
      for (auto result : op->getResults()) {
        auto numUses = llvm::range_size(result.getUses());
        if (isa<ITensorType>(result.getType()) && numUses > 1) {
          auto resultTypes = SmallVector<Type>(numUses, result.getType());
          auto fork =
              builder.create<ITensorForkOp>(op->getLoc(), resultTypes, result);
          unsigned idx = 0;
          for (auto &use : llvm::make_early_inc_range(result.getUses()))
            if (use.getOwner() != fork)
              use.set(fork.getResult(idx++));
        }
      }
    });
  }

  LogicalResult postVerification() {
    // Check if all itensor fork/join ops have been folded.
    auto checkResult = getOperation().walk([&](Operation *op) {
      if (isa<hls::ITensorForkOp, hls::ITensorJoinOp>(op)) {
        op->emitOpError("fork and join ops should have been folded");
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });
    return failure(checkResult.wasInterrupted());
  }

  void runOnOperation() override {
    auto context = &getContext();
    generateITensorFork();
    mlir::RewritePatternSet patterns(context);
    patterns.add<FoldForkOpIntoInstanceLikeOp<ITensorEmptyOp>>(context);
    patterns.add<FoldForkOpIntoInstanceLikeOp<ITensorInstanceOp>>(context);
    patterns.add<FoldForkOpIntoForkOp>(context);
    patterns.add<FoldForkOpIntoViewLikeOp>(context);
    patterns.add<FoldForkOpIntoWriteLikeOp>(context);
    patterns.add<FoldForkOpIntoForOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));

    if (failed(postVerification()))
      signalPassFailure();
  }
};
} // namespace
