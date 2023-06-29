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

namespace mlir {
namespace scalehls {
namespace hls {

#include "scalehls/Dialect/HLS/IR/HLSOpsInterfaces.h.inc"

/// Memory effects for dataflow.stream operations.
namespace StreamEffects {
struct Instantiate : public MemoryEffects::Effect::Base<Instantiate> {};
struct Push : public MemoryEffects::Effect::Base<Push> {};
struct Pop : public MemoryEffects::Effect::Base<Pop> {};
} // namespace StreamEffects

/// Printer hook for custom directive in assemblyFormat.
///
///   custom<DynamicTemplateList>($templates, $staticTemplates)
///
/// where `template` is of ODS type `Variadic<AnyType>` and `staticTemplates`
/// is of ODS type `ArrayAttr`. Prints a list with either (1) the static
/// attribute value in `staticTemplates` is `dynVal` or (2) the next value
/// otherwise. This allows idiomatic printing of mixed value and attributes in a
/// list. E.g. `<%arg0, 7, f32, %arg42>`.
void printDynamicTemplateList(OpAsmPrinter &printer, Operation *op,
                              OperandRange templates,
                              ArrayAttr staticTemplates);

/// Pasrer hook for custom directive in assemblyFormat.
///
///   custom<DynamicTemplateList>($templates, $staticTemplates)
///
/// where `templates` is of ODS type `Variadic<AnyType>` and `staticTemplates`
/// is of ODS type `ArrayAttr`. Parse a mixed list with either (1) static
/// templates or (2) SSA templates. Fill `staticTemplates` with the ArrayAttr,
/// where `dynVal` encodes the position of SSA templates. Add the parsed SSA
/// templates to `templates` in-order.
//
/// E.g. after parsing "<%arg0, 7, f32, %arg42>":
///   1. `result` is filled with the ArrayAttr "[`dynVal`, 7, f32, `dynVal`]"
///   2. `ssa` is filled with "[%arg0, %arg42]".
ParseResult parseDynamicTemplateList(
    OpAsmParser &parser,
    SmallVectorImpl<OpAsmParser::UnresolvedOperand> &templates,
    ArrayAttr &staticTemplates);

} // namespace hls
} // namespace scalehls
} // namespace mlir

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOps.h.inc"

#endif // SCALEHLS_DIALECT_HLS_HLS_H
