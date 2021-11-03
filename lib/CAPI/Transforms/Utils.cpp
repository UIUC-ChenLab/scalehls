//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Transforms/Utils.h"

#include "mlir/CAPI/IR.h"
#include "mlir/CAPI/Support.h"
#include "mlir/IR/BuiltinOps.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

static void unwrapBand(MlirAffineLoopBand band, AffineLoopBand &unwrappedBand) {
  for (auto op = band.loopBegin; op != band.loopEnd; ++op) {
    auto loop = dyn_cast<AffineForOp>(unwrap(*op));
    assert(loop && "operation in loop band must be AffineForOp");
    unwrappedBand.push_back(loop);
  }
}

MLIR_CAPI_EXPORTED bool mlirApplyAffineLoopPerfection(MlirAffineLoopBand band) {
  AffineLoopBand unwrappedBand;
  unwrapBand(band, unwrappedBand);
  return applyAffineLoopPerfection(unwrappedBand);
}

MLIR_CAPI_EXPORTED bool mlirApplyAffineLoopOrderOpt(MlirAffineLoopBand band) {
  AffineLoopBand unwrappedBand;
  unwrapBand(band, unwrappedBand);
  return applyAffineLoopOrderOpt(unwrappedBand);
}

MLIR_CAPI_EXPORTED bool mlirApplyRemoveVariableBound(MlirAffineLoopBand band) {
  AffineLoopBand unwrappedBand;
  unwrapBand(band, unwrappedBand);
  return applyRemoveVariableBound(unwrappedBand);
}

MLIR_CAPI_EXPORTED bool mlirApplyLegalizeToHlscpp(MlirOperation op,
                                                  bool topFunc) {
  if (auto func = dyn_cast<FuncOp>(unwrap(op)))
    return applyLegalizeToHLSCpp(func, topFunc);
  return false;
}

MLIR_CAPI_EXPORTED bool mlirApplyMemoryAccessOpt(MlirOperation op) {
  if (auto func = dyn_cast<FuncOp>(unwrap(op)))
    return applyMemoryAccessOpt(func);
  return false;
}

MLIR_CAPI_EXPORTED bool mlirApplyArrayPartition(MlirOperation op) {
  if (auto func = dyn_cast<FuncOp>(unwrap(op)))
    return applyArrayPartition(func);
  return false;
}
