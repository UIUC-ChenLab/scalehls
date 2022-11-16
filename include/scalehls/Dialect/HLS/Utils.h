//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_SUPPORT_UTILS_H
#define SCALEHLS_SUPPORT_UTILS_H

#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "scalehls/Dialect/HLS/HLS.h"

namespace mlir {
namespace scalehls {

using namespace hls;

using AffineLoopBand = SmallVector<AffineForOp, 6>;
using AffineLoopBands = std::vector<AffineLoopBand>;
using FactorList = SmallVector<unsigned, 8>;

//===----------------------------------------------------------------------===//
// Dataflow utils
//===----------------------------------------------------------------------===//

/// Get the root affine loop contained by the node.
AffineForOp getNodeRootLoop(NodeOp currentNode);

/// Get the affine loop band contained by the node.
AffineLoopBand getNodeLoopBand(NodeOp currentNode);

/// Wrap the operations in the block with dispatch op.
DispatchOp dispatchBlock(Block *block);

/// Fuse the given operations into a new task. The new task will be created
/// before the first operation or last operation and each operation will be
/// inserted in order. This method always succeeds even if the resulting IR is
/// invalid.
TaskOp fuseOpsIntoTask(ArrayRef<Operation *> ops, PatternRewriter &rewriter,
                       bool insertToLastOp = false);

/// Fuse multiple nodes into a new node.
NodeOp fuseNodeOps(ArrayRef<NodeOp> nodes, PatternRewriter &rewriter);

/// Get the consumer/producer nodes of the given buffer expect the given op.
SmallVector<NodeOp> getConsumersExcept(Value buffer, NodeOp except);
SmallVector<NodeOp> getProducersExcept(Value buffer, NodeOp except);
SmallVector<NodeOp> getConsumers(Value buffer);
SmallVector<NodeOp> getProducers(Value buffer);
SmallVector<NodeOp> getDependentConsumers(Value buffer, NodeOp node);

/// Get the depth of a buffer or stream channel. Note that only if the defining
/// operation of the buffer is not a BufferOp or stream types, the returned
/// result will be 1.
unsigned getBufferDepth(Value memref);

/// Find buffer value or buffer op across the dataflow hierarchy.
Value findBuffer(Value memref);
hls::BufferLikeInterface findBufferOp(Value memref);

bool isExternalBuffer(Value memref);

/// Check whether the given use has read/write semantics.
bool isRead(OpOperand &use);
bool isWritten(OpOperand &use);

void populateBufferConversionPatterns(RewritePatternSet &patterns);

//===----------------------------------------------------------------------===//
// Linalg analysis utils
//===----------------------------------------------------------------------===//

bool isElementwiseGenericOp(linalg::GenericOp op);

//===----------------------------------------------------------------------===//
// Memory and loop analysis utils
//===----------------------------------------------------------------------===//

/// Reduces each tile size to the largest divisor of the corresponding trip
/// count (if the trip count is known).
void adjustToDivisorsOfTripCounts(ArrayRef<AffineForOp> band,
                                  SmallVectorImpl<unsigned> *tileSizes);

/// The current op or contained ops have effect on external buffers.
bool hasEffectOnExternalBuffer(Operation *op);

/// Distribute the given factor from the innermost loop of the given loop band,
/// so that we can apply vectorize, unroll and jam, etc.
FactorList
getDistributedFactors(unsigned factor,
                      const SmallVectorImpl<mlir::AffineForOp> &band);

/// Distribute the given factor evenly on all loop levels, this method can fail
/// due to non-constant loop bounds.
LogicalResult
getEvenlyDistributedFactors(unsigned factor, FactorList &factors,
                            const SmallVectorImpl<mlir::AffineForOp> &band);

/// Return a pair which indicates whether the if statement is always true or
/// false, respectively. The returned result is one-hot.
std::pair<bool, bool> ifAlwaysTrueOrFalse(mlir::AffineIfOp ifOp);

/// Check whether the two given if statements have the same condition.
bool checkSameIfStatement(AffineIfOp lhsOp, AffineIfOp rhsOp);

/// Parse array attributes.
SmallVector<int64_t, 8> getIntArrayAttrValue(Operation *op, StringRef name);

/// For storing all affine memory access operations (including AffineLoadOp, and
/// AffineStoreOp) indexed by the corresponding memref.
using MemAccessesMap = DenseMap<Value, SmallVector<Operation *, 16>>;

/// Collect all load and store operations in the block and return them in "map".
void getMemAccessesMap(Block &block, MemAccessesMap &map,
                       bool includeVectorTransfer = false);

bool crossRegionDominates(Operation *a, Operation *b);

/// Check if the lhsOp and rhsOp are in the same block. If so, return their
/// ancestors that are located at the same block. Note that in this check,
/// AffineIfOp is transparent.
Optional<std::pair<Operation *, Operation *>> checkSameLevel(Operation *lhsOp,
                                                             Operation *rhsOp);

unsigned getCommonSurroundingLoops(Operation *A, Operation *B,
                                   AffineLoopBand *band);

/// Calculate the upper and lower bound of the affine map if possible.
Optional<std::pair<int64_t, int64_t>> getBoundOfAffineMap(AffineMap map,
                                                          ValueRange operands);

/// Calculate partition factors through analyzing the "memrefType" and return
/// them in "factors". Meanwhile, the overall partition number is calculated and
/// returned as well.
int64_t getPartitionFactors(MemRefType memrefType,
                            SmallVector<int64_t, 8> *factors = nullptr);

bool isFullyPartitioned(MemRefType memrefType);

/// This is method for finding the number of child loops which immediatedly
/// contained by the input operation.
unsigned getChildLoopNum(Operation *op);

/// Given a tiled loop band, return true and get the tile (tile-space) loop
/// band and the point (intra-tile) loop band. If failed, return false.
bool getTileAndPointLoopBand(const AffineLoopBand &band,
                             AffineLoopBand &tileBand,
                             AffineLoopBand &pointBand);

bool getParallelAndReductionLoopBand(const AffineLoopBand &band,
                                     AffineLoopBand &parallelBand,
                                     AffineLoopBand &reductionBand);

/// Get the whole loop band given the outermost or innermost loop and return it
/// in "band". Meanwhile, the return value is the innermost or outermost loop of
/// this loop band.
AffineForOp getLoopBandFromOutermost(AffineForOp forOp, AffineLoopBand &band);
AffineForOp getLoopBandFromInnermost(AffineForOp forOp, AffineLoopBand &band);

/// Collect all loop bands in the "block" and return them in "bands". If
/// "allowHavingChilds" is true, loop bands containing more than 1 other loop
/// bands are also collected. Otherwise, only loop bands that contains no child
/// loops are collected.
void getLoopBands(Block &block, AffineLoopBands &bands,
                  bool allowHavingChilds = false);

void getArrays(Block &block, SmallVectorImpl<Value> &arrays,
               bool allowArguments = true);

Optional<unsigned> getAverageTripCount(AffineForOp forOp);

bool checkDependence(Operation *A, Operation *B);

func::FuncOp getTopFunc(ModuleOp module, std::string topFuncName = "");

func::FuncOp getRuntimeFunc(ModuleOp module, std::string runtimeFuncName = "");

/// Ensure that all operations that could be executed after `start`
/// (noninclusive) and prior to `memOp` (e.g. on a control flow/op path between
/// the operations) do not have the potential memory effect `EffectType` on
/// `memOp`. `memOp`  is an operation that reads or writes to a memref. For
/// example, if `EffectType` is MemoryEffects::Write, this method will check if
/// there is no write to the memory between `start` and `memOp` that would
/// change the read within `memOp`.
template <typename EffectType>
bool hasNoInterveningEffect(Operation *start, Operation *memOp, Value memref) {
  auto isLocallyAllocated = [](Value memref) {
    auto *defOp = memref.getDefiningOp();
    return defOp && hasSingleEffect<MemoryEffects::Allocate>(defOp, memref);
  };

  // A boolean representing whether an intervening operation could have impacted
  // memOp.
  bool hasSideEffect = false;

  // Check whether the effect on memOp can be caused by a given operation op.
  std::function<void(Operation *)> checkOperation = [&](Operation *op) {
    // If the effect has alreay been found, early exit,
    if (hasSideEffect)
      return;

    if (auto memEffect = dyn_cast<MemoryEffectOpInterface>(op)) {
      SmallVector<MemoryEffects::EffectInstance, 1> effects;
      memEffect.getEffects(effects);

      bool opMayHaveEffect = false;
      for (auto effect : effects) {
        // If op causes EffectType on a potentially aliasing location for memOp,
        // mark as having the effect.
        if (isa<EffectType>(effect.getEffect())) {
          // TODO: This should be replaced with a check for no aliasing.
          // Aliasing information should be passed to this method.
          if (effect.getValue() && effect.getValue() != memref &&
              isLocallyAllocated(memref) &&
              isLocallyAllocated(effect.getValue()))
            continue;
          opMayHaveEffect = true;
          break;
        }
      }

      if (!opMayHaveEffect)
        return;

      // If the side effect comes from an affine read or write, try to prove the
      // side effecting `op` cannot reach `memOp`.
      if (isa<AffineReadOpInterface, AffineWriteOpInterface>(op) &&
          isa<AffineReadOpInterface, AffineWriteOpInterface>(memOp)) {
        MemRefAccess srcAccess(op);
        MemRefAccess destAccess(memOp);

        // FIXME: This is unsafe as the two memref may be alias with each other.
        // This is also one of the most important change from the MLIR in-tree
        // scalar replacement.
        if (srcAccess.memref != destAccess.memref)
          return;

        // Affine dependence analysis here is applicable only if both ops
        // operate on the same memref and if `op`, `memOp`, and `start` are in
        // the same AffineScope.
        if (getAffineScope(op) == getAffineScope(memOp) &&
            getAffineScope(op) == getAffineScope(start)) {
          // Number of loops containing the start op and the ending operation.
          unsigned minSurroundingLoops =
              getNumCommonSurroundingLoops(*start, *memOp);

          // Number of loops containing the operation `op` which has the
          // potential memory side effect and can occur on a path between
          // `start` and `memOp`.
          unsigned nsLoops = getNumCommonSurroundingLoops(*op, *memOp);

          // For ease, let's consider the case that `op` is a store and we're
          // looking for other potential stores (e.g `op`) that overwrite memory
          // after `start`, and before being read in `memOp`. In this case, we
          // only need to consider other potential stores with depth >
          // minSurrounding loops since `start` would overwrite any store with a
          // smaller number of surrounding loops before.
          unsigned d;
          FlatAffineValueConstraints dependenceConstraints;
          for (d = nsLoops + 1; d > minSurroundingLoops; d--) {
            DependenceResult result = checkMemrefAccessDependence(
                srcAccess, destAccess, d, &dependenceConstraints,
                /*dependenceComponents=*/nullptr);
            // A dependence failure or the presence of a dependence implies a
            // side effect.
            if (!noDependence(result)) {
              hasSideEffect = true;
              return;
            }
          }

          // No side effect was seen, simply return.
          return;
        }
        // TODO: Check here if the memrefs alias: there is no side effect if
        // `srcAccess.memref` and `destAccess.memref` don't alias.
      }
      // We have an op with a memory effect and we cannot prove if it
      // intervenes.
      hasSideEffect = true;
      return;
    }

    if (op->hasTrait<OpTrait::HasRecursiveMemoryEffects>()) {
      // Recurse into the regions for this op and check whether the internal
      // operations may have the side effect `EffectType` on memOp.
      for (Region &region : op->getRegions())
        for (Block &block : region)
          for (Operation &op : block)
            checkOperation(&op);
      return;
    }

    // Otherwise, conservatively assume generic operations have the effect
    // on the operation.
    hasSideEffect = true;
  };

  // Check all paths from ancestor op `parent` to the operation `to` for the
  // effect. It is known that `to` must be contained within `parent`.
  auto until = [&](Operation *parent, Operation *to) {
    // TODO check only the paths from `parent` to `to`.
    // Currently we fallback and check the entire parent op, rather than
    // just the paths from the parent path, stopping after reaching `to`.
    // This is conservatively correct, but could be made more aggressive.
    assert(parent->isAncestor(to));
    checkOperation(parent);
  };

  // Check for all paths from operation `from` to operation `untilOp` for the
  // given memory effect.
  std::function<void(Operation *, Operation *)> recur =
      [&](Operation *from, Operation *untilOp) {
        assert(
            from->getParentRegion()->isAncestor(untilOp->getParentRegion()) &&
            "Checking for side effect between two operations without a common "
            "ancestor");

        // If the operations are in different regions, recursively consider all
        // path from `from` to the parent of `to` and all paths from the parent
        // of `to` to `to`.
        if (from->getParentRegion() != untilOp->getParentRegion()) {
          recur(from, untilOp->getParentOp());
          until(untilOp->getParentOp(), untilOp);
          return;
        }

        // Now, assuming that `from` and `to` exist in the same region, perform
        // a CFG traversal to check all the relevant operations.

        // Additional blocks to consider.
        SmallVector<Block *, 2> todoBlocks;
        {
          // First consider the parent block of `from` an check all operations
          // after `from`.
          for (auto iter = ++from->getIterator(), end = from->getBlock()->end();
               iter != end && &*iter != untilOp; ++iter) {
            checkOperation(&*iter);
          }

          // If the parent of `from` doesn't contain `to`, add the successors
          // to the list of blocks to check.
          if (untilOp->getBlock() != from->getBlock())
            for (Block *succ : from->getBlock()->getSuccessors())
              todoBlocks.push_back(succ);
        }

        llvm::SmallDenseSet<Block *, 4> done;
        // Traverse the CFG until hitting `to`.
        while (!todoBlocks.empty()) {
          Block *blk = todoBlocks.pop_back_val();
          if (done.count(blk))
            continue;
          done.insert(blk);
          for (auto &op : *blk) {
            if (&op == untilOp)
              break;
            checkOperation(&op);
            if (&op == blk->getTerminator())
              for (Block *succ : blk->getSuccessors())
                todoBlocks.push_back(succ);
          }
        }
      };

  recur(start, memOp);
  return !hasSideEffect;
}

//===----------------------------------------------------------------------===//
// PtrLikeMemRefAccess Struct Declaration
//===----------------------------------------------------------------------===//

/// Encapsulates a memref load or store access information.
struct PtrLikeMemRefAccess {
  Value memref = nullptr;
  AffineValueMap accessMap;

