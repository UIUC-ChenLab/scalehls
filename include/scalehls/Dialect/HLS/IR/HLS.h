//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLS_H
#define SCALEHLS_DIALECT_HLS_HLS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
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

namespace mlir {
namespace scalehls {
namespace hls {

#include "scalehls/Dialect/HLS/IR/HLSOpsInterfaces.h.inc"

/// Kind of dataflow.node operands.
enum class OperandKind { INPUT, OUTPUT, PARAM };

/// Memory effects for dataflow.stream operations.
namespace StreamEffects {
struct Instantiate : public MemoryEffects::Effect::Base<Instantiate> {};
struct Push : public MemoryEffects::Effect::Base<Push> {};
struct Pop : public MemoryEffects::Effect::Base<Pop> {};
} // namespace StreamEffects

//===----------------------------------------------------------------------===//
// Tile layout attribute utils.
//===----------------------------------------------------------------------===//

TileLayoutAttr getTileLayout(Operation *op);
void setTileLayout(Operation *op, TileLayoutAttr tileLayout);
void setTileLayout(Operation *op, ArrayRef<int64_t> tileShape,
                   ArrayRef<int64_t> vectorShape);
void setTileLayout(Operation *op, ArrayRef<int64_t> tileShape);

TileLayoutAttr getTileLayout(Value memref);
void setTileLayout(Value memref, TileLayoutAttr tileLayout);
void setTileLayout(Value memref, ArrayRef<int64_t> tileShape,
                   ArrayRef<int64_t> vectorShape);
void setTileLayout(Value memref, ArrayRef<int64_t> tileShape);

//===----------------------------------------------------------------------===//
// HLS directive attributes
//===----------------------------------------------------------------------===//

/// Loop directives attribute utils.
LoopDirectiveAttr getLoopDirective(Operation *op);
void setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective);
void setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                      bool dataflow, bool flatten);

/// Parrallel and point loop attribute utils.
bool hasParallelAttr(Operation *op);
void setParallelAttr(Operation *op);
bool hasPointAttr(Operation *op);
void setPointAttr(Operation *op);

/// Function directives attribute utils.
FuncDirectiveAttr getFuncDirective(Operation *op);
void setFuncDirective(Operation *op, FuncDirectiveAttr FuncDirective);
void setFuncDirective(Operation *op, bool pipeline, int64_t targetInterval,
                      bool dataflow);

/// Top and runtime function attribute utils.
bool hasTopFuncAttr(Operation *op);
void setTopFuncAttr(Operation *op);
bool hasRuntimeAttr(Operation *op);
void setRuntimeAttr(Operation *op);

class NodeOp;

} // namespace hls
} // namespace scalehls
} // namespace mlir

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOps.h.inc"

#endif // SCALEHLS_DIALECT_HLS_HLS_H
