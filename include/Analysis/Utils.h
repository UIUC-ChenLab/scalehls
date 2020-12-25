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
      return StringRef();
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
      return StringRef();
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

// For storing all affine memory access operations (including CallOp,
// AffineLoadOp, and AffineStoreOp) indexed by the corresponding memref.
using MemAccesses = SmallVector<Operation *, 16>;
using MemAccessesMap = DenseMap<Value, MemAccesses>;

/// Collect all load and store operations in the block. The collected operations
/// in the MemAccessesMap are ordered, which means an operation will never
/// dominate another operation in front of it.
void getMemAccessesMap(Block &block, MemAccessesMap &map,
                       bool includeCalls = false);

// Check if the lhsOp and rhsOp is at the same scheduling level. In this check,
// AffineIfOp is transparent.
Optional<std::pair<Operation *, Operation *>> checkSameLevel(Operation *lhsOp,
                                                             Operation *rhsOp);

// Get the innermost surrounding operation, either an AffineForOp or a FuncOp.
// In this method, AffineIfOp is transparent as well.
Operation *getSurroundingOp(Operation *op);

// Get the pointer of the scrOp's parent loop, which should locate at the same
// level with dstOp's any parent loop.
Operation *getSameLevelDstOp(Operation *srcOp, Operation *dstOp);

/// Get the definition ArrayOp given any memref or memory access operation.
hlscpp::ArrayOp getArrayOp(Value memref);

hlscpp::ArrayOp getArrayOp(Operation *op);

// For storing the intermediate memory and successor loops indexed by the
// predecessor loop.
using Successors = SmallVector<std::pair<Value, Operation *>, 2>;
using SuccessorsMap = DenseMap<Operation *, Successors>;

void getSuccessorsMap(Block &block, SuccessorsMap &map);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_UTILS_H
