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
MlirAttribute mlirHLSPortKindAttrGet(MlirContext ctx, MlirPortKind kind) {
  return wrap(hls::PortKindAttr::get(unwrap(ctx), static_cast<PortKind>(kind)));
}
MlirPortKind mlirHLSPortKindAttrGetValue(MlirAttribute attr) {
  return static_cast<MlirPortKind>(
      unwrap(attr).cast<hls::PortKindAttr>().getValue());
}
