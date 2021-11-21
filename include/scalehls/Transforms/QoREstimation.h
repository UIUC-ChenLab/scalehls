//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "external/INIReader.h"
#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/IR/BuiltinOps.h"
#include "scalehls/Dialect/HLSCpp/Visitor.h"
#include "scalehls/Support/Utils.h"
#include "scalehls/Transforms/Utils.h"

namespace mlir {
namespace scalehls {

using LatencyMap = llvm::StringMap<int64_t>;
void getLatencyMap(INIReader spec, LatencyMap &latencyMap);

//===----------------------------------------------------------------------===//
// ScaleHLSEstimator Class Declaration
//===----------------------------------------------------------------------===//

class ScaleHLSEstimator
    : public HLSCppVisitorBase<ScaleHLSEstimator, bool, int64_t> {
public:
  explicit ScaleHLSEstimator(LatencyMap &latencyMap, bool depAnalysis)
      : latencyMap(latencyMap), depAnalysis(depAnalysis) {}

  void estimateFunc(FuncOp func);
  void estimateLoop(AffineForOp loop, FuncOp func);

  using HLSCppVisitorBase::visitOp;
  bool visitUnhandledOp(Operation *op, int64_t begin) {
    // Default latency of any unhandled operation is 0.
    return setTiming(op, begin, begin, 0, 0), true;
  }

  bool visitOp(AffineForOp op, int64_t begin);
  bool visitOp(AffineIfOp op, int64_t begin);
  bool visitOp(CallOp op, int64_t begin);
  bool visitOp(AffineLoadOp op, int64_t begin) {
    return estimateLoadStore(op, begin), true;
  }
  bool visitOp(AffineStoreOp op, int64_t begin) {
    return estimateLoadStore(op, begin), true;
  }
  bool visitOp(memref::LoadOp op, int64_t begin) {
    return setTiming(op, begin, begin + 2, 2, 1), true;
  }
  bool visitOp(memref::StoreOp op, int64_t begin) {
    return setTiming(op, begin, begin + 1, 1, 1), true;
  }

  /// Handle operations with profiled latency.
#define HANDLE(OPTYPE, KEYNAME)                                                \
  bool visitOp(OPTYPE op, int64_t begin) {                                     \
    auto latency = latencyMap[KEYNAME] + 1;                                    \
    setTiming(op, begin, begin + latency, latency, 1);                         \
    return true;                                                               \
  }
  HANDLE(arith::AddFOp, "fadd");
  HANDLE(arith::SubFOp, "fadd");
  HANDLE(arith::MulFOp, "fmul");
  HANDLE(arith::DivFOp, "fdiv");
  HANDLE(arith::CmpFOp, "fcmp");
#undef HANDLE

private:
  // For storing all dependencies indexed by the dependency source operation.
  using Depends = SmallVector<Operation *, 16>;
  using DependsMap = DenseMap<Operation *, Depends>;

  // Hold the memory ports information.
  struct MemPortInfo {
    unsigned rdPort = 0;
    unsigned wrPort = 0;
    unsigned rdwrPort = 0;

    SmallVector<MemRefAccess, 2> rdAccesses;
  };

  // For storing memory port information of all partitions indexed by the
  // {schedule_level, memref}.
  using MemPortInfos = std::vector<MemPortInfo>;
  using MemPortInfosMap = DenseMap<int64_t, DenseMap<Value, MemPortInfos>>;

  // For storing the resource utilization indexed by the schedule level.
  using ResourceAllocMap = DenseMap<int64_t, int64_t>;

  /// Collect all dependencies detected in the function.
  void getFuncDependencies();

  /// LoadOp and StoreOp related methods.
  void getPartitionIndices(Operation *op);
  void estimateLoadStore(Operation *op, int64_t begin);

  /// AffineForOp related methods.
  int64_t getResMinII(int64_t begin, int64_t end, MemAccessesMap &map);
  int64_t getDepMinII(int64_t II, FuncOp func, MemAccessesMap &map);
  int64_t getDepMinII(int64_t II, AffineForOp forOp, MemAccessesMap &map);

  /// Block scheduler and estimator.
  int64_t getDspAllocMap(Block &block, ResourceAllocMap &faddMap,
                         ResourceAllocMap &fmulMap);
  ResourceAttr estimateResource(Block &block, int64_t minII = -1);
  TimingAttr estimateTiming(Block &block, int64_t begin = 0);
  void reverseTiming(Block &block);
  void initEstimator(Block &block);

  DependsMap dependsMap;
  MemPortInfosMap memPortInfosMap;
  LatencyMap &latencyMap;
  bool depAnalysis = true;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
