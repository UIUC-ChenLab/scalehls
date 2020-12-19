//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Transforms/Passes.h"
#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/Utils.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/IntegerSet.h"
#include "llvm/ADT/SmallPtrSet.h"
#include <algorithm>

using namespace mlir;
using namespace scalehls;

namespace {
struct SimplifyMemRefAccess
    : public SimplifyMemRefAccessBase<SimplifyMemRefAccess> {
  void runOnOperation() override;
};

} // end anonymous namespace

void SimplifyMemRefAccess::runOnOperation() {}

std::unique_ptr<Pass> scalehls::createSimplifyMemRefAccessPass() {
  return std::make_unique<SimplifyMemRefAccess>();
}
