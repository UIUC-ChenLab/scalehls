//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "Dialect/HLSCpp/Visitor.h"
#include "INIReader.h"
#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/LoopUtils.h"
#include "llvm/ADT/TypeSwitch.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// HLSCppToolBase Class Declaration and Definition
//===----------------------------------------------------------------------===//

class HLSCppToolBase {
public:
  explicit HLSCppToolBase(OpBuilder builder) : builder(builder) {}

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
  StringRef getPartitionType(ArrayOp op, unsigned dim) {
    if (auto attr = op.partition_type()[dim].cast<StringAttr>())
      return attr.getValue();
    else
      return "";
  }

  unsigned getPartitionFactor(ArrayOp op, unsigned dim) {
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

  /// Schedule attribute related methods.
  void setScheduleValue(Operation *op, unsigned begin, unsigned end) {
    setAttrValue(op, "schedule_begin", begin);
    setAttrValue(op, "schedule_end", end);
  }

  unsigned getLatencyValue(Operation *op) {
    if (auto latency = getUIntAttrValue(op, "latency"))
      return latency;
    else
      return getUIntAttrValue(op, "schedule_end") -
             getUIntAttrValue(op, "schedule_begin");
  }
};

//===----------------------------------------------------------------------===//
// HLSCppEstimator Class Declaration
//===----------------------------------------------------------------------===//

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

class HLSCppEstimator
    : public HLSCppVisitorBase<HLSCppEstimator, Optional<unsigned>, unsigned>,
      public HLSCppToolBase {
public:
  explicit HLSCppEstimator(FuncOp &func)
      : HLSCppToolBase(OpBuilder(func)), func(func), liveness(Liveness(func)) {
    getFuncMemRefDepends();
  }

  void getFuncMemRefDepends();
  using HLSCppVisitorBase::visitOp;
  Optional<unsigned> visitUnhandledOp(Operation *op, unsigned begin) {
    // Default latency of any unhandled operation is 1.
    setScheduleValue(op, begin, begin + 1);
    return begin + 1;
  }

  int32_t getPartitionIndex(Operation *op);
  unsigned getLoadStoreSchedule(Operation *op, unsigned begin);
  Optional<unsigned> visitOp(AffineLoadOp op, unsigned begin);
  Optional<unsigned> visitOp(AffineStoreOp op, unsigned begin);

  unsigned getResMinII(AffineForOp forOp, LoadStoresMap &map);
  unsigned getDepMinII(AffineForOp forOp, LoadStoresMap &map);
  Optional<unsigned> visitOp(AffineForOp op, unsigned begin);

  Optional<unsigned> visitOp(AffineIfOp op, unsigned begin);
  Optional<unsigned> visitOp(ArrayOp op, unsigned begin);

  Optional<std::pair<unsigned, unsigned>> estimateBlock(Block &block,
                                                        unsigned begin);
  void estimateFunc();

  FuncOp &func;
  Liveness liveness;
  DependsMap dependsMap;
  PortsMapDict portsMapDict;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
