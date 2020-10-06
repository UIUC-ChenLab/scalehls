//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "INIReader.h"
#include "Visitor.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Pass/Pass.h"
#include "llvm/ADT/TypeSwitch.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// HLSCppToolBase Class Declaration
//===----------------------------------------------------------------------===//

class HLSCppToolBase {
public:
  explicit HLSCppToolBase(OpBuilder &builder) : builder(builder) {}

  /// Get value methods.
  unsigned getUIntAttrValue(Operation *op, StringRef name) {
    return op->getAttrOfType<IntegerAttr>(name).getUInt();
  }

  bool getBoolAttrValue(Operation *op, StringRef name) {
    return op->getAttrOfType<BoolAttr>(name).getValue();
  }

  StringRef getStrAttrValue(Operation *op, StringRef name) {
    return op->getAttrOfType<StringAttr>(name).getValue();
  }

  /// Set value methods.
  void setAttrValue(Operation *op, StringRef name, unsigned value) {
    op->setAttr(name, builder.getUI32IntegerAttr(value));
  }

  void setAttrValue(Operation *op, StringRef name, bool value) {
    op->setAttr(name, builder.getBoolAttr(value));
  }

  void setAttrValue(Operation *op, StringRef name, StringRef value) {
    op->setAttr(name, builder.getStringAttr(value));
  }

private:
  OpBuilder &builder;
};

//===----------------------------------------------------------------------===//
// HLSCppAnalyzer Class Declaration
//===----------------------------------------------------------------------===//

class HLSCppAnalyzer : public HLSCppVisitorBase<HLSCppAnalyzer, bool>,
                       public HLSCppToolBase {
public:
  explicit HLSCppAnalyzer(OpBuilder &builder) : HLSCppToolBase(builder) {}

  bool inPipeline;

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSCppVisitorBase::visitOp;
  bool visitOp(AffineForOp op);
  bool visitOp(AffineIfOp op);

  void analyzeBlock(Block &block);
  void analyzeFunc(FuncOp func);
  void analyzeModule(ModuleOp module);
};

//===----------------------------------------------------------------------===//
// HLSCppEstimator Class Declaration
//===----------------------------------------------------------------------===//

class HLSCppEstimator : public HLSCppVisitorBase<HLSCppEstimator, bool>,
                        public HLSCppToolBase {
public:
  explicit HLSCppEstimator(OpBuilder &builder, std::string targetSpecPath,
                           std::string opLatencyPath);

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
