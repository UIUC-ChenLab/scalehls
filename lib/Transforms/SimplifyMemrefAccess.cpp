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
        if (firstAccess == secondAccess) {
          // If the two operations are at different loop levels, break.
          // TODO: memory access operation hoisting?
          auto sameLevelOps = checkSameLevel(firstOp, secondOp);
          if (!sameLevelOps)
            break;

          // If the second operation's access direction is different with the
          // first operation, the first operation is known not redundant.
          if ((firstIsRead && !secondIsRead) || (!firstIsRead && secondIsRead))
            break;

          // If both of the two operations are memory loads, only if both of
          // them is not conditionally executed, elinimation could happen.
          if (firstIsRead && secondIsRead) {
            if (sameLevelOps.getValue().first == firstOp &&
                sameLevelOps.getValue().second == secondOp) {
              // Now we have known that the first and second operation are at
              // the same level, and have identical memory accesses. Therefore,
              // we can safely eliminate the first operation after replacing
              // all its uses.
              for (unsigned i = 0, e = firstOp->getNumResults(); i < e; ++i) {
                firstOp->getResult(i).replaceAllUsesWith(
                    secondOp->getResult(i));
              }
              secondOp->moveAfter(firstOp);
              firstOp->erase();
              break;
            }
          }

          // If both of the two operations are memory stores, only if the second
          // operation is not conditionally executed, the first operation can be
          // safely eliminated.
          if (!firstIsRead && !secondIsRead) {
            if (sameLevelOps.getValue().second == secondOp) {
              firstOp->erase();
              break;
            }
          }
        } else {
          // Find possible dependencies. If dependency appears, the first is no
          // longer be able to be simplified.
          unsigned nsLoops = getNumCommonSurroundingLoops(*firstOp, *secondOp);
          bool foundDependence = false;

          for (unsigned depth = 1; depth <= nsLoops + 1; ++depth) {
            FlatAffineConstraints dependenceConstraints;
            SmallVector<DependenceComponent, 2> dependenceComponents;

            DependenceResult result = checkMemrefAccessDependence(
                firstAccess, secondAccess, depth, &dependenceConstraints,
                &dependenceComponents);

            // Only zero distance dependencies are considered here.
            if (hasDependence(result)) {
              bool hasZeroDistance = true;

              for (auto dep : dependenceComponents)
                if (dep.lb.getValue() > 0 || dep.ub.getValue() < 0) {
                  hasZeroDistance = false;
                  break;
                }

              if (hasZeroDistance) {
                foundDependence = true;
                break;
              }
            }
          }

          // If any dependence is found, break.
          if (foundDependence)
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
