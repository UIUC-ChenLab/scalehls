//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_H
#define SCALEHLS_TRANSFORMS_PASSES_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
class Pass;
} // namespace mlir

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// Optimization APIs
//===----------------------------------------------------------------------===//

/// Apply loop perfection to all outer loops of the input loop until the outer
/// operation is no longer a loop, or contains more than one child loop.
bool applyAffineLoopPerfection(AffineForOp loop, OpBuilder &builder);

/// Apply remove variable bound to all inner loops of the input loop.
bool applyRemoveVariableBound(AffineForOp loop, OpBuilder &builder);

/// Apply loop pipelining to the input loop, all inner loops are automatically
/// fully unrolled.
bool applyLoopPipelining(AffineForOp loop, OpBuilder &builder);

bool applyArrayPartition(FuncOp func, OpBuilder &builder);

//===----------------------------------------------------------------------===//
// Optimization Pass Entries
//===----------------------------------------------------------------------===//

/// Pragma optimization passes.
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createArrayPartitionPass();
std::unique_ptr<Pass> createPragmaDSEPass();

/// Loop optimization passes.
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createPartialAffineLoopTilePass();
std::unique_ptr<Pass> createRemoveVariableBoundPass();

/// Dataflow optimization passes.
std::unique_ptr<Pass> createSplitFunctionPass();
std::unique_ptr<Pass> createLegalizeDataflowPass();

/// Bufferization passes.
std::unique_ptr<Pass> createHLSKernelBufferizePass();

/// MemRef Optimization Passes.
std::unique_ptr<Pass> createAffineStoreForwardPass();
std::unique_ptr<Pass> createSimplifyMemrefAccessPass();

void registerTransformsPasses();

#define GEN_PASS_CLASSES
#include "Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
