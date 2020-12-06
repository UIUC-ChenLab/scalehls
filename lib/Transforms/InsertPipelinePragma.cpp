//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/IR/Builders.h"
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
  auto module = getOperation();
  auto builder = OpBuilder(module);

  // Walk through all functions and loops.
  for (auto func : module.getOps<FuncOp>()) {
    for (auto forOp : func.getOps<mlir::AffineForOp>()) {
      SmallVector<mlir::AffineForOp, 4> nestedLoops;
      getPerfectlyNestedLoops(nestedLoops, forOp);

      auto targetLoop = nestedLoops.front();
      if (nestedLoops.size() > insertLevel)
        targetLoop = *std::prev(nestedLoops.end(), insertLevel);

      targetLoop.setAttr("pipeline", builder.getBoolAttr(true));
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createInsertPipelinePragmaPass() {
  return std::make_unique<InsertPipelinePragma>();
}
