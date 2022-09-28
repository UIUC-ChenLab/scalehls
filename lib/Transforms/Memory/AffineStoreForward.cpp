//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Affine/Utils.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/IntegerSet.h"
#include "scalehls/Support/Utils.h"
#include "scalehls/Transforms/Passes.h"
#include <algorithm>

using namespace mlir;
using namespace scalehls;

/// Attempt to eliminate loadOp by replacing it with a value stored into memory
/// which the load is guaranteed to retrieve. This check involves three
/// components: 1) The store and load must be on the same location 2) The store
/// must dominate (and therefore must always occur prior to) the load 3) No
/// other operations will overwrite the memory loaded between the given load
/// and store.  If such a value exists, the replaced `loadOp` will be added to
/// `loadOpsToErase` and its memref will be added to `memrefsToErase`.
static mlir::AffineReadOpInterface
forwardStoreToLoad(mlir::AffineReadOpInterface loadOp,
                   SmallVectorImpl<Operation *> &loadOpsToErase,
                   SmallPtrSetImpl<Value> &memrefsToErase,
                   DominanceInfo &domInfo) {

  // The store op candidate for forwarding that satisfies all conditions
  // to replace the load, if any.
  mlir::AffineWriteOpInterface lastWriteStoreOp = nullptr;

  for (auto *user : loadOp.getMemRef().getUsers()) {
    auto storeOp = dyn_cast<mlir::AffineWriteOpInterface>(user);
    if (!storeOp)
      continue;
    MemRefAccess srcAccess(storeOp);
    MemRefAccess destAccess(loadOp);

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

    // 2. The store has to dominate the load op to be candidate. Here, we cover
    // a special case that the store is the sole operation insides of an if
    // statement. If this is the case, we set the if statement as start for
    // intervening effect searching.
    Operation *startOp = storeOp;
    if (auto ifOp = dyn_cast<mlir::AffineIfOp>(storeOp->getParentOp()))
      if (!ifOp.hasElse() && ifOp.getThenBlock()->getOperations().size() == 2 &&
          ifOp->getParentRegion()->isAncestor(loadOp->getParentRegion()) &&
          !ifAlwaysTrueOrFalse(ifOp).second)
        startOp = ifOp;
    if (!domInfo.dominates(startOp, loadOp))
      continue;

    // 3. Ensure there is no intermediate operation which could replace the
    // value in memory.
    if (!hasNoInterveningEffect<MemoryEffects::Write>(startOp, loadOp,
                                                      loadOp.getMemRef()))
      continue;

    // We now have a candidate for forwarding.
    assert(lastWriteStoreOp == nullptr &&
           "multiple simulataneous replacement stores");
    lastWriteStoreOp = storeOp;
  }

  if (!lastWriteStoreOp)
    return loadOp;

  // Perform the actual store to load forwarding.
  Value storeVal = lastWriteStoreOp.getValueToStore();
  // Check if 2 values have the same shape. This is needed for affine vector
  // loads and stores.
  if (storeVal.getType() != loadOp.getValue().getType())
    return loadOp;

  if (!domInfo.dominates(lastWriteStoreOp, loadOp)) {
    // Special case when the store is inside of an if statement.
    auto ifOp = lastWriteStoreOp->getParentOfType<mlir::AffineIfOp>();
    lastWriteStoreOp->moveBefore(ifOp);

    // Create a load and select op as the new value to write.
    auto builder = OpBuilder(ifOp);
    builder.setInsertionPoint(lastWriteStoreOp);
    auto newLoad = cast<mlir::AffineReadOpInterface>(builder.clone(*loadOp));
    auto select = builder.create<hls::AffineSelectOp>(
        ifOp.getLoc(), ifOp.getIntegerSet(), ifOp.getOperands(), storeVal,
        newLoad.getValue());
    ifOp->erase();

    auto valueIdx = llvm::find(lastWriteStoreOp->getOperands(), storeVal) -
                    lastWriteStoreOp->operand_begin();
    lastWriteStoreOp->getOpOperand(valueIdx).set(select);
    loadOp.getValue().replaceAllUsesWith(select);

    // Record this to erase later.
    loadOpsToErase.push_back(loadOp);
    return newLoad;
  }

  // Normal case for direct forwarding.
  loadOp.getValue().replaceAllUsesWith(storeVal);
  // Record the memref for a later sweep to optimize away.
  memrefsToErase.insert(loadOp.getMemRef());
  // Record this to erase later.
  loadOpsToErase.push_back(loadOp);
  return mlir::AffineReadOpInterface();
}

