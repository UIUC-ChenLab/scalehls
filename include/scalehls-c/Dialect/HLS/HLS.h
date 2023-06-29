//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_DIALECT_HLS_HLS_H
#define SCALEHLS_C_DIALECT_HLS_HLS_H

#include "mlir-c/RegisterEverything.h"
#include <vector>

#ifdef __cplusplus
extern "C" {
#endif

//===----------------------------------------------------------------------===//
// HLS Dialect Operations
//===----------------------------------------------------------------------===//

MLIR_DECLARE_CAPI_DIALECT_REGISTRATION(HLS, hls);

MLIR_CAPI_EXPORTED void
mlirSemanticsInitializeBlockArguments(MlirOperation semantics,
                                      const std::vector<MlirValue> &ports);

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSStructType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSStructTypeGet(MlirStringRef name,
                                                 MlirContext ctx);

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSTypeType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSTypeTypeGet(MlirContext ctx);

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSPortType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSPortTypeGet(MlirContext ctx);

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSTaskImplType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSTaskImplTypeGet(MlirContext ctx);

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSMemoryKindType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSMemoryKindTypeGet(MlirContext ctx);

//===----------------------------------------------------------------------===//
// HLS Dialect Attributes
//===----------------------------------------------------------------------===//

enum class MlirParamKind : uint32_t {
  TILE_SIZE = 0,
  PARALLEL_SIZE = 1,
  IP_TEMPLATE = 2,
  TASK_IMPL = 3,
  MEMORY_KIND = 4
};

MLIR_CAPI_EXPORTED bool mlirAttrIsHLSParamKindAttr(MlirAttribute attr);
MLIR_CAPI_EXPORTED MlirAttribute mlirHLSParamKindAttrGet(MlirContext ctx,
                                                         MlirParamKind kind);
MLIR_CAPI_EXPORTED MlirParamKind
mlirHLSParamKindAttrGetValue(MlirAttribute attr);

enum class MlirPortKind : uint32_t { INPUT = 0, OUTPUT = 1, PARAM = 2 };

MLIR_CAPI_EXPORTED bool mlirAttrIsHLSPortKindAttr(MlirAttribute attr);
MLIR_CAPI_EXPORTED MlirAttribute mlirHLSPortKindAttrGet(MlirContext ctx,
                                                        MlirPortKind kind);
MLIR_CAPI_EXPORTED MlirPortKind mlirHLSPortKindAttrGetValue(MlirAttribute attr);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_DIALECT_HLS_HLS_H
