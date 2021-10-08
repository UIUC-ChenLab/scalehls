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

MLIR_CAPI_EXPORTED bool mlirApplyLegalizeToHlscpp(MlirOperation op,
                                                  bool topFunc) {
  if (auto func = dyn_cast<FuncOp>(unwrap(op)))
    return applyLegalizeToHLSCpp(func, topFunc);
  return false;
}

MLIR_CAPI_EXPORTED bool mlirApplyArrayPartition(MlirOperation op) {
  if (auto func = dyn_cast<FuncOp>(unwrap(op)))
    return applyArrayPartition(func);
  return false;
}
