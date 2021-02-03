//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_PASSES_H
#define SCALEHLS_DIALECT_HLSKERNEL_PASSES_H

#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
class Pass;
} // namespace mlir

namespace mlir {
namespace scalehls {

std::unique_ptr<Pass> createHLSKernelBufferizePass();

void registerHLSKernelTransformsPasses();

#define GEN_PASS_CLASSES
#include "scalehls/Dialect/HLSKernel/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLSKERNEL_PASSES_H
