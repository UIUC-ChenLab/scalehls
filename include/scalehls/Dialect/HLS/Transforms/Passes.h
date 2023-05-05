//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_H
#define SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_H

#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/Pass/Pass.h"
#include "scalehls/InitAllDialects.h"
#include <memory>

namespace mlir {
class Pass;
namespace func {
class FuncOp;
} // namespace func
} // namespace mlir

namespace mlir {
namespace scalehls {
namespace hls {

std::unique_ptr<Pass> createEliminateBufferYieldPass();
std::unique_ptr<Pass>
createParameterizeDataflowTaskPass(unsigned defaultTileFactor = 32,
                                   unsigned defaultParallelFactor = 2);

#define GEN_PASS_CLASSES
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"

#define GEN_PASS_REGISTRATION
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"

} // namespace hls
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_H
