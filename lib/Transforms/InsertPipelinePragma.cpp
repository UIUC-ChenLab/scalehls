//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/IR/Builders.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Transforms/LoopUtils.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct InsertPipelinePragma
    : public InsertPipelinePragmaBase<InsertPipelinePragma> {
  void runOnOperation() override;
};
} // namespace

void InsertPipelinePragma::runOnOperation() {
  auto func = getOperation();
  auto builder = OpBuilder(func);

  // Walk through loops in the function.
  for (auto forOp : func.getOps<mlir::AffineForOp>()) {
    SmallVector<mlir::AffineForOp, 4> nestedLoops;
    forOp.walk([&](mlir::AffineForOp loop) { nestedLoops.push_back(loop); });

    auto targetLoop = nestedLoops.back();
    if (nestedLoops.size() > insertLevel)
      targetLoop = *std::next(nestedLoops.begin(), insertLevel);

    targetLoop.setAttr("pipeline", builder.getBoolAttr(true));

    // All intter loops of the pipelined loop are automatically unrolled.
    targetLoop.walk([&](mlir::AffineForOp loop) {
      if (loop != targetLoop)
        loopUnrollFull(loop);
    });
  }

  // Canonicalize the IR after loop unrolling.
  OwningRewritePatternList patterns;

  auto *context = &getContext();
  for (auto *op : context->getRegisteredOperations())
    op->getCanonicalizationPatterns(patterns, context);

  applyPatternsAndFoldGreedily(func.getOperation()->getRegions(),
                               std::move(patterns));
}

std::unique_ptr<mlir::Pass> scalehls::createInsertPipelinePragmaPass() {
  return std::make_unique<InsertPipelinePragma>();
}
