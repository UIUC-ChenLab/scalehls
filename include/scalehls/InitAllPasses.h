//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_INITALLPASSES_H
#define SCALEHLS_INITALLPASSES_H

#include "mlir/InitAllPasses.h"
#include "scalehls/Conversions/Passes.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Pipelines/Pipelines.h"
#include "scalehls/Transforms/Passes.h"

namespace mlir {
namespace scalehls {

// Add all the ScaleHLS passes.
inline void registerAllPasses() {
  scalehls::registerPipelines();
  scalehls::registerConversionsPasses();
  scalehls::registerTransformsPasses();
  mlir::registerAllPasses();

  hls::registerHLSPasses();
}

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_INITALLPASSES_H
