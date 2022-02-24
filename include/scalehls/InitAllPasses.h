//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_INITALLPASSES_H
#define SCALEHLS_INITALLPASSES_H

#include "mlir/InitAllPasses.h"
#include "scalehls/Transforms/Passes.h"

namespace mlir {
namespace scalehls {

// Add all the ScaleHLS passes.
inline void registerAllPasses() {
  scalehls::registerTransformsPasses();
  mlir::registerAllPasses();
}

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_INITALLPASSES_H
