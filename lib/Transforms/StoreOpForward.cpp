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
// (* A dependence being satisfied at a block: a dependence that is satisfied by
// virtue of the destination operation appearing textually / lexically after
// the source operation within the body of a 'affine.for' operation; thus, a
// dependence is always either satisfied by a loop or by a block).
//
// The above conditions are simple to check, sufficient, and powerful for most
// cases in practice - they are sufficient, but not necessary --- since they
// don't reason about loops that are guaranteed to execute at least once or
// multiple sources to forward from.
//
// TODO: more forwarding can be done when support for
// loop/conditional live-out SSA values is available.
// TODO: do general dead store elimination for memref's. This pass
// currently only eliminates the stores only if no other loads/uses (other
// than dealloc) remain.
//
struct StoreOpForward : public StoreOpForwardBase<StoreOpForward> {
  void runOnOperation() override;

  void forwardStoreToLoad(AffineReadOpInterface loadOp);

  // A list of memref's that are potentially dead / could be eliminated.
  SmallPtrSet<Value, 4> memrefsToErase;

  DominanceInfo *domInfo = nullptr;
  PostDominanceInfo *postDomInfo = nullptr;
};

} // end anonymous namespace

/// Creates a pass to perform optimizations relying on memref dataflow such as
/// store to load forwarding, elimination of dead stores, and dead allocs.
std::unique_ptr<Pass> scalehls::createStoreOpForwardPass() {
  return std::make_unique<StoreOpForward>();
}

