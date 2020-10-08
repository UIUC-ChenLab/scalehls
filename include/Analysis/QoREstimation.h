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

  StringRef getPartitionType(ArrayOp *op, unsigned dim) {
    return op->partition_type()[dim].cast<StringAttr>().getValue();
  }

  unsigned getPartitionFactor(ArrayOp *op, unsigned dim) {
    return op->partition_factor()[dim].cast<IntegerAttr>().getUInt();
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

  /// Get expression methods.
  AffineExpr getSymbolExpr(unsigned value) {
    return getAffineSymbolExpr(value, builder.getContext());
  }

  AffineExpr getDimExpr(unsigned value) {
    return getAffineDimExpr(value, builder.getContext());
  }

  AffineExpr getConstExpr(unsigned value) {
    return getAffineConstantExpr(value, builder.getContext());
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

// For storing the scheduled time stamp of operations.
using OpScheduleMap = llvm::SmallDenseMap<Operation *, unsigned, 16>;

// For storing each memory access operations indexed by its targed memory
// value symbol.
using MemAccess = SmallVector<Operation *, 4>;
using MemAccessDict = llvm::SmallDenseMap<Value, MemAccess, 16>;

// For storing memory access and schedule information of pipelined region.
struct PipelineInfo {
  PipelineInfo(unsigned baseII) : II(baseII) {}

  unsigned II;
  OpScheduleMap opScheduleMap;
  MemAccessDict memLoadDict;
  MemAccessDict memStoreDict;
};

// For storing loop induction information.
struct InductionInfo {
  InductionInfo(unsigned lowerBound, unsigned upperBound, unsigned step)
      : lowerBound(lowerBound), upperBound(upperBound), step(step) {}

  unsigned lowerBound;
  unsigned upperBound;
  unsigned step;
};
using InductionInfoList = SmallVector<InductionInfo, 8>;

// This records the number of accesses for each partition.
using AccessNum = SmallVector<unsigned, 16>;
// This records the AccessNum of each dimension of an array.
using AccessNumList = SmallVector<AccessNum, 8>;

class HLSCppEstimator : public HLSCppVisitorBase<HLSCppEstimator, bool>,
                        public HLSCppToolBase {
public:
  explicit HLSCppEstimator(OpBuilder &builder, std::string targetSpecPath,
                           std::string opLatencyPath);

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSCppVisitorBase::visitOp;
  bool visitOp(AffineForOp op);
  bool visitOp(AffineIfOp op);

  void setBlockSchedule(Block &block, unsigned opSchedule,
                        OpScheduleMap &opScheduleMap);
  unsigned getBlockSchedule(Block &block, bool innerFlatten,
                            OpScheduleMap &opScheduleMap);

  void getPipelineInfo(Block &block, PipelineInfo &info);

  template <typename OpType> void getAccessNum(OpType op, ArrayOp arrayOp);

  void estimateOperation(Operation *op);
  void estimateFunc(FuncOp func);
  void estimateBlock(Block &block);
  void estimateModule(ModuleOp module);
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
