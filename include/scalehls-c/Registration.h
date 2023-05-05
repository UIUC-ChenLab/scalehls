//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_REGISTRATION_H
#define SCALEHLS_C_REGISTRATION_H

#include "mlir-c/IR.h"

#ifdef __cplusplus
extern "C" {
#endif

MLIR_CAPI_EXPORTED void
mlirScaleHLSRegisterAllDialects(MlirDialectRegistry registry);

MLIR_CAPI_EXPORTED void
mlirScaleHLSRegisterAllInterfaceExternalModels(MlirDialectRegistry registry);

MLIR_CAPI_EXPORTED void mlirScaleHLSRegisterAllPasses(void);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_REGISTRATION_H
