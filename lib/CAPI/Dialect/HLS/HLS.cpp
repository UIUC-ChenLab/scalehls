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

bool mlirAttrIsHLSMemoryKindAttr(MlirAttribute attr) {
  return unwrap(attr).isa<hls::MemoryKindAttr>();
}
MlirAttribute mlirHLSMemoryKindAttrGet(MlirContext ctx, MlirMemoryKind kind) {
  return wrap(
      hls::MemoryKindAttr::get(unwrap(ctx), static_cast<MemoryKind>(kind)));
}
MlirMemoryKind mlirHLSMemoryKindAttrGetValue(MlirAttribute attr) {
  return static_cast<MlirMemoryKind>(
      unwrap(attr).cast<hls::MemoryKindAttr>().getValue());
}
