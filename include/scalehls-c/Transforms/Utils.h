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

struct MlirAffineLoopBand {
  const MlirOperation *loopBegin;
  const MlirOperation *loopEnd;
};
typedef struct MlirAffineLoopBand MlirAffineLoopBand;

MLIR_CAPI_EXPORTED bool mlirApplyAffineLoopPerfection(MlirAffineLoopBand band);
MLIR_CAPI_EXPORTED bool mlirApplyAffineLoopOrderOpt(MlirAffineLoopBand band);
MLIR_CAPI_EXPORTED bool mlirApplyRemoveVariableBound(MlirAffineLoopBand band);

MLIR_CAPI_EXPORTED bool mlirApplyLegalizeToHlscpp(MlirOperation op,
                                                  bool topFunc);

MLIR_CAPI_EXPORTED bool mlirApplyMemoryAccessOpt(MlirOperation op);
MLIR_CAPI_EXPORTED bool mlirApplyArrayPartition(MlirOperation op);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_TRANSFORMS_UTILS_H
