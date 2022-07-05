//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/IntegerSet.h"
#include "scalehls/Support/Utils.h"
#include "scalehls/Transforms/Passes.h"
#include <algorithm>

using namespace mlir;
using namespace scalehls;

// The difference between this pass and built-in memref-dataflow-opt is this
// pass support to forward the StoreOps that are conditionally executed.
static bool applyAffineStoreForward(func::FuncOp func) {
  SmallPtrSet<Operation *, 16> opsToErase;

  MemAccessesMap memAccessesMap;
  getMemAccessesMap(func.front(), memAccessesMap);

  for (auto memAccessesPair : memAccessesMap) {
    auto loadOrStoreOps = memAccessesPair.second;

    // Collect all load/store operations that share the same memref access.
    ReverseOpIteratorsMap fwdingsMap;
    for (auto it = loadOrStoreOps.rbegin(); it != loadOrStoreOps.rend(); ++it)
      fwdingsMap[PtrLikeMemRefAccess(*it)].push_back(it);

    // Traverse each {MemRefAccess, Operation iterator vector} element.
    for (auto fwdingsPair : fwdingsMap) {
      auto fwdingOps = fwdingsPair.second;
      SmallVector<AffineReadOpInterface, 2> chainLoadOps;
      bool lastIsChainLoadOp = false;

      for (unsigned i = 0, e = fwdingOps.size() - 1; i < e; ++i) {
        auto opIt = fwdingOps[i];
        auto domOpIt = fwdingOps[i + 1];

        auto loadOp = dyn_cast<AffineReadOpInterface>(*opIt);
        auto domOp = *domOpIt;

        if (!loadOp) {
          lastIsChainLoadOp = false;
          continue;
        }

        // The two operations must locate in the same loop level.
        auto sameLevelOps = checkSameLevel(domOp, loadOp);
        if (!sameLevelOps) {
          lastIsChainLoadOp = false;
          continue;
        }

        // The second operation (load) must always be executed.
        if (sameLevelOps.getValue().second != loadOp) {
          lastIsChainLoadOp = false;
          continue;
        }

        // Traverse all store operations between the current two operations that
        // share the same memref access.
        auto it = std::next(opIt);
        for (; it != domOpIt; ++it) {
          if (isa<AffineWriteOpInterface>(*it))
            if (checkDependence(*it, loadOp))
              break;
        }

        // We need to make sure there is no dependency exists in between.
        if (it != domOpIt) {
          lastIsChainLoadOp = false;
          continue;
        }

        if (!lastIsChainLoadOp)
          chainLoadOps.clear();

        auto domStoreOp = dyn_cast<AffineWriteOpInterface>(domOp);

        if (!domStoreOp) {
          chainLoadOps.push_back(loadOp);
          lastIsChainLoadOp = true;
          continue;
        }

        // Now we know the forwarding is possible. Perform the actual store to
        // load forwarding.
        auto storeSurroundingOp =
            checkSameLevel(domStoreOp, loadOp).getValue().first;
        Value storeVal =
            cast<AffineWriteOpInterface>(domStoreOp).getValueToStore();
        auto builder = OpBuilder(func);

        if (storeSurroundingOp == domStoreOp) {
          loadOp.getValue().replaceAllUsesWith(storeVal);
          opsToErase.insert(loadOp.getOperation());

          for (auto chainLoadOp : chainLoadOps) {
            chainLoadOp.getValue().replaceAllUsesWith(storeVal);
            opsToErase.insert(chainLoadOp.getOperation());
          }
        } else {
          auto ifOp = dyn_cast<AffineIfOp>(storeSurroundingOp);
          // TODO: support AffineIfOp nests and AffineIfOp with else block.
          if (!ifOp || ifOp.hasElse() ||
              ifOp.getThenBlock() != domStoreOp->getBlock())
            return true;

          // Create a new if operation before the loadOp.
          builder.setInsertionPointAfter(loadOp);
          auto newIfOp = builder.create<AffineIfOp>(
              loadOp.getLoc(), loadOp.getValue().getType(),
              ifOp.getIntegerSet(), ifOp.getOperands(),
              /*withElseRegion=*/true);
          loadOp.getValue().replaceAllUsesWith(newIfOp.getResult(0));

          // The domStoreOp can be forwarded to the then block loadOp.
          builder.setInsertionPointToEnd(newIfOp.getThenBlock());
          builder.create<AffineYieldOp>(newIfOp.getLoc(), storeVal);
          domStoreOp->moveBefore(newIfOp.getThenBlock()->getTerminator());

          // Since domStoreOp is conditionally executed, it cannot be
          // forwarded to the else block loadOp.
          builder.setInsertionPointToEnd(newIfOp.getElseBlock());
          builder.create<AffineYieldOp>(newIfOp.getLoc(), loadOp.getValue());

          // Eliminate emptry ifOp.
          if (ifOp.getThenBlock()->getTerminator() ==
                  &ifOp.getThenBlock()->front() &&
              ifOp.getNumResults() == 0)
            ifOp.erase();

          // The load operation is no longer dominated by the store operation,
          // thus other store operations can be forwarded to this load operation
          // again.
          fwdingOps[i] = domOpIt;
          fwdingOps[i + 1] = opIt;
        }

        lastIsChainLoadOp = false;
      }
    }

    auto memref = memAccessesPair.first;
    auto defOp = memref.getDefiningOp();
    if (defOp && llvm::all_of(memref.getUsers(), [](Operation *user) {
          return isa<mlir::AffineWriteOpInterface>(user);
        })) {
      for (auto user : memref.getUsers())
        user->erase();
      defOp->erase();
    }
  }

  for (auto op : opsToErase)
    op->erase();

  return true;
}

namespace {
struct AffineStoreForward : public AffineStoreForwardBase<AffineStoreForward> {
  void runOnOperation() override { applyAffineStoreForward(getOperation()); }
};
} // namespace

/// Creates a pass to perform optimizations relying on memref dataflow such as
/// store to load forwarding, elimination of dead stores, and dead allocs.
std::unique_ptr<Pass> scalehls::createAffineStoreForwardPass() {
  return std::make_unique<AffineStoreForward>();
}
