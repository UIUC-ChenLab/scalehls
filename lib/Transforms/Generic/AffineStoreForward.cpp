//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/Utils.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/IntegerSet.h"
#include "scalehls/Analysis/Utils.h"
#include "scalehls/Transforms/Passes.h"
#include <algorithm>

using namespace mlir;
using namespace scalehls;

// The difference between this pass and built-in memref-dataflow-opt is this
// pass support to forward the StoreOps that are conditionally executed.

namespace {
// The store to load forwarding relies on three conditions:
//
// 1) they need to have mathematically equivalent affine access functions
// (checked after full composition of load/store operands); this implies that
// they access the same single memref element for all iterations of the common
// surrounding loop,
//
// 2) the store op should dominate the load op,
//
// 3) among all op's that satisfy both (1) and (2), the one that postdominates
// all store op's that have a dependence into the load, is provably the last
// writer to the particular memref location being loaded at the load op, and its
// store value can be forwarded to the load. Note that the only dependences
// that are to be considered are those that are satisfied at the block* of the
// innermost common surrounding loop of the <store, load> being considered.
//
class Forwarder {
public:
  explicit Forwarder(FuncOp func, SmallPtrSet<Value, 4> &memrefsToErase,
                     SmallPtrSet<Operation *, 16> &loadsToErase)
      : func(func), memrefsToErase(memrefsToErase), loadsToErase(loadsToErase) {
    getMemAccessesMap(func.front(), map);
  }

  void forwardStoreToLoad(AffineReadOpInterface loadOp);

  FuncOp func;
  SmallPtrSet<Value, 4> &memrefsToErase;
  SmallPtrSet<Operation *, 16> &loadsToErase;
  MemAccessesMap map;
};
} // namespace

