//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Registration.h"
#include "mlir/CAPI/IR.h"
#include "scalehls/InitAllDialects.h"
#include "scalehls/InitAllPasses.h"

using namespace mlir;
using namespace scalehls;

void mlirScaleHLSRegisterAllDialects(MlirDialectRegistry registry) {
  registerAllDialects(*unwrap(registry));
}

void mlirScaleHLSRegisterAllExtensions(MlirDialectRegistry registry) {
  registerAllExtensions(*unwrap(registry));
}

void mlirScaleHLSRegisterAllInterfaceExternalModels(
    MlirDialectRegistry registry) {
  registerAllInterfaceExternalModels(*unwrap(registry));
}

void mlirScaleHLSRegisterAllPasses(void) { scalehls::registerAllPasses(); }
