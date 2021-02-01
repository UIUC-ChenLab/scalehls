//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_UTILS_H
#define SCALEHLS_ANALYSIS_UTILS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// HLSCppAnalysisBase Class
//===----------------------------------------------------------------------===//

class HLSCppAnalysisBase {
public:
  explicit HLSCppAnalysisBase(OpBuilder &builder) : builder(builder) {}
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

  OpBuilder &builder;
};

//===----------------------------------------------------------------------===//
// Helper methods
//===----------------------------------------------------------------------===//

using AffineLoopBand = SmallVector<AffineForOp, 6>;
using AffineLoopBands = std::vector<AffineLoopBand>;

// For storing all affine memory access operations (including CallOp,
// AffineLoadOp, and AffineStoreOp) indexed by the corresponding memref.
using MemAccesses = SmallVector<Operation *, 16>;
using MemAccessesMap = DenseMap<Value, MemAccesses>;

/// Collect all load and store operations in the block. The collected operations
/// in the MemAccessesMap are ordered, which means an operation will never
/// dominate another operation in front of it.
void getMemAccessesMap(Block &block, MemAccessesMap &map);

// Check if the lhsOp and rhsOp is at the same scheduling level. In this check,
// AffineIfOp is transparent.
Optional<std::pair<Operation *, Operation *>> checkSameLevel(Operation *lhsOp,
                                                             Operation *rhsOp);

// Get the pointer of the scrOp's parent loop, which should locate at the same
// level with dstOp's any parent loop.
Operation *getSameLevelDstOp(Operation *srcOp, Operation *dstOp);

Optional<std::pair<int64_t, int64_t>> getBoundOfAffineBound(AffineBound bound);

AffineMap getLayoutMap(MemRefType memrefType);

// Collect partition factors and overall partition number through analyzing the
// layout map of a MemRefType.
int64_t getPartitionFactors(MemRefType memrefType,
                            SmallVector<int64_t, 8> *factors = nullptr);

/// This is method for finding the number of child loops which immediatedly
/// contained by the input operation.
unsigned getChildLoopNum(Operation *op);

AffineForOp getLoopBandFromRoot(AffineForOp forOp, AffineLoopBand &band);
AffineForOp getLoopBandFromLeaf(AffineForOp forOp, AffineLoopBand &band);

/// Collect all loop bands in the function. If allowHavingChilds is false,
/// only innermost loop bands will be collected.
void getLoopBands(Block &block, AffineLoopBands &bands,
                  bool allowHavingChilds = false);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_UTILS_H