// This attempts to find stores which have no impact on the final result.
// A writing op writeA will be eliminated if there exists an op writeB if
// 1) writeA and writeB have mathematically equivalent affine access functions.
// 2) writeB postdominates writeA.
// 3) There is no potential read between writeA and writeB.
static void findUnusedStore(mlir::AffineWriteOpInterface writeA,
                            SmallVectorImpl<Operation *> &opsToErase,
                            SmallPtrSetImpl<Value> &memrefsToErase,
                            PostDominanceInfo &postDominanceInfo) {
  auto memref = writeA.getMemRef();
  for (Operation *user : writeA.getMemRef().getUsers()) {
    // Only consider writing operations.
    auto writeB = dyn_cast<mlir::AffineWriteOpInterface>(user);
    if (!writeB)
      continue;

    // The operations must be distinct.
    if (writeB == writeA)
      continue;

    // Both operations must write to the same memory.
    MemRefAccess srcAccess(writeB);
    MemRefAccess destAccess(writeA);

    if (srcAccess != destAccess)
      continue;

    // Both operations must lie in the same region. Similarly, we consider a
    // special case that when write A is the sole operation in an if statement,
    // where write B is possible to be unused.
    Operation *targetA = writeA;
    Operation *targetB = writeB;
    if (auto ifOpA = dyn_cast<mlir::AffineIfOp>(writeA->getParentOp())) {
      if (!ifOpA.hasElse() &&
          ifOpA.getThenBlock()->getOperations().size() == 2 &&
          ifOpA->getParentRegion()->isAncestor(writeB->getParentRegion()))
        targetA = ifOpA;
      if (auto ifOpB = dyn_cast<mlir::AffineIfOp>(writeB->getParentOp()))
        if (checkSameIfStatement(ifOpA, ifOpB))
          targetB = ifOpB;
    }
    if (targetA->getParentRegion() != targetB->getParentRegion())
      continue;

    // writeB must postdominate writeA.
    if (!postDominanceInfo.postDominates(targetB, targetA))
      continue;

    // There cannot be an operation which reads from memory between
    // the two writes.
    if (!hasNoInterveningEffect<MemoryEffects::Read>(targetA, writeB,
                                                     writeB.getMemRef()))
      continue;

    opsToErase.push_back(targetA);
    break;
  }

  if (llvm::all_of(memref.getUsers(), [&](Operation *ownerOp) {
        return isa<mlir::AffineWriteOpInterface>(ownerOp) ||
               hasSingleEffect<MemoryEffects::Free>(ownerOp, memref);
      }))
    memrefsToErase.insert(memref);
}

// The load to load forwarding / redundant load elimination is similar to the
// store to load forwarding.
// loadA will be be replaced with loadB if:
// 1) loadA and loadB have mathematically equivalent affine access functions.
// 2) loadB dominates loadA.
// 3) There is no write between loadA and loadB.
static void loadCSE(mlir::AffineReadOpInterface loadA,
                    SmallVectorImpl<Operation *> &loadOpsToErase,
                    DominanceInfo &domInfo) {
  if (auto buffer = loadA.getMemRef().getDefiningOp<BufferOp>())
    if (auto initValue = buffer.getInitValue())
      if (llvm::all_of(buffer->getUsers(), [&](Operation *user) {
            if (auto store = dyn_cast<mlir::AffineWriteOpInterface>(user)) {
              if (crossRegionDominates(store, loadA))
                return false;
              if (checkDependence(store, loadA))
                return false;
              return true;
            }
            return true;
          })) {
        auto builder = OpBuilder(loadA);
        builder.setInsertionPoint(loadA);
        auto constantInitValue = builder.create<arith::ConstantOp>(
            loadA.getLoc(), initValue.value());
        loadA.getValue().replaceAllUsesWith(constantInitValue);
        loadOpsToErase.push_back(loadA);
        return;
      }

  SmallVector<mlir::AffineReadOpInterface, 4> loadCandidates;
  for (auto *user : loadA.getMemRef().getUsers()) {
    auto loadB = dyn_cast<mlir::AffineReadOpInterface>(user);
    if (!loadB || loadB == loadA)
      continue;

    MemRefAccess srcAccess(loadB);
    MemRefAccess destAccess(loadA);

    // 1. The accesses have to be to the same location.
    if (srcAccess != destAccess) {
      continue;
    }

    // 2. The store has to dominate the load op to be candidate.
    if (!domInfo.dominates(loadB, loadA))
      continue;

    // 3. There is no write between loadA and loadB.
    if (!hasNoInterveningEffect<MemoryEffects::Write>(loadB.getOperation(),
                                                      loadA, loadA.getMemRef()))
      continue;

    // Check if two values have the same shape. This is needed for affine vector
    // loads.
    if (loadB.getValue().getType() != loadA.getValue().getType())
      continue;

    loadCandidates.push_back(loadB);
  }

  // Of the legal load candidates, use the one that dominates all others
  // to minimize the subsequent need to loadCSE
  Value loadB;
  for (mlir::AffineReadOpInterface option : loadCandidates) {
    if (llvm::all_of(loadCandidates, [&](mlir::AffineReadOpInterface depStore) {
          return depStore == option ||
                 domInfo.dominates(option.getOperation(),
                                   depStore.getOperation());
        })) {
      loadB = option.getValue();
      break;
    }
  }

  if (loadB) {
    loadA.getValue().replaceAllUsesWith(loadB);
    // Record this to erase later.
    loadOpsToErase.push_back(loadA);
  }
}

