//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_INITALLPASSES_H
#define SCALEHLS_INITALLPASSES_H

#include "mlir/InitAllPasses.h"
#include "scalehls/Analysis/Passes.h"
#include "scalehls/Conversion/Passes.h"
#include "scalehls/Transforms/Passes.h"

namespace mlir {
namespace scalehls {

// Add all the ScaleHLS passes.
inline void registerAllPasses() {
  scalehls::registerAnalysisPasses();
  scalehls::registerConversionPasses();
  scalehls::registerTransformsPasses();

  // TODO: only register required passes.
  mlir::registerAllPasses();
}

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_INITALLPASSES_H
