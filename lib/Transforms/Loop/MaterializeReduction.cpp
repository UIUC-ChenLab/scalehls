//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct MaterializeReductionPattern : public OpRewritePattern<AffineForOp> {
  using OpRewritePattern<AffineForOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineForOp loop,
                                PatternRewriter &rewriter) const override {
    if (!loop.getNumIterOperands())
      return success();
    auto loc = rewriter.getUnknownLoc();
    auto yield = cast<AffineYieldOp>(loop.getBody()->getTerminator());

    // Traverse all iteration values.
    for (auto zip : llvm::zip(loop.getIterOperands(), loop.getRegionIterArgs(),
                              yield.getOperands(), loop.getResults())) {
      auto iterOperand = std::get<0>(zip);
      auto iterArg = std::get<1>(zip);
      auto yieldOperand = std::get<2>(zip);
      auto yieldResult = std::get<3>(zip);

      // Create a buffer for the iteration value before the loop and set the
      // initial state.
      auto memrefType = MemRefType::get({1}, iterOperand.getType());
      auto map = rewriter.getConstantAffineMap(0);
      rewriter.setInsertionPoint(loop);
      auto buf = rewriter.create<memref::AllocOp>(loc, memrefType);
      rewriter.create<AffineStoreOp>(loc, iterOperand, buf, map, ValueRange());

      // Load the iteration value from the buffer at the begining of loop and
      // replace all uses.
      rewriter.setInsertionPointToStart(loop.getBody());
      auto partial = rewriter.create<AffineLoadOp>(loc, buf, map, ValueRange());
      iterArg.replaceAllUsesWith(partial);

      // Update the state of the buffer at the end of loop.
      rewriter.setInsertionPoint(yield);
      rewriter.create<AffineStoreOp>(loc, yieldOperand, buf, map, ValueRange());

      // Load from the buffer after the loop and replace all uses.
      rewriter.setInsertionPointAfter(loop);
      auto result = rewriter.create<AffineLoadOp>(loc, buf, map, ValueRange());
      yieldResult.replaceAllUsesWith(result);
    }

    // Create a new loop without iteration operands.
    rewriter.setInsertionPoint(loop);
    auto newLoop = rewriter.create<AffineForOp>(
        loop.getLoc(), loop.getLowerBoundOperands(), loop.getLowerBoundMap(),
        loop.getUpperBoundOperands(), loop.getUpperBoundMap(), loop.getStep());
    auto &loopOps = loop.getBody()->getOperations();
    auto &newLoopOps = newLoop.getBody()->getOperations();
    newLoopOps.splice(newLoopOps.begin(), loopOps, loopOps.begin(),
                      std::prev(loopOps.end()));
    loop.getInductionVar().replaceAllUsesWith(newLoop.getInductionVar());

    // Remove the original loop now.
    rewriter.eraseOp(loop);
    return success();
  }
};
} //  namespace

namespace {
struct MaterializeReduction
    : public MaterializeReductionBase<MaterializeReduction> {
  void runOnOperation() override {
    auto func = getOperation();
    mlir::RewritePatternSet patterns(func.getContext());
    patterns.add<MaterializeReductionPattern>(func.getContext());
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createMaterializeReductionPass() {
  return std::make_unique<MaterializeReduction>();
}
