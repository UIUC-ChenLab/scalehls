//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_PIPELINES_PIPELINES_H
#define SCALEHLS_PIPELINES_PIPELINES_H

namespace mlir {
namespace scalehls {

void registerPipelines();
void registerScaleHLSPyTorchPipeline();

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_PIPELINES_PIPELINES_H