void Forwarder::forwardStoreToLoad(AffineReadOpInterface loadOp) {
  auto &loadOrStoreOps = map[loadOp.getMemRef()];

  // The last store operation that meets 1) and 2) above.
  Operation *fwdingStoreOp = nullptr;

  // Find all eligible store operations that dominates the load operation.
  SmallVector<Operation *, 8> storeOps;
  auto startOpIter =
      std::find(loadOrStoreOps.rbegin(), loadOrStoreOps.rend(), loadOp);

  for (auto it = std::next(startOpIter); it != loadOrStoreOps.rend(); ++it) {
    auto loadOrStoreOp = *it;

    auto storeOp = dyn_cast<AffineWriteOpInterface>(loadOrStoreOp);
    if (!storeOp)
      continue;

    // Check whether storeOp and loadOp is at the same level.
    // TODO: support store-to-load forward between different level
    auto sameLevelOps = checkSameLevel(storeOp, loadOp);
    if (!sameLevelOps)
      return;

    if (sameLevelOps.getValue().second == loadOp &&
        MemRefAccess(storeOp) == MemRefAccess(loadOp)) {
      fwdingStoreOp = storeOp;
      break;
    }

    storeOps.push_back(storeOp);
  }

  // There's no valid store operations that can be forwarded.
  if (!fwdingStoreOp)
    return;

  // For now, we don't know whether fwdingStoreOp meets 3) above. We need to
  // make sure all store operations between fwdingStoreOp and loadOp does NOT
  // have dependency with loadOp.
  if (!storeOps.empty()) {
    // As we have ensured that all store operations are at the same level, thus
    // their common surrounding loops are exactly the same.
    AffineLoopBand commonLoops;
    unsigned numCommonLoops =
        getCommonSurroundingLoops(storeOps.back(), loadOp, &commonLoops);

    // Traverse each loop level to find dependencies.
    for (unsigned depth = numCommonLoops; depth > 0; depth--) {
      // Bypass all parallel loop level.
      if (auto parallelAttr =
              commonLoops[depth - 1]->getAttrOfType<BoolAttr>("parallel"))
        if (parallelAttr.getValue())
          continue;

      for (auto storeOp : storeOps) {
        FlatAffineConstraints depConstrs;

        DependenceResult result = checkMemrefAccessDependence(
            MemRefAccess(storeOp), MemRefAccess(loadOp), depth, &depConstrs,
            /*dependenceComponents=*/nullptr);
        if (hasDependence(result))
          return;
      }
    }
  }

  // Perform the actual store to load forwarding.
  auto storeSurroundingOp =
      checkSameLevel(fwdingStoreOp, loadOp).getValue().first;
  Value storeVal =
      cast<AffineWriteOpInterface>(fwdingStoreOp).getValueToStore();
  auto builder = OpBuilder(func);

  if (storeSurroundingOp == fwdingStoreOp) {
    loadOp.getValue().replaceAllUsesWith(storeVal);
    loadsToErase.insert(loadOp.getOperation());

    // Record the memref for a later sweep to optimize away.
    memrefsToErase.insert(loadOp.getMemRef());
  } else {
    auto ifOp = cast<AffineIfOp>(storeSurroundingOp);
    // TODO: support AffineIfOp nests and AffineIfOp with else block.
    if (ifOp.hasElse() || ifOp.getThenBlock() != fwdingStoreOp->getBlock())
      return;

    // Create a new if operation before the loadOp.
    builder.setInsertionPointAfter(loadOp);
    auto newIfOp = builder.create<AffineIfOp>(
        loadOp.getLoc(), loadOp.getValue().getType(), ifOp.getIntegerSet(),
        ifOp.getOperands(), /*withElseRegion=*/true);
    loadOp.getValue().replaceAllUsesWith(newIfOp.getResult(0));

    // The fwdingStoreOp can be forwarded to the then block loadOp.
    builder.setInsertionPointToEnd(newIfOp.getThenBlock());
    builder.create<AffineYieldOp>(newIfOp.getLoc(), storeVal);
    fwdingStoreOp->moveBefore(newIfOp.getThenBlock()->getTerminator());

    // Since fwdingStoreOp is conditionally executed, it cannot be forwarded
    // to the else block loadOp.
    builder.setInsertionPointToEnd(newIfOp.getElseBlock());
    builder.create<AffineYieldOp>(newIfOp.getLoc(), loadOp.getValue());

    // Eliminate emptry ifOp.
    if (ifOp.getThenBlock()->getTerminator() == &ifOp.getThenBlock()->front() &&
        ifOp.getNumResults() == 0)
      ifOp.erase();

    // The load operation is no longer dominated by the store operation, thus
    // other store operations can be forwarded to this load operation again.
    auto storeOpIter =
        std::find(loadOrStoreOps.begin(), loadOrStoreOps.end(), fwdingStoreOp);
    auto loadOpIter =
        std::find(loadOrStoreOps.begin(), loadOrStoreOps.end(), loadOp);
    std::rotate(storeOpIter, std::next(storeOpIter), std::next(loadOpIter));

    forwardStoreToLoad(loadOp);
  }
}

static bool applyAffineStoreForward(FuncOp func) {
  SmallPtrSet<Value, 4> memrefsToErase;
  SmallPtrSet<Operation *, 16> loadsToErase;
  auto forwarder = Forwarder(func, memrefsToErase, loadsToErase);

  // Walk all load's and perform store to load forwarding.
  func.walk([&](AffineReadOpInterface loadOp) {
    forwarder.forwardStoreToLoad(loadOp);
  });

  for (auto loadOp : loadsToErase)
    loadOp->erase();

  // Check if the store fwd'ed memrefs are now left with only stores and can
  // thus be completely deleted. Note: the canonicalize pass should be able
  // to do this as well, but we'll do it here since we collected these anyway.
  for (auto memref : memrefsToErase) {
    // If the memref hasn't been alloc'ed in this function, skip.
    Operation *defOp = memref.getDefiningOp();
    if (!defOp || !isa<AllocOp>(defOp))
      // TODO: if the memref was returned by a 'call' operation, we
      // could still erase it if the call had no side-effects.
      continue;
    if (llvm::any_of(memref.getUsers(), [&](Operation *ownerOp) {
          return !isa<AffineWriteOpInterface, DeallocOp>(ownerOp);
        }))
      continue;

    // Erase all stores, the dealloc, and the alloc on the memref.
    for (auto *user : llvm::make_early_inc_range(memref.getUsers()))
      user->erase();
    defOp->erase();
  }

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
