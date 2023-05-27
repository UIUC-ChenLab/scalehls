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

static_assert(static_cast<int>(MlirPortKind::INPUT) ==
                      static_cast<int>(PortKind::INPUT) &&
                  static_cast<int>(MlirPortKind::OUTPUT) ==
                      static_cast<int>(PortKind::OUTPUT),
              "MlirPortKind (C-API) and PortKind (C++) mismatch");

bool mlirAttrIsHLSPortKindAttr(MlirAttribute attr) {
  return unwrap(attr).isa<hls::PortKindAttr>();
}
MlirAttribute mlirHLSPortKindAttrGet(MlirContext ctx, MlirPortKind direction) {
  return wrap(
      hls::PortKindAttr::get(unwrap(ctx), static_cast<PortKind>(direction)));
}
MlirPortKind mlirHLSPortKindAttrGetValue(MlirAttribute attr) {
  return static_cast<MlirPortKind>(
      unwrap(attr).cast<hls::PortKindAttr>().getValue());
}
