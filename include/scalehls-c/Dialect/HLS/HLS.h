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

MLIR_DECLARE_CAPI_DIALECT_REGISTRATION(HLS, hls);

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

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_DIALECT_HLS_HLS_H
