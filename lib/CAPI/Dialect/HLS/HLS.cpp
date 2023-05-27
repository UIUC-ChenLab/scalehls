//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Dialect/HLS/HLS.h"
#include "mlir/CAPI/Registration.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// HLS Dialect Operations
//===----------------------------------------------------------------------===//

MLIR_DEFINE_CAPI_DIALECT_REGISTRATION(HLS, hls, hls::HLSDialect)

void mlirSemanticsInitializeBlockArguments(MlirOperation semantics) {
  auto op = dyn_cast<SemanticsOp>(unwrap(semantics));
  assert(op && "expected a semantics op");
  op.initializeBlockArguments();
}

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

bool mlirTypeIsHLSTypeType(MlirType type) {
  return unwrap(type).isa<hls::TypeType>();
}
MlirType mlirHLSTypeTypeGet(MlirContext ctx) {
  return wrap(hls::TypeType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSPortType(MlirType type) {
  return unwrap(type).isa<hls::PortType>();
}
MlirType mlirHLSPortTypeGet(MlirContext ctx) {
  return wrap(hls::PortType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSTaskImplType(MlirType type) {
  return unwrap(type).isa<hls::TaskImplType>();
}
MlirType mlirHLSTaskImplTypeGet(MlirContext ctx) {
  return wrap(hls::TaskImplType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSMemoryKindType(MlirType type) {
  return unwrap(type).isa<hls::MemoryKindType>();
}
MlirType mlirHLSMemoryKindTypeGet(MlirContext ctx) {
  return wrap(hls::MemoryKindType::get(unwrap(ctx)));
}

//===----------------------------------------------------------------------===//
// HLS Dialect Attributes
//===----------------------------------------------------------------------===//

static_assert(static_cast<int>(MlirParamKind::TILE_SIZE) ==
                      static_cast<int>(ParamKind::TILE_SIZE) &&
                  static_cast<int>(MlirParamKind::PARALLEL_SIZE) ==
                      static_cast<int>(ParamKind::PARALLEL_SIZE) &&
                  static_cast<int>(MlirParamKind::IP_TEMPLATE) ==
                      static_cast<int>(ParamKind::IP_TEMPLATE) &&
                  static_cast<int>(MlirParamKind::TASK_IMPL) ==
                      static_cast<int>(ParamKind::TASK_IMPL) &&
                  static_cast<int>(MlirParamKind::MEMORY_KIND) ==
                      static_cast<int>(ParamKind::MEMORY_KIND),
              "MlirParamKind (C-API) and ParamKind (C++) mismatch");

bool mlirAttrIsHLSParamKindAttr(MlirAttribute attr) {
  return unwrap(attr).isa<hls::ParamKindAttr>();
}
MlirAttribute mlirHLSParamKindAttrGet(MlirContext ctx, MlirParamKind kind) {
  return wrap(
      hls::ParamKindAttr::get(unwrap(ctx), static_cast<ParamKind>(kind)));
}
MlirParamKind mlirHLSParamKindAttrGetValue(MlirAttribute attr) {
  return static_cast<MlirParamKind>(
      unwrap(attr).cast<hls::ParamKindAttr>().getValue());
}

static_assert(static_cast<int>(MlirPortKind::INPUT) ==
                      static_cast<int>(PortKind::INPUT) &&
                  static_cast<int>(MlirPortKind::OUTPUT) ==
                      static_cast<int>(PortKind::OUTPUT),
              "MlirPortKind (C-API) and PortKind (C++) mismatch");

bool mlirAttrIsHLSPortKindAttr(MlirAttribute attr) {
  return unwrap(attr).isa<hls::PortKindAttr>();
}
MlirAttribute mlirHLSPortKindAttrGet(MlirContext ctx, MlirPortKind kind) {
  return wrap(hls::PortKindAttr::get(unwrap(ctx), static_cast<PortKind>(kind)));
}
MlirPortKind mlirHLSPortKindAttrGetValue(MlirAttribute attr) {
  return static_cast<MlirPortKind>(
      unwrap(attr).cast<hls::PortKindAttr>().getValue());
}
