//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Translation/EmitHLSCpp.h"
#include "mlir/CAPI/IR.h"
#include "mlir/CAPI/Support.h"
#include "mlir/CAPI/Utils.h"
#include "scalehls/Translation/EmitHLSCpp.h"

using namespace mlir;
using namespace scalehls;

MlirLogicalResult mlirScaleHLSEmitHlsCpp(MlirModule module,
                                         MlirStringCallback callback,
                                         void *userData,
                                         int64_t axiMaxWidenBitwidth,
                                         bool omitGlobalConstants) {
  mlir::detail::CallbackOstream stream(callback, userData);
  return wrap(emitHLSCpp(unwrap(module), stream, axiMaxWidenBitwidth,
                         omitGlobalConstants));
}
