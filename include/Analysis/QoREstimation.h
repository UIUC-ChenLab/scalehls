//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "Analysis/StaticParam.h"
#include "Visitor.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Pass/Pass.h"
#include "llvm/ADT/TypeSwitch.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// HLSCppAnalyzer Class Declaration
//===----------------------------------------------------------------------===//

class HLSCppAnalyzer : public HLSCppVisitorBase<HLSCppAnalyzer, bool> {
public:
  explicit HLSCppAnalyzer(ProcParam &procParam, MemParam &memParam)
      : procParam(procParam), memParam(memParam) {}

  bool inPipeline;

  ProcParam &procParam;
  MemParam &memParam;

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSCppVisitorBase::visitOp;
  bool visitOp(AffineForOp op);
  bool visitOp(AffineIfOp op);

  void analyzeOperation(Operation *op);
  void analyzeFunc(FuncOp func);
  void analyzeBlock(Block &block);
  void analyzeModule(ModuleOp module);
};

//===----------------------------------------------------------------------===//
// QoREstimator Class Declaration
//===----------------------------------------------------------------------===//

class QoREstimator : public HLSCppVisitorBase<QoREstimator, bool> {
public:
  explicit QoREstimator(ProcParam &procParam, MemParam &memParam,
                        std::string targetSpecPath, std::string opLatencyPath);

  // For storing the scheduled time stamp of operations;
  using ScheduleMap = llvm::SmallDenseMap<Operation *, unsigned, 16>;

  // For storing each memory access operations indexed by its targed memory
  // value symbol.
  using MemAccess = std::pair<Value, Operation *>;
  using MemAccessList = SmallVector<MemAccess, 16>;

  // For storing required memory ports for each partition of each array.
  using MemPort = SmallVector<unsigned, 16>;
  using MemPortMap = llvm::SmallDenseMap<Value, MemPort, 16>;

  // This flag indicates that currently the estimator is in a pipelined region,
  // which will impact the estimation strategy.
  bool inPipeline;

  ProcParam &procParam;
  MemParam &memParam;

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSCppVisitorBase::visitOp;
  /// These methods can estimate the performance and resource utilization of a
  /// specific MLIR structure, and update them in procParams or memroyParams.
  bool visitOp(AffineForOp op);
  bool visitOp(AffineIfOp op);

  /// These methods are used for searching longest path in a DAG.
  void alignBlockSchedule(Block &block, ScheduleMap &opScheduleMap,
                          unsigned opSchedule);
  unsigned getBlockSchedule(Block &block, ScheduleMap &opScheduleMap);
  unsigned getBlockII(Block &block, ScheduleMap &opScheduleMap,
                      MemAccessList &memLoadList, MemAccessList &memStoreList,
                      unsigned initInterval);

  /// MLIR component estimators.
  void estimateOperation(Operation *op);
  void estimateFunc(FuncOp func);
  void estimateBlock(Block &block);
  void estimateModule(ModuleOp module);
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