  void *impl = nullptr;

  /// Constructs a MemRefAccess from a load or store operation.
  explicit PtrLikeMemRefAccess(Operation *opInst);

  PtrLikeMemRefAccess(const void *impl) : impl(const_cast<void *>(impl)) {}

  bool operator==(const PtrLikeMemRefAccess &rhs) const;

  llvm::hash_code getHashValue() {
    return llvm::hash_combine(memref, accessMap.getAffineMap(),
                              accessMap.getOperands(), impl);
  }
};

using ReverseOpIteratorsMap =
    DenseMap<PtrLikeMemRefAccess,
             SmallVector<std::reverse_iterator<Operation **>, 16>>;
using OpIteratorsMap =
    DenseMap<PtrLikeMemRefAccess, SmallVector<Operation **, 16>>;

} // namespace scalehls
} // namespace mlir

//===----------------------------------------------------------------------===//
// Make PtrLikeMemRefAccess eligible as key of DenseMap
//===----------------------------------------------------------------------===//

namespace llvm {

template <> struct DenseMapInfo<mlir::scalehls::PtrLikeMemRefAccess> {
  static mlir::scalehls::PtrLikeMemRefAccess getEmptyKey() {
    auto pointer = llvm::DenseMapInfo<void *>::getEmptyKey();
    return mlir::scalehls::PtrLikeMemRefAccess(pointer);
  }
  static mlir::scalehls::PtrLikeMemRefAccess getTombstoneKey() {
    auto pointer = llvm::DenseMapInfo<void *>::getTombstoneKey();
    return mlir::scalehls::PtrLikeMemRefAccess(pointer);
  }
  static unsigned getHashValue(mlir::scalehls::PtrLikeMemRefAccess access) {
    return access.getHashValue();
  }
  static bool isEqual(mlir::scalehls::PtrLikeMemRefAccess lhs,
                      mlir::scalehls::PtrLikeMemRefAccess rhs) {
    return lhs == rhs;
  }
};

} // namespace llvm

#endif // SCALEHLS_SUPPORT_UTILS_H
