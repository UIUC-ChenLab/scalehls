//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_INITALLPASSES_H
#define SCALEHLS_INITALLPASSES_H

#include "mlir/InitAllPasses.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Pipelines.h"

namespace mlir {
namespace scalehls {

// Add all the ScaleHLS passes.
inline void registerAllPasses() {
  mlir::registerAllPasses();

  hls::registerScaleHLSHLSTransformsPasses();
  scalehls::registerScaleHLSTransformsPasses();
  scalehls::registerScaleHLSPipelines();
}

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_INITALLPASSES_H
