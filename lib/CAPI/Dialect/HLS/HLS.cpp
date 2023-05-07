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

MLIR_DEFINE_CAPI_DIALECT_REGISTRATION(HLS, hls, hls::HLSDialect)

bool mlirTypeIsHLSTypeParamType(MlirType type) {
  return unwrap(type).isa<hls::TypeParamType>();
}
MlirType mlirHLSTypeParamTypeGet(MlirContext ctx) {
  return wrap(hls::TypeParamType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSValueParamType(MlirType type) {
  return unwrap(type).isa<hls::TypeParamType>();
}
MlirType mlirHLSValueParamTypeGet(MlirContext ctx) {
  return wrap(hls::TypeParamType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSPortType(MlirType type) {
  return unwrap(type).isa<hls::TypeParamType>();
}
MlirType mlirHLSPortTypeGet(MlirContext ctx) {
  return wrap(hls::TypeParamType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSIPIdentifierType(MlirType type) {
  return unwrap(type).isa<hls::TypeParamType>();
}
MlirType mlirHLSIPIdentifierTypeGet(MlirContext ctx) {
  return wrap(hls::TypeParamType::get(unwrap(ctx)));
}

bool mlirTypeIsHLSMemoryKindType(MlirType type) {
  return unwrap(type).isa<hls::TypeParamType>();
}
MlirType mlirHLSMemoryKindTypeGet(MlirContext ctx) {
  return wrap(hls::TypeParamType::get(unwrap(ctx)));
}
