//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Transforms/Passes.h"
#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/Utils.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include <algorithm>

using namespace mlir;
using namespace scalehls;

namespace {
struct SimplifyMemRefAccess
    : public SimplifyMemRefAccessBase<SimplifyMemRefAccess> {
  void runOnOperation() override;
};

} // end anonymous namespace

void SimplifyMemRefAccess::runOnOperation() {
  auto func = getOperation();

  // Collect all load and store operations in the function block.
  LoadStoresMap map;
  getLoadStoresMap(func.front(), map);

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

        auto sameLevelOps = checkSameLevel(firstOp, secondOp);

        // Check whether the two operations statically have the same access
        // element while at the same level.
        if ((firstAccess == secondAccess) && sameLevelOps) {

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
          // Find possible dependencies.
          unsigned nsLoops = getNumCommonSurroundingLoops(*firstOp, *secondOp);
          bool dependencyFlag = false;

          for (unsigned depth = 1; depth <= nsLoops + 1; ++depth) {
            FlatAffineConstraints dependenceConstraints;
            SmallVector<DependenceComponent, 2> dependenceComponents;

            DependenceResult result = checkMemrefAccessDependence(
                firstAccess, secondAccess, depth, &dependenceConstraints,
                &dependenceComponents);

            // Only zero distance dependencies are considered here.
            if (hasDependence(result)) {
              int64_t distance = 0;
              for (auto dep : dependenceComponents)
                if (dep.lb)
                  distance += abs(dep.lb.getValue());

              if (distance == 0) {
                dependencyFlag = true;
                break;
              }
            }
          }

          if (dependencyFlag)
            break;
        }
      }
      opIndex++;
    }
  }
}

std::unique_ptr<Pass> scalehls::createSimplifyMemRefAccessPass() {
  return std::make_unique<SimplifyMemRefAccess>();
}
