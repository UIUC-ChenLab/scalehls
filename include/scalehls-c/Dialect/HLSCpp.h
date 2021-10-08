//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_DIALECT_HLSCPP_H
#define SCALEHLS_C_DIALECT_HLSCPP_H

#include "mlir-c/Registration.h"

#ifdef __cplusplus
extern "C" {
#endif

MLIR_DECLARE_CAPI_DIALECT_REGISTRATION(HLSCpp, hlscpp);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_DIALECT_HLSCPP_H
