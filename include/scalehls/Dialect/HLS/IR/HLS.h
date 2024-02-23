//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLS_H
#define SCALEHLS_DIALECT_HLS_HLS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Utils/StaticValueUtils.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Interfaces/ControlFlowInterfaces.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Interfaces/ViewLikeInterface.h"
#include "scalehls/Dialect/HLS/IR/HLSOpsDialect.h.inc"
#include "scalehls/Dialect/HLS/IR/HLSOpsEnums.h.inc"

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsTypes.h.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsAttributes.h.inc"

#include "scalehls/Dialect/HLS/IR/HLSOpsInterfaces.h.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOps.h.inc"

namespace mlir {
namespace scalehls {
namespace hls {

//===----------------------------------------------------------------------===//
// Attribute Accessors
//===----------------------------------------------------------------------===//

/// Loop directive attribute accessors.
LoopDirectiveAttr getLoopDirective(Operation *op);
void setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective);
void setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                      bool dataflow, bool flatten);

/// Function directive attribute accessors.
FuncDirectiveAttr getFuncDirective(Operation *op);
void setFuncDirective(Operation *op, FuncDirectiveAttr FuncDirective);
void setFuncDirective(Operation *op, bool pipeline, int64_t targetInterval,
                      bool dataflow);

/// Top and runtime function attribute utils.
bool hasTopFuncAttr(Operation *op);
void setTopFuncAttr(Operation *op);
bool hasRuntimeAttr(Operation *op);
void setRuntimeAttr(Operation *op);

//===----------------------------------------------------------------------===//
// Transform Utils
//===----------------------------------------------------------------------===//

/// Wrap the operations in the block with dispatch op. Return a nullptr if
/// failed.
ScheduleOp scheduleBlock(StringRef name, Block *block,
                         PatternRewriter &rewriter);

/// Fuse the given operations into a new task. The new task will be created
/// before "insertToOp" and each operation will be in the original order. This
/// method always succeeds even if the resulting IR is invalid.
TaskOp fuseOpsIntoTask(ArrayRef<Operation *> ops, PatternRewriter &rewriter,
                       Operation *insertToOp = nullptr);

//===----------------------------------------------------------------------===//
// Analysis Utils
//===----------------------------------------------------------------------===//

/// Get or check the memory kind of a type.
MemoryKind getMemoryKind(MemRefType type);
bool isRam1P(MemRefType type);
bool isRam2P(MemRefType type);
bool isRamS2P(MemRefType type);
bool isRamT2P(MemRefType type);
bool isDram(MemRefType type);
bool isUnknown(MemRefType type);

/// Check whether the given use has read/write semantics.
bool isRead(OpOperand &use);
bool isWritten(OpOperand &use);

func::FuncOp getTopFunc(ModuleOp module, std::string topFuncName = "");

func::FuncOp getRuntimeFunc(ModuleOp module, std::string runtimeFuncName = "");

bool isFullyPartitioned(MemRefType memrefType);

/// Calculate partition factors through analyzing the "memrefType" and return
/// them in "factors". Meanwhile, the overall partition number is calculated and
/// returned as well.
int64_t getPartitionFactors(MemRefType memrefType,
                            SmallVectorImpl<int64_t> *factors = nullptr);

} // namespace hls
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLS_HLS_H
