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
class Simplifier {
public:
  explicit Simplifier(FuncOp func, SmallPtrSet<Operation *, 16> &opsToErase)
      : func(func), opsToErase(opsToErase) {
    getMemAccessesMap(func.front(), map);
  }

  void refreshMemAccessMap() {
    map.clear();
    getMemAccessesMap(func.front(), map);
  }

  void simplifyLoad(AffineReadOpInterface loadOp);
  void simplifyStore(AffineWriteOpInterface storeOp);

  FuncOp func;
  SmallPtrSet<Operation *, 16> &opsToErase;
  MemAccessesMap map;
};
} // namespace

void Simplifier::simplifyLoad(AffineReadOpInterface loadOp) {
  auto &loadOrStoreOps = map[loadOp.getMemRef()];

  // The last load operation that has identical memory access with loadOp.
  Operation *targetLoadOp = nullptr;

  // Find all eligible store operations that dominates the load operation.
  SmallVector<Operation *, 8> domStoreOps;
  auto startOpIter =
      std::find(loadOrStoreOps.rbegin(), loadOrStoreOps.rend(), loadOp);

  for (auto it = std::next(startOpIter); it != loadOrStoreOps.rend(); ++it) {
    auto loadOrStoreOp = *it;

    // If the two operations are at different loop levels, quit.
    auto sameLevelOps = checkSameLevel(loadOrStoreOp, loadOp);
    if (!sameLevelOps)
      return;

    if (auto domLoadOp = dyn_cast<AffineReadOpInterface>(loadOrStoreOp)) {
      // Check whether has identical memory access.
      if (sameLevelOps.getValue().first == domLoadOp &&
          sameLevelOps.getValue().second == loadOp &&
          MemRefAccess(domLoadOp) == MemRefAccess(loadOp) &&
          !opsToErase.count(domLoadOp)) {
        targetLoadOp = domLoadOp;
        break;
      }
    } else {
      domStoreOps.push_back(loadOrStoreOp);
    }
  }

  if (!targetLoadOp)
    return;

  if (!domStoreOps.empty()) {
    // As we have ensured that all store operations are at the same level, thus
    // their common surrounding loops are exactly the same.
    AffineLoopBand commonLoops;
    unsigned numCommonLoops =
        getCommonSurroundingLoops(domStoreOps.back(), loadOp, &commonLoops);

    // Traverse each loop level to find dependencies.
    for (unsigned depth = numCommonLoops; depth > 0; depth--) {
      // Skip all parallel loop level.
      if (auto parallelAttr =
              commonLoops[depth - 1]->getAttrOfType<BoolAttr>("parallel"))
        if (parallelAttr.getValue())
          continue;

      for (auto storeOp : domStoreOps) {
        FlatAffineConstraints depConstrs;

        DependenceResult result = checkMemrefAccessDependence(
            MemRefAccess(storeOp), MemRefAccess(loadOp), depth, &depConstrs,
            /*dependenceComponents=*/nullptr);
        if (hasDependence(result))
          return;
      }
    }
  }

  for (unsigned i = 0, e = loadOp->getNumResults(); i < e; ++i)
    loadOp->getResult(i).replaceAllUsesWith(targetLoadOp->getResult(i));
  opsToErase.insert(loadOp);
}

void Simplifier::simplifyStore(AffineWriteOpInterface storeOp) {
  auto &loadOrStoreOps = map[storeOp.getMemRef()];

  // The last store operation that has identical memory access with storeOp.
  Operation *targetStoreOp = nullptr;

  // Find all eligible operations that dominates the store operation.
  SmallVector<Operation *, 8> postDomLoadOps;
  auto startOpIter =
      std::find(loadOrStoreOps.begin(), loadOrStoreOps.end(), storeOp);

  for (auto it = std::next(startOpIter); it != loadOrStoreOps.end(); ++it) {
    auto loadOrStoreOp = *it;

    // If the two operations are at different loop levels, quit.
    auto sameLevelOps = checkSameLevel(storeOp, loadOrStoreOp);
    if (!sameLevelOps)
      return;

    if (auto postDomStoreOp = dyn_cast<AffineWriteOpInterface>(loadOrStoreOp)) {
      // Check whether has identical memory access.
      if (sameLevelOps.getValue().second == postDomStoreOp &&
          MemRefAccess(storeOp) == MemRefAccess(postDomStoreOp)) {
        targetStoreOp = postDomStoreOp;
        break;
      }
    } else {
      postDomLoadOps.push_back(loadOrStoreOp);
    }
  }

  if (!targetStoreOp)
    return;

  if (!postDomLoadOps.empty()) {
    // As we have ensured that all store operations are at the same level, thus
    // their common surrounding loops are exactly the same.
    AffineLoopBand commonLoops;
    unsigned numCommonLoops =
        getCommonSurroundingLoops(storeOp, postDomLoadOps.back(), &commonLoops);

    // Traverse each loop level to find dependencies.
    for (unsigned depth = numCommonLoops; depth > 0; depth--) {
      // Skip all parallel loop level.
      if (auto parallelAttr =
              commonLoops[depth - 1]->getAttrOfType<BoolAttr>("parallel"))
        if (parallelAttr.getValue())
          continue;

      for (auto loadOp : postDomLoadOps) {
        FlatAffineConstraints depConstrs;

        DependenceResult result = checkMemrefAccessDependence(
            MemRefAccess(storeOp), MemRefAccess(loadOp), depth, &depConstrs,
            /*dependenceComponents=*/nullptr);
        if (hasDependence(result))
          return;
      }
    }
  }

  for (auto postDomLoadOp : postDomLoadOps) {
    FlatAffineConstraints depConstrs;
    unsigned nsLoops = getNumCommonSurroundingLoops(*storeOp, *postDomLoadOp);

    for (unsigned depth = nsLoops + 1; depth > 0; depth--) {
      DependenceResult result = checkMemrefAccessDependence(
          MemRefAccess(storeOp), MemRefAccess(postDomLoadOp), depth,
          &depConstrs, /*dependenceComponents=*/nullptr);
      if (hasDependence(result))
        return;
    }
  }

  opsToErase.insert(storeOp);
}

static bool applySimplifyMemrefAccess(FuncOp func) {
  SmallPtrSet<Operation *, 16> opsToErase;
  auto simplifier = Simplifier(func, opsToErase);
  func.walk(
      [&](AffineReadOpInterface loadOp) { simplifier.simplifyLoad(loadOp); });

  for (auto loadOp : opsToErase)
    loadOp->erase();

  opsToErase.clear();
  simplifier.refreshMemAccessMap();
  func.walk([&](AffineWriteOpInterface storeOp) {
    simplifier.simplifyStore(storeOp);
  });

  for (auto storeOp : opsToErase)
    storeOp->erase();

  return true;
}

namespace {
struct SimplifyMemrefAccess
    : public SimplifyMemrefAccessBase<SimplifyMemrefAccess> {
  void runOnOperation() override { applySimplifyMemrefAccess(getOperation()); }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSimplifyMemrefAccessPass() {
  return std::make_unique<SimplifyMemrefAccess>();
}
