//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Transforms/Pipelines.h"
#include "mlir/CAPI/Pass.h"
#include "scalehls/Transforms/Pipelines.h"

using namespace mlir;
using namespace scalehls;

void mlirAddLinalgTransformPasses(MlirPassManager pm) {
  addLinalgTransformPasses(*unwrap(pm));
}
void mlirAddConvertLinalgToDataflowPasses(MlirPassManager pm) {
  addConvertLinalgToDataflowPasses(*unwrap(pm));
}
void mlirAddGenerateDesignSpacePasses(MlirPassManager pm) {
  addGenerateDesignSpacePasses(*unwrap(pm));
}
void mlirAddComprehensiveBufferizePasses(MlirPassManager pm) {
  addComprehensiveBufferizePasses(*unwrap(pm));
}
void mlirAddLowerDataflowPasses(MlirPassManager pm) {
  addLowerDataflowPasses(*unwrap(pm));
}
void mlirAddConvertDataflowToFuncPasses(MlirPassManager pm) {
  addConvertDataflowToFuncPasses(*unwrap(pm));
}

void mlirRegisterScaleHLSPipelines(void) { registerScaleHLSPipelines(); }
