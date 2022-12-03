//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_DIALECT_HLS_H
#define SCALEHLS_C_DIALECT_HLS_H

#include "mlir-c/RegisterEverything.h"

#ifdef __cplusplus
extern "C" {
#endif

MLIR_DECLARE_CAPI_DIALECT_REGISTRATION(HLS, hls);

MLIR_CAPI_EXPORTED void
scalehlsRegisterAllDialects(MlirDialectRegistry registry);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_DIALECT_HLS_H
