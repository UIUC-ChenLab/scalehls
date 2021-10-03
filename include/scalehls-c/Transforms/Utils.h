//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_TRANSFORMS_UTILS_H
#define SCALEHLS_C_TRANSFORMS_UTILS_H

#include "mlir-c/IR.h"

#ifdef __cplusplus
extern "C" {
#endif

MLIR_CAPI_EXPORTED bool mlirApplyArrayPartition(MlirOperation op);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_TRANSFORMS_UTILS_H
