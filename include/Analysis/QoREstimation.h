//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_QORESTIMATION_H
#define SCALEHLS_ANALYSIS_QORESTIMATION_H

#include "Dialect/HLSCpp/Visitor.h"
#include "INIReader.h"
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
// HLSCppEstimator Class Declaration
//===----------------------------------------------------------------------===//

// For storing all memory access operations (including AffineLoadOp and
// AffineStoreOp) indexed by the array instantce (ArrayOp).
using LoadStore = SmallVector<Operation *, 16>;
using LoadStoreDict = llvm::SmallDenseMap<Operation *, LoadStore, 8>;

// Indicate the unoccupied memory ports number.
struct PortInfo {
  PortInfo(unsigned rdPort = 0, unsigned wrPort = 0, unsigned rdwrPort = 0)
      : rdPort(rdPort), wrPort(wrPort), rdwrPort(rdwrPort) {}

  unsigned rdPort;
  unsigned wrPort;
  unsigned rdwrPort;
};

// For storing ports number information of each memory instance.
using MemPort = SmallVector<PortInfo, 16>;
using MemPortDict = llvm::SmallDenseMap<Operation *, MemPort, 8>;

// For storing MemPort indexed by the pipeline stage.
using MemPortDicts = SmallVector<MemPortDict, 16>;

class HLSCppEstimator : public HLSCppVisitorBase<HLSCppEstimator, bool>,
                        public HLSCppToolBase {
public:
  explicit HLSCppEstimator(OpBuilder &builder, std::string targetSpecPath);

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSCppVisitorBase::visitOp;
  bool visitOp(AffineForOp op);

  void getBlockMemInfo(Block &block, LoadStoreDict &info);

  unsigned getLoadStoreSchedule(Operation *op, unsigned begin,
                                MemPortDicts &dicts);
  unsigned getBlockSchedule(Block &block);

  unsigned getResMinII(AffineForOp forOp, LoadStoreDict dict);
  unsigned getDepMinII(AffineForOp forOp, LoadStoreDict dict);

  void estimateFunc(FuncOp func);
  void estimateBlock(Block &block);
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_QORESTIMATION_H
