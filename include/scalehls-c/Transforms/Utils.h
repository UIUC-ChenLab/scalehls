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

//===----------------------------------------------------------------------===//
// CAPI data structures
//===----------------------------------------------------------------------===//

#define DEFINE_C_API_STRUCT(name, storage)                                     \
  struct name {                                                                \
    storage *ptr;                                                              \
  };                                                                           \
  typedef struct name name

DEFINE_C_API_STRUCT(MlirFunc, const void);

#undef DEFINE_C_API_STRUCT

//===----------------------------------------------------------------------===//
// Utils
//===----------------------------------------------------------------------===//

MLIR_CAPI_EXPORTED bool MlirApplyArrayPartition(MlirFunc func);

//===----------------------------------------------------------------------===//
// MlirFunc APIs
//===----------------------------------------------------------------------===//

/// Gets the context that a module was created with.
MLIR_CAPI_EXPORTED MlirContext mlirFuncGetContext(MlirFunc module);

/// Gets the body of the module, i.e. the only block it contains.
MLIR_CAPI_EXPORTED MlirRegion mlirFuncGetBody(MlirFunc module);

/// Views the module as a generic operation.
MLIR_CAPI_EXPORTED MlirOperation mlirFuncGetOperation(MlirFunc module);

/// Views the generic operation as a module.
/// The returned module is null when the input operation was not a ModuleOp.
MLIR_CAPI_EXPORTED MlirFunc mlirFuncFromOperation(MlirOperation op);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_TRANSFORMS_UTILS_H
