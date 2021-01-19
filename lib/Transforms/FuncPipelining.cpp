//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Transforms/LoopUtils.h"

using namespace std;
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
  bool hasFullyUnrolled = false;
  while (hasFullyUnrolled == false) {
    hasFullyUnrolled = true;
    func.walk([&](AffineForOp loop) {
      if (failed(loopUnrollFull(loop)))
        hasFullyUnrolled = false;
    });
  }

  func->setAttr("pipeline", builder.getBoolAttr(true));
  func->setAttr("dataflow", builder.getBoolAttr(false));

  // For now, this method will always success.
  return true;
}

std::unique_ptr<Pass> scalehls::createFuncPipeliningPass() {
  return std::make_unique<FuncPipelining>();
}
