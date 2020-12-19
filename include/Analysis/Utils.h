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

  OpBuilder builder;

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

  /// Set schedule attribute methods.
  void setScheduleValue(Operation *op, unsigned begin, unsigned end) {
    setAttrValue(op, "schedule_begin", begin);
    setAttrValue(op, "schedule_end", end);
  }
};

//===----------------------------------------------------------------------===//
// Common Used Type Declarations
//===----------------------------------------------------------------------===//

// Profiled latency map.
using LatencyMap = llvm::StringMap<unsigned>;

// For storing all memory access operations (including AffineLoadOp and
// AffineStoreOp) indexed by the array instance (ArrayOp).
using LoadStores = SmallVector<Operation *, 16>;
using LoadStoresMap = DenseMap<Operation *, LoadStores>;

// For storing all dependent operations indexed by the source operation.
using Depends = SmallVector<Operation *, 16>;
using DependsMap = DenseMap<Operation *, Depends>;

// Indicate the unoccupied memory ports number.
struct PortInfo {
  PortInfo(unsigned rdPort = 0, unsigned wrPort = 0, unsigned rdwrPort = 0)
      : rdPort(rdPort), wrPort(wrPort), rdwrPort(rdwrPort) {}

  unsigned rdPort;
  unsigned wrPort;
  unsigned rdwrPort;
};

// For storing ports number of all partitions indexed by the array instance
// (ArrayOp).
using Ports = SmallVector<PortInfo, 16>;
using PortsMap = DenseMap<Operation *, Ports>;

// For storing PortsMap indexed by the scheduling level.
using PortsMapDict = DenseMap<unsigned, PortsMap>;

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_UTILS_H
