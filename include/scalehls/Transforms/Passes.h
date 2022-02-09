//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
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

/// QoR estimation pass.
std::unique_ptr<Pass> createQoREstimationPass();

/// Design space exploration pass.
std::unique_ptr<Pass> createMultipleLevelDSEPass();

/// Dataflow optimization passes.
std::unique_ptr<Pass> createLegalizeDataflowPass();
std::unique_ptr<Pass> createSplitFunctionPass();

/// Loop optimization passes.
std::unique_ptr<Pass> createMaterializeReductionPass();
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createRemoveVariableBoundPass();
std::unique_ptr<Pass> createAffineLoopOrderOptPass();
std::unique_ptr<Pass> createPartialAffineLoopTilePass();
std::unique_ptr<Pass> createReduceInitialIntervalPass();

/// Directive optimization passes.
std::unique_ptr<Pass> createFuncPipeliningPass();
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createArrayPartitionPass();

/// Simplification passes.
std::unique_ptr<Pass> createSimplifyAffineIfPass();
std::unique_ptr<Pass> createAffineStoreForwardPass();
std::unique_ptr<Pass> createSimplifyMemrefAccessPass();

void registerTransformsPasses();

#define GEN_PASS_CLASSES
#include "scalehls/Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
