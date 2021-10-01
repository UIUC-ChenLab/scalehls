//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_TRANSLATION_EMITHLSCPP_H
#define SCALEHLS_C_TRANSLATION_EMITHLSCPP_H

#include "mlir-c/IR.h"

#ifdef __cplusplus
extern "C" {
#endif

/// Emits HLS C++ code for the specified module using the provided callback and
/// user data.
MLIR_CAPI_EXPORTED MlirLogicalResult mlirEmitHlsCpp(MlirModule,
                                                    MlirStringCallback,
                                                    void *userData);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_TRANSLATION_EMITHLSCPP_H
