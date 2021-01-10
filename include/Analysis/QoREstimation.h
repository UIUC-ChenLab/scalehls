//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "Analysis/Utils.h"
#include "Dialect/HLSCpp/Visitor.h"
#include "INIReader.h"

namespace mlir {
namespace scalehls {

using LatencyMap = llvm::StringMap<int64_t>;
void getLatencyMap(INIReader spec, LatencyMap &latencyMap);

class HLSCppEstimator
    : public HLSCppVisitorBase<HLSCppEstimator, bool, int64_t>,
      public HLSCppAnalysisBase {
public:
  explicit HLSCppEstimator(FuncOp &func, LatencyMap &latencyMap)
      : HLSCppAnalysisBase(OpBuilder(func)), func(func),
        latencyMap(latencyMap) {
    getFuncDependencies();
  }

  // For storing all dependencies indexed by the dependency source operation.
  using Depends = SmallVector<Operation *, 16>;
  using DependsMap = DenseMap<Operation *, Depends>;

  // Indicate the unoccupied memory ports number.
  struct PortInfo {
    unsigned rdPort;
    unsigned wrPort;
    unsigned rdwrPort;

    PortInfo(unsigned rdPort = 0, unsigned wrPort = 0, unsigned rdwrPort = 0)
        : rdPort(rdPort), wrPort(wrPort), rdwrPort(rdwrPort) {}
  };

  // For storing ports number of all partitions indexed by the memref.
  using Ports = SmallVector<PortInfo, 16>;
  using PortsMap = DenseMap<Value, Ports>;
  // For storing PortsMap indexed by the scheduling level.
  using PortsMapDict = DenseMap<int64_t, PortsMap>;

  // For storing the DSP resource utilization indexed by the schedule level.
  using ResourceMap = DenseMap<int64_t, int64_t>;

  /// Collect all dependencies detected in the function.
  void getFuncDependencies();

  void setScheduleValue(Operation *op, int64_t begin, int64_t end) {
    setAttrValue(op, "schedule_begin", begin);
    setAttrValue(op, "schedule_end", end);
  }

  using HLSCppVisitorBase::visitOp;
  bool visitUnhandledOp(Operation *op, int64_t begin) {
    // Default latency of any unhandled operation is 0.
    setScheduleValue(op, begin, begin);
    return true;
  }

  /// LoadOp and StoreOp related methods.
  int64_t getPartitionIndex(Operation *op);
  void estimateLoadStore(Operation *op, int64_t begin);
  bool visitOp(AffineLoadOp op, int64_t begin) {
    return estimateLoadStore(op, begin), true;
  }
  bool visitOp(AffineStoreOp op, int64_t begin) {
    return estimateLoadStore(op, begin), true;
  }
  bool visitOp(LoadOp op, int64_t begin) {
    setScheduleValue(op, begin, begin + 2);
    return true;
  }
  bool visitOp(StoreOp op, int64_t begin) {
    setScheduleValue(op, begin, begin + 1);
    return true;
  }

  /// AffineForOp related methods.
  // unsigned getOpMinII(AffineForOp forOp);
  int64_t getResMinII(MemAccessesMap &map);
  int64_t getDepMinII(AffineForOp forOp, MemAccessesMap &map);
  bool visitOp(AffineForOp op, int64_t begin);

  /// Other operation handlers.
  bool visitOp(AffineIfOp op, int64_t begin);
  bool visitOp(CallOp op, int64_t begin);

  /// Handle operations with profiled latency.
#define HANDLE(OPTYPE, KEYNAME)                                                \
  bool visitOp(OPTYPE op, int64_t begin) {                                     \
    setScheduleValue(op, begin, begin + latencyMap[KEYNAME] + 1);              \
    return true;                                                               \
  }
  HANDLE(AddFOp, "fadd");
  HANDLE(MulFOp, "fmul");
  HANDLE(DivFOp, "fdiv");
  HANDLE(CmpFOp, "fcmp");
#undef HANDLE

  /// Block scheduler and estimator.
  int64_t getResourceMap(Block &block, ResourceMap &addFMap,
                         ResourceMap &mulFMap);
  int64_t estimateResource(Block &block);
  Optional<std::pair<int64_t, int64_t>> estimateBlock(Block &block,
                                                      int64_t begin);
  void reverseSchedule();
  void estimateFunc();

  FuncOp &func;
  DependsMap dependsMap;
  PortsMapDict portsMapDict;
  LatencyMap &latencyMap;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
