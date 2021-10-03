//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Transforms/Utils.h"

#include "mlir/CAPI/IR.h"
#include "mlir/CAPI/Support.h"
#include "mlir/CAPI/Utils.h"
#include "mlir/IR/BuiltinOps.h"
#include "scalehls/CAPI/Transforms/Utils.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

//===----------------------------------------------------------------------===//
// Utils
//===----------------------------------------------------------------------===//

MLIR_CAPI_EXPORTED bool MlirApplyArrayPartition(MlirFunc func) {
  return applyArrayPartition(unwrap(func));
}

//===----------------------------------------------------------------------===//
// Function API.
//===----------------------------------------------------------------------===//

MlirContext mlirFuncGetContext(MlirFunc func) {
  return wrap(unwrap(func).getContext());
}

MlirRegion mlirFuncGetBody(MlirFunc func) {
  return wrap(&unwrap(func).getBody());
}

MlirOperation mlirFuncGetOperation(MlirFunc func) {
  return wrap(unwrap(func).getOperation());
}

MlirFunc mlirFuncFromOperation(MlirOperation op) {
  return wrap(dyn_cast<FuncOp>(unwrap(op)));
}
