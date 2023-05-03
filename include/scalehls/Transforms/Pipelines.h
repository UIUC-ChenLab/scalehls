//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PIPELINES_H
#define SCALEHLS_TRANSFORMS_PIPELINES_H

namespace mlir {
namespace scalehls {

void registerScaleHLSPipelines();
void registerScaleHLSPyTorchPipeline();

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PIPELINES_H
