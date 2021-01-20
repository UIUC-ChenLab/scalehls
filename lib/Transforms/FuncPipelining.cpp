//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Transforms/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct FuncPipelining : public FuncPipeliningBase<FuncPipelining> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    if (func.getName() == targetFunc) {
      applyFuncPipelining(func, builder);

      // Canonicalize the IR after function pipelining.
      OwningRewritePatternList patterns;
      for (auto *op : builder.getContext()->getRegisteredOperations())
        op->getCanonicalizationPatterns(patterns, builder.getContext());

      applyPatternsAndFoldGreedily(func.getRegion(), std::move(patterns));
    }
  }
};
} // namespace

/// Apply function pipelining to the input function, all contained loops are
/// automatically fully unrolled.
bool scalehls::applyFuncPipelining(FuncOp func, OpBuilder &builder) {
  // TODO: the teminate condition need to be updated. This will try at most 8
  // iterations.
  for (auto i = 0; i < 8; ++i) {
    bool hasFullyUnrolled = true;
    func.walk([&](AffineForOp loop) {
      if (failed(loopUnrollFull(loop)))
        hasFullyUnrolled = false;
    });

    if (hasFullyUnrolled)
      break;

    if (i == 7)
      return false;
  }

  func->setAttr("pipeline", builder.getBoolAttr(true));
  func->setAttr("dataflow", builder.getBoolAttr(false));

  return true;
}

std::unique_ptr<Pass> scalehls::createFuncPipeliningPass() {
  return std::make_unique<FuncPipelining>();
}
