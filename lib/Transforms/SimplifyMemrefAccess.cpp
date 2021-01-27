//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/Utils.h"
#include "scalehls/Analysis/Utils.h"
#include "scalehls/Transforms/Passes.h"
#include <algorithm>

using namespace mlir;
using namespace scalehls;

namespace {
struct SimplifyMemrefAccess
    : public SimplifyMemrefAccessBase<SimplifyMemrefAccess> {
  void runOnOperation() override { applySimplifyMemrefAccess(getOperation()); }
};
} // namespace

bool scalehls::applySimplifyMemrefAccess(FuncOp func) {
  // Collect all load and store operations in the function block.
  MemAccessesMap map;
  getMemAccessesMap(func.front(), map);

  for (auto pair : map) {
    auto loadStores = pair.second;

    // Walk through all load and store operations.
    unsigned opIndex = 1;
    for (auto firstOp : loadStores) {
      auto firstAccess = MemRefAccess(firstOp);
      auto firstIsRead = isa<AffineReadOpInterface>(firstOp);

      // Only walk through all load and store operations that MAY dominated by
      // the first operation.
      for (auto secondOp : llvm::drop_begin(loadStores, opIndex)) {
        auto secondAccess = MemRefAccess(secondOp);
        auto secondIsRead = isa<AffineReadOpInterface>(secondOp);

        // Check whether the two operations statically have the same access.
        // This is conservative, because dependency analysis should be conducted
        // for checking whether the in between operations should break the
        // simplification.
        if (firstAccess != secondAccess)
          break;

        // If the second operation's access direction is different with the
        // first operation, the first operation is known not redundant.
        if ((firstIsRead && !secondIsRead) || (!firstIsRead && secondIsRead))
          break;

        // If the two operations are at different loop levels, break.
        // TODO: memory access operation hoisting?
        auto sameLevelOps = checkSameLevel(firstOp, secondOp);
        if (!sameLevelOps)
          break;

        // If both of the two operations are memory loads, only if both of
        // them is not conditionally executed, elinimation could happen.
        if (firstIsRead && secondIsRead)
          if (sameLevelOps.getValue().first == firstOp &&
              sameLevelOps.getValue().second == secondOp) {
            // Now we have known that the first and second operation are at
            // the same level, and have identical memory accesses. Therefore,
            // we can safely eliminate the first operation after replacing
            // all its uses.
            for (unsigned i = 0, e = firstOp->getNumResults(); i < e; ++i) {
              firstOp->getResult(i).replaceAllUsesWith(secondOp->getResult(i));
            }
            // TODO: this is actually incorrect, if some AffineApplyOp is not
            // folded, this will cause domination violation.
            secondOp->moveAfter(firstOp);
            firstOp->erase();
            break;
          }

        // If both of the two operations are memory stores, only if the second
        // operation is not conditionally executed, the first operation can be
        // safely eliminated.
        if (!firstIsRead && !secondIsRead)
          if (sameLevelOps.getValue().second == secondOp) {
            firstOp->erase();
            break;
          }
      }
      opIndex++;
    }
  }

  return true;
}

std::unique_ptr<Pass> scalehls::createSimplifyMemrefAccessPass() {
  return std::make_unique<SimplifyMemrefAccess>();
}
