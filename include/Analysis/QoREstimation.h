//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "INIReader.h"
#include "Visitor.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/LoopUtils.h"
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
  int64_t getIntAttrValue(Operation *op, StringRef name) {
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

  /// Set value methods.
  void setAttrValue(Operation *op, StringRef name, unsigned value) {
    op->setAttr(name, builder.getUI32IntegerAttr(value));
  }

  void setAttrValue(Operation *op, StringRef name, int32_t value) {
    op->setAttr(name, builder.getI32IntegerAttr(value));
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

  AffineExpr getConstExpr(int64_t value) {
    return getAffineConstantExpr(value, builder.getContext());
  }

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

// Indicate the unoccupied memory ports number.
struct PortNum {
  PortNum(unsigned rdPort = 0, unsigned wrPort = 0, unsigned rdwrPort = 0)
      : rdPort(rdPort), wrPort(wrPort), rdwrPort(rdwrPort) {}

  unsigned rdPort;
  unsigned wrPort;
  unsigned rdwrPort;
};

// For storing ports number information of each memory instance.
using MemPort = llvm::SmallDenseMap<Operation *, SmallVector<PortNum, 16>, 8>;

// For storing MemPort indexed by the pipeline stage (a basic block).
using MemPortList = SmallVector<MemPort, 16>;

// For storing each memory access operations (including AffineLoadOp and
// AffineStoreOp) indexed by the array instantce (ArrayOp).
using MemAccess = SmallVector<Operation *, 16>;
using MemAccessDict = llvm::SmallDenseMap<Operation *, MemAccess, 8>;

// An aggregate information structure for storing memory load and store
// MemAccessDict in the scope of loop/function/other region.
struct MemInfo {
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

class HLSCppEstimator : public HLSCppVisitorBase<HLSCppEstimator, bool>,
                        public HLSCppToolBase {
public:
  explicit HLSCppEstimator(OpBuilder &builder, std::string targetSpecPath,
                           std::string opLatencyPath);

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSCppVisitorBase::visitOp;
  bool visitOp(AffineForOp op);
  bool visitOp(AffineIfOp op);

  int32_t getPartitionIdx(AffineMap map, ArrayOp op);
  void getMemInfo(Block &block, MemInfo &info);

  unsigned getLoadStoreSchedule(Operation *op, ArrayOp arrayOp,
                                MemPortList &memPortList, unsigned begin);
  unsigned getBlockSchedule(Block &block, MemInfo memInfo);

  void estimateOperation(Operation *op);
  void estimateFunc(FuncOp func);
  void estimateBlock(Block &block);
  void estimateModule(ModuleOp module);
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
