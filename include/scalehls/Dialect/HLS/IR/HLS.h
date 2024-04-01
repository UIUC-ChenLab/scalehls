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

namespace mlir {
namespace scalehls {
namespace hls {
class StreamOp;
} // namespace hls
} // namespace scalehls
} // namespace mlir

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsTypes.h.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsAttributes.h.inc"

#include "scalehls/Dialect/HLS/IR/HLSOpsInterfaces.h.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOps.h.inc"

//===----------------------------------------------------------------------===//
// Dialect Utils
//===----------------------------------------------------------------------===//

namespace mlir {
namespace scalehls {
namespace hls {

/// Get or check the memory kind of a type.
MemoryKind getMemoryKind(MemRefType type);

bool isFullyPartitioned(MemRefType memrefType);

/// Calculate partition factors through analyzing the "memrefType" and return
/// them in "factors". Meanwhile, the overall partition number is calculated and
/// returned as well.
int64_t getPartitionFactors(MemRefType memrefType,
                            SmallVectorImpl<int64_t> *factors = nullptr);

OpOperand *getUntiledOperand(OpOperand *operand);

} // namespace hls
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLS_HLS_H
