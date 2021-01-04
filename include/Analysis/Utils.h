//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_UTILS_H
#define SCALEHLS_ANALYSIS_UTILS_H

#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/IR/Operation.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// HLSCppAnalysisBase Class
//===----------------------------------------------------------------------===//

class HLSCppAnalysisBase {
public:
  explicit HLSCppAnalysisBase(OpBuilder builder) : builder(builder) {}
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

  OpBuilder builder;
};

//===----------------------------------------------------------------------===//
// Helper methods
//===----------------------------------------------------------------------===//

// For storing all affine memory access operations (including CallOp,
// AffineLoadOp, and AffineStoreOp) indexed by the corresponding memref.
using MemAccesses = SmallVector<Operation *, 16>;
using MemAccessesMap = DenseMap<Value, MemAccesses>;

/// Collect all load and store operations in the block. The collected operations
/// in the MemAccessesMap are ordered, which means an operation will never
/// dominate another operation in front of it.
void getMemAccessesMap(Block &block, MemAccessesMap &map,
                       bool includeCalls = false);

Optional<std::pair<int64_t, int64_t>>
getBoundOfAffineBound(AffineBound bound, MLIRContext *context);

// Check if the lhsOp and rhsOp is at the same scheduling level. In this check,
// AffineIfOp is transparent.
Optional<std::pair<Operation *, Operation *>> checkSameLevel(Operation *lhsOp,
                                                             Operation *rhsOp);

// Get the pointer of the scrOp's parent loop, which should locate at the same
// level with dstOp's any parent loop.
Operation *getSameLevelDstOp(Operation *srcOp, Operation *dstOp);

AffineMap getLayoutMap(MemRefType memrefType);

// Collect partition factors and overall partition number through analysis the
// layout map of a MemRefType.
int64_t getPartitionFactors(MemRefType memrefType,
                            SmallVector<int64_t, 4> *factors = nullptr);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_UTILS_H
