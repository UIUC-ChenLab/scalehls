//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/EmitHLSCpp.h"
#include "mlir/CAPI/IR.h"
#include "mlir/CAPI/Support.h"
#include "mlir/CAPI/Utils.h"
#include "scalehls/Translation/EmitHLSCpp.h"

using namespace mlir;
using namespace scalehls;

MlirLogicalResult scalehlsEmitHlsCpp(MlirModule module,
                                     MlirStringCallback callback,
                                     void *userData) {
  mlir::detail::CallbackOstream stream(callback, userData);
  return wrap(emitHLSCpp(unwrap(module), stream));
}
