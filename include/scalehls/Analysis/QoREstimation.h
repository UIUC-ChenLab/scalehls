//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "external/INIReader.h"
#include "mlir/IR/BuiltinOps.h"
#include "scalehls/Analysis/Utils.h"
#include "scalehls/Dialect/HLSCpp/Visitor.h"

namespace mlir {
namespace scalehls {

using LatencyMap = llvm::StringMap<int64_t>;
void getLatencyMap(INIReader spec, LatencyMap &latencyMap);

class HLSCppEstimator
    : public HLSCppVisitorBase<HLSCppEstimator, bool, int64_t>,
      public HLSCppAnalysisBase {
public:
  explicit HLSCppEstimator(FuncOp func, LatencyMap &latencyMap)
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

  /// For storing all resource types.
  struct Resource {
    int64_t bram;
    int64_t dsp;
    int64_t ff;
    int64_t lut;

    Resource(int64_t bram = 0, int64_t dsp = 0, int64_t ff = 0, int64_t lut = 0)
        : bram(bram), dsp(dsp), ff(ff), lut(lut) {}
  };

  /// Collect all dependencies detected in the function.
  void getFuncDependencies();

  void setResourceValue(Operation *op, Resource resource) {
    setAttrValue(op, "bram", resource.bram);
    setAttrValue(op, "dsp", resource.dsp);
    setAttrValue(op, "ff", resource.ff);
    setAttrValue(op, "lut", resource.lut);
  }

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
  void getPartitionIndex(Operation *op);
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
  int64_t getResMinII(MemAccessesMap &map);
  int64_t getDepMinII(FuncOp func, MemAccessesMap &map);
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
  HANDLE(SubFOp, "fadd");
  HANDLE(MulFOp, "fmul");
  HANDLE(DivFOp, "fdiv");
  HANDLE(CmpFOp, "fcmp");
#undef HANDLE

  /// Block scheduler and estimator.
  int64_t getDSPMap(Block &block, ResourceMap &faddMap, ResourceMap &fmulMap);
  Resource estimateResource(Block &block, int64_t interval = -1);
  Optional<std::pair<int64_t, int64_t>> estimateBlock(Block &block,
                                                      int64_t begin);
  void reverseSchedule();
  void estimateFunc();

  FuncOp func;
  DependsMap dependsMap;
  PortsMapDict portsMapDict;
  LatencyMap &latencyMap;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
