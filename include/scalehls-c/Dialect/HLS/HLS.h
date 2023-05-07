//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_DIALECT_HLS_HLS_H
#define SCALEHLS_C_DIALECT_HLS_HLS_H

#include "mlir-c/RegisterEverything.h"

#ifdef __cplusplus
extern "C" {
#endif

//===----------------------------------------------------------------------===//
// HLS Dialect Operations
//===----------------------------------------------------------------------===//

MLIR_DECLARE_CAPI_DIALECT_REGISTRATION(HLS, hls);

MLIR_CAPI_EXPORTED void
mlirSemanticsInitializeBlockArguments(MlirOperation semantics);

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSTypeParamType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSTypeParamTypeGet(MlirContext ctx);

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSValueParamType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSValueParamTypeGet(MlirContext ctx);

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSPortType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSPortTypeGet(MlirContext ctx);

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSIPIdentifierType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSIPIdentifierTypeGet(MlirContext ctx);

MLIR_CAPI_EXPORTED bool mlirTypeIsHLSMemoryKindType(MlirType type);
MLIR_CAPI_EXPORTED MlirType mlirHLSMemoryKindTypeGet(MlirContext ctx);

//===----------------------------------------------------------------------===//
// HLS Dialect Attributes
//===----------------------------------------------------------------------===//

enum class MlirValueParamKind : uint32_t { STATIC = 0, DYNAMIC = 1 };

MLIR_CAPI_EXPORTED bool mlirAttrIsHLSValueParamKindAttr(MlirAttribute attr);
MLIR_CAPI_EXPORTED MlirAttribute
mlirHLSValueParamKindAttrGet(MlirContext ctx, MlirValueParamKind kind);
MLIR_CAPI_EXPORTED MlirValueParamKind
mlirHLSValueParamKindAttrGetValue(MlirAttribute attr);

enum class MlirPortDirection : uint32_t { INPUT = 0, OUTPUT = 1 };

MLIR_CAPI_EXPORTED bool mlirAttrIsHLSPortDirectionAttr(MlirAttribute attr);
MLIR_CAPI_EXPORTED MlirAttribute
mlirHLSPortDirectionAttrGet(MlirContext ctx, MlirPortDirection direction);
MLIR_CAPI_EXPORTED MlirPortDirection
mlirHLSPortDirectionAttrGetValue(MlirAttribute attr);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_DIALECT_HLS_HLS_H
