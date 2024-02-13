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

/// Tilelayout attribute accessors on operation.
TileLayoutAttr getTileLayout(Operation *op);
void setTileLayout(Operation *op, TileLayoutAttr tileLayout);
void setTileLayout(Operation *op, ArrayRef<int64_t> tileShape,
                   ArrayRef<int64_t> vectorShape);
void setTileLayout(Operation *op, ArrayRef<int64_t> tileShape);

/// Tilelayout attribute accessors on value.
TileLayoutAttr getTileLayout(Value memref);
void setTileLayout(Value memref, TileLayoutAttr tileLayout);
void setTileLayout(Value memref, ArrayRef<int64_t> tileShape,
                   ArrayRef<int64_t> vectorShape);
void setTileLayout(Value memref, ArrayRef<int64_t> tileShape);

/// Loop directive attribute accessors.
LoopDirectiveAttr getLoopDirective(Operation *op);
void setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective);
void setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                      bool dataflow, bool flatten);

/// Parrallel and point loop attribute accessors.
bool hasParallelAttr(Operation *op);
void setParallelAttr(Operation *op);
bool hasPointAttr(Operation *op);
void setPointAttr(Operation *op);

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
DispatchOp dispatchBlock(Block *block, PatternRewriter &rewriter);

/// Fuse the given operations into a new task. The new task will be created
/// before "insertToOp" and each operation will be in the original order. This
/// method always succeeds even if the resulting IR is invalid.
TaskOp fuseOpsIntoTask(ArrayRef<Operation *> ops, PatternRewriter &rewriter,
                       Operation *insertToOp = nullptr);

/// Fuse multiple nodes into a new node.
NodeOp fuseNodeOps(ArrayRef<NodeOp> nodes, PatternRewriter &rewriter);

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

/// Get the consumer/producer nodes of the given buffer expect the given op.
SmallVector<NodeOp> getConsumersExcept(Value buffer, NodeOp except);
SmallVector<NodeOp> getProducersExcept(Value buffer, NodeOp except);
SmallVector<NodeOp> getConsumers(Value buffer);
SmallVector<NodeOp> getProducers(Value buffer);
SmallVector<NodeOp> getDependentConsumers(Value buffer, NodeOp node);

/// Get the nested consumer/producer nodes of the given buffer expect the given
/// node. The corresponding buffer values are also returned.
SmallVector<std::pair<NodeOp, Value>> getNestedConsumersExcept(Value buffer,
                                                               NodeOp except);
SmallVector<std::pair<NodeOp, Value>> getNestedProducersExcept(Value buffer,
                                                               NodeOp except);
SmallVector<std::pair<NodeOp, Value>> getNestedConsumers(Value buffer);
SmallVector<std::pair<NodeOp, Value>> getNestedProducers(Value buffer);

/// Get the depth of a buffer or stream channel. Note that only if the defining
/// operation of the buffer is not a BufferOp or stream types, the returned
/// result will be 1.
unsigned getBufferDepth(Value memref);

/// Find buffer value or buffer op across the dataflow hierarchy.
Value findBuffer(Value memref);
hls::BufferLikeInterface findBufferOp(Value memref);

/// Check whether the given buffer is external.
bool isExtBuffer(Value memref);

/// Check whether the given use has read/write semantics.
bool isRead(OpOperand &use);
bool isWritten(OpOperand &use);

} // namespace hls
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLS_HLS_H
