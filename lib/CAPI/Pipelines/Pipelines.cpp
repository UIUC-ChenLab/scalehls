//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Pipelines/Pipelines.h"
#include "mlir/CAPI/Pass.h"
#include "scalehls/Pipelines/Pipelines.h"

using namespace mlir;
using namespace scalehls;

void mlirAddLinalgTransformPasses(MlirPassManager pm) {
  addLinalgTransformPasses(*unwrap(pm));
}
void mlirAddComprehensiveBufferizePasses(MlirPassManager pm) {
  addComprehensiveBufferizePasses(*unwrap(pm));
}
void mlirAddConvertDataflowToFuncPasses(MlirPassManager pm) {
  addConvertDataflowToFuncPasses(*unwrap(pm));
}

void mlirRegisterScaleHLSPipelines(void) { registerScaleHLSPipelines(); }