// The store to load forwarding and load CSE rely on three conditions:
//
// 1) store/load providing a replacement value and load being replaced need to
// have mathematically equivalent affine access functions (checked after full
// composition of load/store operands); this implies that they access the same
// single memref element for all iterations of the common surrounding loop,
//
// 2) the store/load op should dominate the load op,
//
// 3) no operation that may write to memory read by the load being replaced can
// occur after executing the instruction (load or store) providing the
// replacement value and before the load being replaced (thus potentially
// allowing overwriting the memory read by the load).
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
static bool applyAffineStoreForward(func::FuncOp func) {
  DominanceInfo domInfo(func);
  PostDominanceInfo postDomInfo(func);

  // Load op's whose results were replaced by those forwarded from stores.
  SmallVector<Operation *, 8> opsToErase;

  // A list of memref's that are potentially dead / could be eliminated.
  SmallPtrSet<Value, 4> memrefsToErase;

  // Walk all load's and perform store to load forwarding.
  func.walk([&](mlir::AffineReadOpInterface loadOp) {
    auto currentLoadOp = loadOp;
    auto newLoadOp = mlir::AffineReadOpInterface();
    while (1) {
      newLoadOp = forwardStoreToLoad(currentLoadOp, opsToErase, memrefsToErase,
                                     domInfo);
      // If the current load op is erased or failed to transform, break.
      if (!newLoadOp || newLoadOp == currentLoadOp)
        break;
      currentLoadOp = newLoadOp;
    }
    if (newLoadOp)
      loadCSE(newLoadOp, opsToErase, domInfo);
  });

  // Erase all load op's whose results were replaced with store fwd'ed ones.
  for (auto *op : opsToErase)
    op->erase();
  opsToErase.clear();

  // Walk all store's and perform unused store elimination
  func.walk([&](mlir::AffineWriteOpInterface storeOp) {
    findUnusedStore(storeOp, opsToErase, memrefsToErase, postDomInfo);
  });
  // Erase all store op's which don't impact the program
  for (auto *op : opsToErase)
    op->erase();

  // Check if the store fwd'ed memrefs are now left with only stores and
  // deallocs and can thus be completely deleted. Note: the canonicalize pass
  // should be able to do this as well, but we'll do it here since we collected
  // these anyway.
  for (auto memref : memrefsToErase) {
    // If the memref hasn't been locally alloc'ed, skip.
    Operation *defOp = memref.getDefiningOp();
    if (!defOp || !hasSingleEffect<MemoryEffects::Allocate>(defOp, memref))
      // TODO: if the memref was returned by a 'call' operation, we
      // could still erase it if the call had no side-effects.
      continue;
    if (llvm::any_of(memref.getUsers(), [&](Operation *ownerOp) {
          return !isa<mlir::AffineWriteOpInterface>(ownerOp) &&
                 !hasSingleEffect<MemoryEffects::Free>(ownerOp, memref);
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
