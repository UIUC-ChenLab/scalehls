//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_INITALLPASSES_H
#define SCALEHLS_INITALLPASSES_H

#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Arith/Transforms/Passes.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Func/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
#include "mlir/Dialect/SCF/Transforms/Passes.h"
#include "mlir/Dialect/Shape/Transforms/Passes.h"
#include "mlir/Dialect/Tensor/Transforms/Passes.h"
#include "mlir/Dialect/Transform/Transforms/Passes.h"
#include "mlir/Dialect/Vector/Transforms/Passes.h"
#include "mlir/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

namespace mlir {
namespace scalehls {

// Add all the ScaleHLS passes.
inline void registerAllPasses() {
  // Transform passes.
  registerTransformsPasses();

  // Conversion passes.
  registerConversionPasses();

  // Dialect passes.
  affine::registerAffinePasses();
  arith::registerArithPasses();
  bufferization::registerBufferizationPasses();
  func::registerFuncPasses();
  registerLinalgPasses();
  memref::registerMemRefPasses();
  registerSCFPasses();
  registerShapePasses();
  tensor::registerTensorPasses();
  transform::registerTransformPasses();
  vector::registerVectorPasses();

  // ScaleHLS passes.
  hls::registerScaleHLSHLSTransformsPasses();
}

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_INITALLPASSES_H
