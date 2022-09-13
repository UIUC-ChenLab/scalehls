//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_SUPPORT_UTILS_H
#define SCALEHLS_SUPPORT_UTILS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "scalehls/Dialect/HLS/HLS.h"

namespace mlir {
namespace scalehls {

using namespace hls;

//===----------------------------------------------------------------------===//
// Dataflow utils
//===----------------------------------------------------------------------===//

ScheduleOp wrapWithSchedule(Block *block);

/// Fuse the given operations into a new task. The new task will be created
/// before the first operation and each operation will be inserted in order.
/// This method always succeeds even if the resulting IR is invalid.
TaskOp fuseOpsIntoTask(ArrayRef<Operation *> ops, PatternRewriter &rewriter);

SmallVector<NodeOp, 4> getConsumersExcept(Value buffer, NodeOp exceptedOp);
SmallVector<NodeOp, 4> getProducersExcept(Value buffer, NodeOp exceptedOp);
SmallVector<NodeOp, 4> getConsumers(Value buffer);
SmallVector<NodeOp, 4> getProducers(Value buffer);

bool isInputOutput(Value value);

//===----------------------------------------------------------------------===//
// Memory and loop analysis utils
//===----------------------------------------------------------------------===//

/// Parse array attributes.
SmallVector<int64_t, 8> getIntArrayAttrValue(Operation *op, StringRef name);

using AffineLoopBand = SmallVector<AffineForOp, 6>;
using AffineLoopBands = std::vector<AffineLoopBand>;

/// For storing all affine memory access operations (including AffineLoadOp, and
/// AffineStoreOp) indexed by the corresponding memref.
using MemAccessesMap = DenseMap<Value, SmallVector<Operation *, 16>>;

/// Collect all load and store operations in the block and return them in "map".
void getMemAccessesMap(Block &block, MemAccessesMap &map,
                       bool includeVectorTransfer = false);

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

/// Get the whole loop band given the outermost loop and return it in "band".
/// Meanwhile, the return value is the innermost loop of this loop band.
AffineForOp getLoopBandFromOutermost(AffineForOp forOp, AffineLoopBand &band);

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
