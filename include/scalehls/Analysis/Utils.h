//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_UTILS_H
#define SCALEHLS_ANALYSIS_UTILS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"

namespace mlir {
namespace scalehls {

using AffineLoopBand = SmallVector<AffineForOp, 6>;
using AffineLoopBands = std::vector<AffineLoopBand>;

// For storing all affine memory access operations (including AffineLoadOp, and
// AffineStoreOp) indexed by the corresponding memref.
using MemAccessesMap = DenseMap<Value, SmallVector<Operation *, 16>>;

/// Collect all load and store operations in the block and return them in "map".
void getMemAccessesMap(Block &block, MemAccessesMap &map);

/// Check if the lhsOp and rhsOp are in the same block. If so, return their
/// ancestors that are located at the same block. Note that in this check,
/// AffineIfOp is transparent.
Optional<std::pair<Operation *, Operation *>> checkSameLevel(Operation *lhsOp,
                                                             Operation *rhsOp);

unsigned getCommonSurroundingLoops(Operation *A, Operation *B,
                                   AffineLoopBand *band);

/// Calculate the upper and lower bound of "bound" if possible.
Optional<std::pair<int64_t, int64_t>> getBoundOfAffineBound(AffineBound bound);

/// Return the layout map of "memrefType".
AffineMap getLayoutMap(MemRefType memrefType);

// Calculate partition factors through analyzing the "memrefType" and return
// them in "factors". Meanwhile, the overall partition number is calculated and
// returned as well.
int64_t getPartitionFactors(MemRefType memrefType,
                            SmallVector<int64_t, 8> *factors = nullptr);

bool isFullyPartitioned(MemRefType memrefType);

/// Get the whole loop band given the outermost loop and return it in "band".
/// Meanwhile, the return value is the innermost loop of this loop band.
AffineForOp getLoopBandFromOutermost(AffineForOp forOp, AffineLoopBand &band);

/// Collect all loop bands in the "block" and return them in "bands". If
/// "allowHavingChilds" is true, loop bands containing more than 1 other loop
/// bands are also collected. Otherwise, only loop bands that contains no child
/// loops are collected.
void getLoopBands(Block &block, AffineLoopBands &bands,
                  bool allowHavingChilds = false);

Optional<unsigned> getAverageTripCount(AffineForOp forOp);

bool checkDependence(Operation *A, Operation *B);

//===----------------------------------------------------------------------===//
// ScaleHLSAnalysisBase Class Declaration
//===----------------------------------------------------------------------===//

class ScaleHLSAnalysisBase {
public:
  explicit ScaleHLSAnalysisBase(Builder &builder) : builder(builder) {}
  /// Get attribute value methods.
  int64_t getIntAttrValue(Operation *op, StringRef name) {
    if (auto attr = op->getAttrOfType<IntegerAttr>(name))
      return attr.getInt();
    else
      return -1;
  }

  bool getBoolAttrValue(Operation *op, StringRef name) {
    if (auto attr = op->getAttrOfType<BoolAttr>(name))
      return attr.getValue();
    else
      return false;
  }

  StringRef getStrAttrValue(Operation *op, StringRef name) {
    if (auto attr = op->getAttrOfType<StringAttr>(name))
      return attr.getValue();
    else
      return StringRef();
  }

  SmallVector<int64_t, 8> getIntArrayAttrValue(Operation *op, StringRef name) {
    SmallVector<int64_t, 8> array;
    if (auto arrayAttr = op->getAttrOfType<ArrayAttr>(name)) {
      for (auto attr : arrayAttr)
        if (auto intAttr = attr.dyn_cast<IntegerAttr>())
          array.push_back(intAttr.getInt());
        else
          return SmallVector<int64_t, 8>();
      return array;
    } else
      return SmallVector<int64_t, 8>();
  }

  /// Set attribute value methods.
  void setAttrValue(Operation *op, StringRef name, int64_t value) {
    op->setAttr(name, builder.getI64IntegerAttr(value));
  }

  void setAttrValue(Operation *op, StringRef name, bool value) {
    op->setAttr(name, builder.getBoolAttr(value));
  }

  void setAttrValue(Operation *op, StringRef name, StringRef value) {
    op->setAttr(name, builder.getStringAttr(value));
  }

  void setAttrValue(Operation *op, StringRef name, ArrayRef<int64_t> value) {
    op->setAttr(name, builder.getI64ArrayAttr(value));
  }

  Builder &builder;
};

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

#endif // SCALEHLS_ANALYSIS_UTILS_H
