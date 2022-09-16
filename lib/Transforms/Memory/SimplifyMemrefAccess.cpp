//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Support/Utils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

static bool applySimplifyMemrefAccess(func::FuncOp func) {
  SmallPtrSet<Operation *, 16> opsToErase;

  MemAccessesMap memAccessesMap;
  getMemAccessesMap(func.front(), memAccessesMap);

  for (auto memAccessesPair : memAccessesMap) {
    auto loadOrStoreOps = memAccessesPair.second;

    // Collect all load operations that share the same memref access.
    ReverseOpIteratorsMap loadsMap;
    for (auto it = loadOrStoreOps.rbegin(); it != loadOrStoreOps.rend(); ++it) {
      if (isa<AffineReadOpInterface>(*it))
        loadsMap[PtrLikeMemRefAccess(*it)].push_back(it);
    }

    // Traverse each {MemRefAccess, Load operation iterator vector} element.
    for (auto loadsPair : loadsMap) {
      auto loadOps = loadsPair.second;

      for (unsigned i = 0, e = loadOps.size() - 1; i < e; ++i) {
        auto loadOpIt = loadOps[i];
        auto domLoadOpIt = loadOps[i + 1];

        auto loadOp = *loadOpIt;
        auto domLoadOp = *domLoadOpIt;

        // The two load operations must locate in the same basic block.
        if (loadOp->getBlock() != domLoadOp->getBlock())
          continue;

        // Traverse all store operations between the current two load operations
        // that share the same memref access.
        auto it = std::next(loadOpIt);
        for (; it != domLoadOpIt; ++it) {
          if (isa<AffineWriteOpInterface>(*it))
            if (checkDependence(*it, loadOp))
              break;
        }

        // We need to make sure there is no dependency exists in between.
        if (it != domLoadOpIt)
          continue;

        // Now we know loadOp can be eliminated.
        loadOp->getResult(0).replaceAllUsesWith(domLoadOp->getResult(0));
        opsToErase.insert(loadOp);
      }
    }

    // Find all store operations that share the same memref access.
    OpIteratorsMap storesMap;
    for (auto it = loadOrStoreOps.begin(); it != loadOrStoreOps.end(); ++it) {
      if (isa<AffineWriteOpInterface>(*it))
        storesMap[PtrLikeMemRefAccess(*it)].push_back(it);
    }

    // Traverse each {MemRefAccess, Store operation iterator vector} element.
    for (auto storesPair : storesMap) {
      auto storeOps = storesPair.second;

      for (unsigned i = 0, e = storeOps.size() - 1; i < e; ++i) {
        auto storeOpIt = storeOps[i];
        auto postDomStoreOpIt = storeOps[i + 1];

        auto storeOp = *storeOpIt;
        auto postDomStoreOp = *postDomStoreOpIt;

        // The two store operations must locate in the same loop level.
        auto sameLevelOps = checkSameLevel(storeOp, postDomStoreOp);
        if (!sameLevelOps)
          continue;

        // The second store operation must always be executed.
        if (sameLevelOps.value().second != postDomStoreOp)
          continue;

        // Traverse all load operations between the current two load operations
        // that share the same memref access.
        auto it = std::next(storeOpIt);
        for (; it != postDomStoreOpIt; ++it) {
          if (isa<AffineReadOpInterface>(*it))
            if (checkDependence(storeOp, *it))
              break;
        }

        // We need to make sure there is no dependency exists in between.
        if (it != postDomStoreOpIt)
          continue;

        // Now we know storeOp can be eliminated.
        opsToErase.insert(storeOp);
      }
    }
  }

  for (auto op : opsToErase)
    op->erase();

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