// This is a straightforward implementation not optimized for speed. Optimize
// if needed.
void StoreOpForward::forwardStoreToLoad(AffineReadOpInterface loadOp) {
  // First pass over the use list to get the minimum number of surrounding
  // loops common between the load op and the store op, with min taken across
  // all store ops.
  SmallVector<Operation *, 8> storeOps;
  unsigned minSurroundingLoops = getNestingDepth(loadOp);
  for (auto *user : loadOp.getMemRef().getUsers()) {
    auto storeOp = dyn_cast<AffineWriteOpInterface>(user);
    if (!storeOp)
      continue;
    unsigned nsLoops = getNumCommonSurroundingLoops(*loadOp, *storeOp);
    minSurroundingLoops = std::min(nsLoops, minSurroundingLoops);
    storeOps.push_back(storeOp);
  }

  // The list of store op candidates for forwarding that satisfy conditions
  // (1) and (2) above - they will be filtered later when checking (3).
  SmallVector<Operation *, 8> fwdingCandidates;

  // Store ops that have a dependence into the load (even if they aren't
  // forwarding candidates). Each forwarding candidate will be checked for a
  // post-dominance on these. 'fwdingCandidates' are a subset of depSrcStores.
  SmallVector<Operation *, 8> depSrcStores;

  for (auto *storeOp : storeOps) {
    MemRefAccess srcAccess(storeOp);
    MemRefAccess destAccess(loadOp);
    // Find stores that may be reaching the load.
    FlatAffineConstraints dependenceConstraints;
    unsigned nsLoops = getNumCommonSurroundingLoops(*loadOp, *storeOp);
    unsigned d;
    // Dependences at loop depth <= minSurroundingLoops do NOT matter.
    for (d = nsLoops + 1; d > minSurroundingLoops; d--) {
      DependenceResult result = checkMemrefAccessDependence(
          srcAccess, destAccess, d, &dependenceConstraints,
          /*dependenceComponents=*/nullptr);
      if (hasDependence(result))
        break;
    }
    if (d == minSurroundingLoops)
      continue;

    // Stores that *may* be reaching the load.
    depSrcStores.push_back(storeOp);

    // 1. Check if the store and the load have mathematically equivalent
    // affine access functions; this implies that they statically refer to the
    // same single memref element. As an example this filters out cases like:
    //     store %A[%i0 + 1]
    //     load %A[%i0]
    //     store %A[%M]
    //     load %A[%N]
    // Use the AffineValueMap difference based memref access equality checking.
    if (srcAccess != destAccess)
      continue;

    // 2. The store has to dominate the load op to be candidate.
    // if (!domInfo->dominates(storeOp, loadOp))
    //  continue;

    // Check whether storeOp and loadOp is at the same level.
    auto pair = checkSameLevel(storeOp, loadOp);
    if (!pair)
      continue;

    // TODO: support the case when loadOp is also surrounded by ifOp.
    if (pair.getValue().second != loadOp)
      continue;

    // Check whether the surrounding ifOp of storeOp dominates loadOp.
    if (!domInfo->dominates(pair.getValue().first, loadOp))
      continue;

    // We now have a candidate for forwarding.
    fwdingCandidates.push_back(storeOp);
  }

  // 3. Of all the store op's that meet the above criteria, the store that
  // postdominates all 'depSrcStores' (if one exists) is the unique store
  // providing the value to the load, i.e., provably the last writer to that
  // memref loc.
  // Note: this can be implemented in a cleaner way with postdominator tree
  // traversals. Consider this for the future if needed.
  Operation *lastWriteStoreOp = nullptr;
  for (auto *storeOp : fwdingCandidates) {
    if (llvm::all_of(depSrcStores, [&](Operation *depStore) {
          if (auto pair = checkSameLevel(storeOp, depStore))
            return postDomInfo->postDominates(pair.getValue().first,
                                              pair.getValue().second);
          return postDomInfo->postDominates(storeOp, depStore);
        })) {
      lastWriteStoreOp = storeOp;
      break;
    }
  }
  if (!lastWriteStoreOp)
    return;

  // Perform the actual store to load forwarding.
  auto storeSameLevelOp =
      checkSameLevel(lastWriteStoreOp, loadOp).getValue().first;
  Value storeVal =
      cast<AffineWriteOpInterface>(lastWriteStoreOp).getValueToStore();

  if (storeSameLevelOp == lastWriteStoreOp) {
    loadOp.getValue().replaceAllUsesWith(storeVal);
    loadOp.erase();
  } else {
    auto ifOp = cast<mlir::AffineIfOp>(storeSameLevelOp);
    // TODO: support AffineIfOp nests and AffineIfOp with else block.
    if (ifOp.hasElse() || ifOp.getThenBlock() != lastWriteStoreOp->getBlock())
      return;

    // Create a new if operation before the loadOp.
    OpBuilder builder(loadOp);
    builder.setInsertionPointAfter(loadOp);
    auto newIfOp = builder.create<mlir::AffineIfOp>(
        loadOp.getLoc(), loadOp.getValue().getType(), ifOp.getIntegerSet(),
        ifOp.getOperands(), /*withElseRegion=*/true);
    loadOp.getValue().replaceAllUsesWith(newIfOp.getResult(0));

    // The lastWriteStoreOp can be forwarded to the then block loadOp.
    builder.setInsertionPointToEnd(newIfOp.getThenBlock());
    builder.create<mlir::AffineYieldOp>(newIfOp.getLoc(), storeVal);
    lastWriteStoreOp->moveBefore(newIfOp.getThenBlock()->getTerminator());

    // Since lastWriteStoreOp is conditionally executed, it cannot be forwarded
    // to the else block loadOp.
    builder.setInsertionPointToEnd(newIfOp.getElseBlock());
    builder.create<mlir::AffineYieldOp>(newIfOp.getLoc(), loadOp.getValue());

    // Eliminate emptry ifOp.
    if (ifOp.getThenBlock()->getTerminator() == &ifOp.getThenBlock()->front())
      ifOp.erase();
  }

  // Record the memref for a later sweep to optimize away.
  memrefsToErase.insert(loadOp.getMemRef());
}

void StoreOpForward::runOnOperation() {
  // Only supports single block functions at the moment.
  FuncOp f = getOperation();
  if (!llvm::hasSingleElement(f)) {
    markAllAnalysesPreserved();
    return;
  }

  domInfo = &getAnalysis<DominanceInfo>();
  postDomInfo = &getAnalysis<PostDominanceInfo>();

  memrefsToErase.clear();

  // Walk all load's and perform store to load forwarding.
  f.walk([&](AffineReadOpInterface loadOp) { forwardStoreToLoad(loadOp); });

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
}
