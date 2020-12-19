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

  /// Get partition information methods.
  StringRef getPartitionType(hlscpp::ArrayOp op, unsigned dim) {
    if (auto attr = op.partition_type()[dim].cast<StringAttr>())
      return attr.getValue();
    else
      return "";
  }

  unsigned getPartitionFactor(hlscpp::ArrayOp op, unsigned dim) {
    if (auto attr = op.partition_factor()[dim].cast<IntegerAttr>())
      return attr.getUInt();
    else
      return 0;
  }

  /// Get attribute value methods.
  int32_t getIntAttrValue(Operation *op, StringRef name) {
    if (auto attr = op->getAttrOfType<IntegerAttr>(name))
      return attr.getInt();
    else
      return -1;
  }

  unsigned getUIntAttrValue(Operation *op, StringRef name) {
    if (auto attr = op->getAttrOfType<IntegerAttr>(name))
      return attr.getUInt();
    else
      return 0;
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
      return "";
  }

  /// Set attribute value methods.
  void setAttrValue(Operation *op, StringRef name, int32_t value) {
    op->setAttr(name, builder.getI32IntegerAttr(value));
  }

  void setAttrValue(Operation *op, StringRef name, unsigned value) {
    op->setAttr(name, builder.getUI32IntegerAttr(value));
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

// For storing all affine memory access operations (including AffineLoadOp and
// AffineStoreOp) indexed by the array (ArrayOp).
using LoadStores = SmallVector<Operation *, 16>;
using LoadStoresMap = DenseMap<Operation *, LoadStores>;

// Check if the lhsOp and rhsOp is at the same scheduling level. In this check,
// AffineIfOp is transparent.
bool checkSameLevel(Operation *lhsOp, Operation *rhsOp);

// Get the pointer of the scrOp's parent loop, which should locate at the same
// level with dstOp's any parent loop.
Operation *getSameLevelDstOp(Operation *srcOp, Operation *dstOp);

/// Get the definition ArrayOp given any memory access operation.
hlscpp::ArrayOp getArrayOp(Operation *op);

/// Collect all load and store operations in the block.
void getLoadStoresMap(Block &block, LoadStoresMap &map);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_UTILS_H
