//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_H
#define SCALEHLS_TRANSFORMS_PASSES_H

#include "mlir/Pass/Pass.h"
#include "scalehls/Analysis/Utils.h"
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
                           bool insertCopy = true);

bool applySplitFunction(FuncOp func, OpBuilder &builder);

/// Apply loop perfection to all outer loops of the input loop until the outer
/// operation is no longer a loop, or contains more than one child loop.
bool applyAffineLoopPerfection(AffineForOp loop, OpBuilder &builder);

/// Apply remove variable bound to all inner loops of the input loop.
bool applyRemoveVariableBound(AffineForOp loop, OpBuilder &builder);

bool applyAffineLoopOrderOpt(AffineLoopBand &band, bool reverse = false);

/// Apply loop tiling and return the new loop that should be pipelined.
AffineForOp applyPartialAffineLoopTiling(AffineLoopBand &band,
                                         OpBuilder &builder,
                                         ArrayRef<unsigned> tileSizes);

/// Apply function pipelining to the input function, all contained loops are
/// automatically fully unrolled.
bool applyFuncPipelining(FuncOp func, OpBuilder &builder);

/// Apply loop pipelining to the input loop, all inner loops are automatically
/// fully unrolled.
bool applyLoopPipelining(AffineForOp loop, OpBuilder &builder);

bool applyArrayPartition(FuncOp func, OpBuilder &builder);

bool applyMergeAffineIf(FuncOp func);

bool applyAffineStoreForward(FuncOp func, OpBuilder &builder);

bool applySimplifyMemrefAccess(FuncOp func);

//===----------------------------------------------------------------------===//
// Optimization Pass Entries
//===----------------------------------------------------------------------===//

/// Design space exploration pass.
std::unique_ptr<Pass> createMultipleLevelDSEPass();

/// Dataflow optimization passes.
std::unique_ptr<Pass> createLegalizeDataflowPass();
std::unique_ptr<Pass> createSplitFunctionPass();

/// Loop optimization passes.
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createRemoveVariableBoundPass();
std::unique_ptr<Pass> createAffineLoopOrderOptPass();
std::unique_ptr<Pass> createPartialAffineLoopTilePass();

/// Directive optimization passes.
std::unique_ptr<Pass> createFuncPipeliningPass();
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createArrayPartitionPass();

/// Standard operation optimization passes.
std::unique_ptr<Pass> createMergeAffineIfPass();
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
