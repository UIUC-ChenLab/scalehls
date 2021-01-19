//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
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

bool applyLegalizeDataflow(FuncOp func, OpBuilder &builder, int64_t minGran,
                           bool insertCopy);

bool applySplitFunction(FuncOp func, OpBuilder &builder);

/// Apply loop perfection to all outer loops of the input loop until the outer
/// operation is no longer a loop, or contains more than one child loop.
bool applyAffineLoopPerfection(AffineForOp loop, OpBuilder &builder);

/// Apply remove variable bound to all inner loops of the input loop.
bool applyRemoveVariableBound(AffineForOp loop, OpBuilder &builder);

bool applyAffineLoopOrderOpt(AffineForOp loop, OpBuilder &builder);

/// Apply loop pipelining to the input loop, all inner loops are automatically
/// fully unrolled.
bool applyLoopPipelining(AffineForOp loop, OpBuilder &builder);

bool applyArrayPartition(FuncOp func, OpBuilder &builder);

/// Apply function pipelining to the input function, all contained loops are
/// automatically fully unrolled.
bool applyFuncPipelining(FuncOp func, OpBuilder &builder);

bool applyAffineStoreForward(FuncOp func, OpBuilder &builder);

bool applySimplifyMemrefAccess(FuncOp func);

//===----------------------------------------------------------------------===//
// Optimization Pass Entries
//===----------------------------------------------------------------------===//

/// Design space exploration pass.
std::unique_ptr<Pass> createMultipleLevelDSEPass();

/// Directive optimization passes.
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createArrayPartitionPass();
std::unique_ptr<Pass> createFuncPipeliningPass();

/// Loop optimization passes.
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createRemoveVariableBoundPass();
std::unique_ptr<Pass> createPartialAffineLoopTilePass();
std::unique_ptr<Pass> createAffineLoopOrderOptPass();

/// Dataflow optimization passes.
std::unique_ptr<Pass> createLegalizeDataflowPass();
std::unique_ptr<Pass> createSplitFunctionPass();

/// Standard operation optimization passes.
std::unique_ptr<Pass> createAffineStoreForwardPass();
std::unique_ptr<Pass> createSimplifyMemrefAccessPass();

/// Bufferization pass.
std::unique_ptr<Pass> createHLSKernelBufferizePass();

void registerTransformsPasses();

#define GEN_PASS_CLASSES
#include "scalehls/Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
