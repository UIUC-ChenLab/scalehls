//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_CAPI_TRANSFORMS_UTILS_H
#define SCALEHLS_CAPI_TRANSFORMS_UTILS_H

#include "mlir/CAPI/Wrap.h"
#include "mlir/IR/BuiltinOps.h"
#include "scalehls-c/Transforms/Utils.h"

DEFINE_C_API_METHODS(MlirFunc, mlir::FuncOp)

#endif // SCALEHLS_CAPI_TRANSFORMS_UTILS_H
