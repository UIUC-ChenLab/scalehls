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

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

bool mlirTypeIsHLSTypeParamType(MlirType type) {
  return unwrap(type).isa<hls::TypeParamType>();
}
MlirType mlirHLSTypeParamTypeGet(MlirContext ctx) {
  return wrap(hls::TypeParamType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSValueParamType(MlirType type) {
  return unwrap(type).isa<hls::ValueParamType>();
}
MlirType mlirHLSValueParamTypeGet(MlirContext ctx) {
  return wrap(hls::ValueParamType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSPortType(MlirType type) {
  return unwrap(type).isa<hls::PortType>();
}
MlirType mlirHLSPortTypeGet(MlirContext ctx) {
  return wrap(hls::PortType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSIPIdentifierType(MlirType type) {
  return unwrap(type).isa<hls::IPIdentifierType>();
}
MlirType mlirHLSIPIdentifierTypeGet(MlirContext ctx) {
  return wrap(hls::IPIdentifierType::get(unwrap(ctx)));
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

static_assert(static_cast<int>(MlirValueParamKind::DYNAMIC) ==
                      static_cast<int>(ValueParamKind::DYNAMIC) &&
                  static_cast<int>(MlirValueParamKind::STATIC) ==
                      static_cast<int>(ValueParamKind::STATIC),
              "MlirValueParamKind (C-API) and ValueParamKind (C++) mismatch");

bool mlirAttrIsHLSValueParamKindAttr(MlirAttribute attr) {
  return unwrap(attr).isa<hls::ValueParamKindAttr>();
}
MlirAttribute mlirHLSValueParamKindAttrGet(MlirContext ctx,
                                           MlirValueParamKind kind) {
  return wrap(hls::ValueParamKindAttr::get(unwrap(ctx),
                                           static_cast<ValueParamKind>(kind)));
}
MlirValueParamKind mlirHLSValueParamKindAttrGetValue(MlirAttribute attr) {
  return static_cast<MlirValueParamKind>(
      unwrap(attr).cast<hls::ValueParamKindAttr>().getValue());
}

static_assert(static_cast<int>(MlirPortDirection::INPUT) ==
                      static_cast<int>(PortDirection::INPUT) &&
                  static_cast<int>(MlirPortDirection::OUTPUT) ==
                      static_cast<int>(PortDirection::OUTPUT),
              "MlirPortDirection (C-API) and PortDirection (C++) mismatch");

bool mlirAttrIsHLSPortDirectionAttr(MlirAttribute attr) {
  return unwrap(attr).isa<hls::PortDirectionAttr>();
}
MlirAttribute mlirHLSPortDirectionAttrGet(MlirContext ctx,
                                          MlirPortDirection direction) {
  return wrap(hls::PortDirectionAttr::get(
      unwrap(ctx), static_cast<PortDirection>(direction)));
}
MlirPortDirection mlirHLSPortDirectionAttrGetValue(MlirAttribute attr) {
  return static_cast<MlirPortDirection>(
      unwrap(attr).cast<hls::PortDirectionAttr>().getValue());
}
