//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_QORESTIMATION_H
#define SCALEHLS_TRANSFORMS_QORESTIMATION_H

#include "StaticParam.h"
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

  ProcParam &procParam;
  MemParam &memParam;

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSCppVisitorBase::visitOp;
  bool visitOp(AffineForOp op);
  bool visitOp(AffineParallelOp op);
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

  ProcParam &procParam;
  MemParam &memParam;

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSCppVisitorBase::visitOp;
  /// These methods can estimate the performance and resource utilization of a
  /// specific MLIR structure, and update them in procParams or memroyParams.
  bool visitOp(AffineForOp op);
  bool visitOp(AffineParallelOp op);
  bool visitOp(AffineIfOp op);

  /// These methods are used for searching longest path in a DAG.
  void updateValueTimeStamp(Operation *currentOp, unsigned opTimeStamp,
                            DenseMap<Value, unsigned> &valueTimeStampMap);
  unsigned searchLongestPath(Block &block);

  /// MLIR component estimators.
  void estimateOperation(Operation *op);
  void estimateFunc(FuncOp func);
  void estimateBlock(Block &block);
  void estimateModule(ModuleOp module);
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_QORESTIMATION_H
