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

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

bool mlirTypeIsHLSITensorType(MlirType type) {
  return unwrap(type).isa<hls::ITensorType>();
}

MLIR_CAPI_EXPORTED int64_t mlirHLSITensorTypeGetDepth(MlirType type) {
  return cast<ITensorType>(unwrap(type)).getDepth();
}

MLIR_CAPI_EXPORTED MlirType mlirHLSITensorTypeSetDepth(MlirType type,
                                                       int64_t depth) {
  auto oldType = cast<ITensorType>(unwrap(type));
  return wrap(
      ITensorType::get(oldType.getElementType(), oldType.getIterTripCounts(),
                       oldType.getIterSteps(), oldType.getIterMap(), depth));
}