//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "Dialect/HLSCpp/Visitor.h"
#include "INIReader.h"
#include "mlir/Analysis/AffineAnalysis.h"
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

  /// Set schedule attribute methods.
  void setScheduleValue(Operation *op, unsigned begin, unsigned end) {
    setAttrValue(op, "schedule_begin", begin);
    setAttrValue(op, "schedule_end", end);
  }
};

//===----------------------------------------------------------------------===//
// HLSCppEstimator Class Declaration
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

class HLSCppEstimator
    : public HLSCppVisitorBase<HLSCppEstimator, Optional<unsigned>, unsigned>,
      public HLSCppToolBase {
public:
  explicit HLSCppEstimator(FuncOp &func, LatencyMap &latencyMap)
      : HLSCppToolBase(OpBuilder(func)), func(func), latencyMap(latencyMap) {
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
  Optional<unsigned> visitOp(AffineLoadOp op, unsigned begin) {
    return getLoadStoreSchedule(op, begin);
  }
  Optional<unsigned> visitOp(AffineStoreOp op, unsigned begin) {
    return getLoadStoreSchedule(op, begin);
  }

  unsigned getOpMinII(AffineForOp forOp);
  unsigned getResMinII(LoadStoresMap &map);
  unsigned getDepMinII(AffineForOp forOp, LoadStoresMap &map);
  Optional<unsigned> visitOp(AffineForOp op, unsigned begin);

  Optional<unsigned> visitOp(AffineIfOp op, unsigned begin);
  Optional<unsigned> visitOp(ReturnOp op, unsigned begin);
  Optional<unsigned> visitOp(ArrayOp op, unsigned begin);

  /// Handle operations with profiled latency.
#define HANDLE(OPTYPE, KEYNAME)                                                \
  Optional<unsigned> visitOp(OPTYPE op, unsigned begin) {                      \
    auto end = begin + latencyMap[KEYNAME] + 1;                                \
    setScheduleValue(op, begin, end);                                          \
    return end;                                                                \
  }
  HANDLE(AddFOp, "fadd");
  HANDLE(MulFOp, "fmul");
  HANDLE(DivFOp, "fdiv");
  HANDLE(CmpFOp, "fcmp");
  HANDLE(SelectOp, "fselect");
#undef HANDLE

  Optional<unsigned> estimateBlock(Block &block, unsigned begin);
  void estimateFunc();

  FuncOp &func;
  DependsMap dependsMap;
  PortsMapDict portsMapDict;
  LatencyMap &latencyMap;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
