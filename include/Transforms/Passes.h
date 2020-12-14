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
std::unique_ptr<mlir::Pass> createPragmaDSEPass();
std::unique_ptr<mlir::Pass> createLoopPipeliningPass();
std::unique_ptr<mlir::Pass> createArrayPartitionPass();

/// Loop optimization passes.
std::unique_ptr<mlir::Pass> createAffineLoopPerfectionPass();
std::unique_ptr<mlir::Pass> createPartialAffineLoopTilePass();
std::unique_ptr<mlir::Pass> createRemoveVarLoopBoundPass();

/// Dataflow optimization passes.
std::unique_ptr<mlir::Pass> createSplitFunctionPass();
std::unique_ptr<mlir::Pass> createLegalizeDataflowPass();

/// Bufferization passes.
std::unique_ptr<mlir::Pass> createHLSKernelBufferizePass();

void registerTransformsPasses();

#define GEN_PASS_CLASSES
#include "Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
