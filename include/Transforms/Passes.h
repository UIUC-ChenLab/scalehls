//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_H
#define SCALEHLS_TRANSFORMS_PASSES_H

#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
class Pass;
} // namespace mlir

namespace mlir {
namespace scalehls {

/// Pragma optimization passes.
std::unique_ptr<Pass> createPragmaDSEPass();
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createArrayPartitionPass();

/// Loop optimization passes.
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createPartialAffineLoopTilePass();
std::unique_ptr<Pass> createRemoveVarLoopBoundPass();

/// Dataflow optimization passes.
std::unique_ptr<Pass> createSplitFunctionPass();
std::unique_ptr<Pass> createLegalizeDataflowPass();

/// Bufferization passes.
std::unique_ptr<Pass> createHLSKernelBufferizePass();
std::unique_ptr<Pass> createStoreOpForwardPass();

void registerTransformsPasses();

#define GEN_PASS_CLASSES
#include "Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
