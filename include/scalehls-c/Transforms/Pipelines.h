//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_TRANSFORMS_PIPELINES_H
#define SCALEHLS_C_TRANSFORMS_PIPELINES_H

#include "mlir-c/Support.h"

#ifdef __cplusplus
extern "C" {
#endif

MLIR_CAPI_EXPORTED void mlirRegisterScaleHLSPipelines(void);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_TRANSFORMS_PIPELINES_H
