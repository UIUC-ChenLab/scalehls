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

/// Apply function pipelining to the input function, all contained loops are
/// automatically fully unrolled.
static bool applyFuncPipelining(FuncOp func, int64_t targetII,
                                OpBuilder &builder) {
  if (!applyFullyLoopUnrolling(func.front()))
    return false;

  func->setAttr("pipeline", builder.getBoolAttr(true));
  func->setAttr("target_ii", builder.getI64IntegerAttr(targetII));

  func->setAttr("dataflow", builder.getBoolAttr(false));

  return true;
}

namespace {
struct FuncPipelining : public FuncPipeliningBase<FuncPipelining> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    if (func.getName() == targetFunc) {
      applyFuncPipelining(func, targetII, builder);

      // Canonicalize the IR after function pipelining.
      OwningRewritePatternList patterns;
      for (auto *op : builder.getContext()->getRegisteredOperations())
        op->getCanonicalizationPatterns(patterns, builder.getContext());

      applyPatternsAndFoldGreedily(func.getRegion(), std::move(patterns));
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createFuncPipeliningPass() {
  return std::make_unique<FuncPipelining>();
}
