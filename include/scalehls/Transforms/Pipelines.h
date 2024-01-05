//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PIPELINES_H
#define SCALEHLS_TRANSFORMS_PIPELINES_H

#include "mlir/Pass/PassManager.h"

namespace mlir {
namespace scalehls {

void addLinalgTransformPasses(OpPassManager &pm);
void addConvertLinalgToDataflowPasses(OpPassManager &pm);
void addComprehensiveBufferizePasses(OpPassManager &pm);
void addLowerDataflowPasses(OpPassManager &pm);
void addConvertDataflowToFuncPasses(OpPassManager &pm);

void registerScaleHLSPipelines();
void registerScaleHLSPyTorchPipeline();

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PIPELINES_H
