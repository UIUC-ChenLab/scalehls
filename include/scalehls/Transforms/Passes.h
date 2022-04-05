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
namespace func {
class FuncOp;
} // namespace func
} // namespace mlir

namespace mlir {
namespace scalehls {

void registerScaleHLSDSEPipeline();
void registerScaleHLSPyTorchPipelineV2();
void registerTransformsPasses();

/// Design space exploration passes.
std::unique_ptr<Pass>
createDesignSpaceExplorePass(std::string dseTargetSpec = "");

/// Graph optimization passes.
std::unique_ptr<Pass> createTosaFakeQuantizePass();
std::unique_ptr<Pass> createTosaSimplifyGraphPass();
std::unique_ptr<Pass> createTosaNodeFusionPass();
std::unique_ptr<Pass> createCreateTokenFlowPass();
std::unique_ptr<Pass>
createFuncDataflowPass(std::string dataflowTargetFunc = "forward",
                       unsigned dataflowGran = 1, bool dataflowBalance = true);
std::unique_ptr<Pass> createDataflowLegalizePass();
std::unique_ptr<Pass> createDataflowBufferizePass();
std::unique_ptr<Pass> createConvertDataflowToFuncPass();
std::unique_ptr<Pass> createTosaToLinalgCleanupPass();

/// Runtime-related passes.
std::unique_ptr<Pass>
createCreateRuntimeMainPass(std::string hlsTopFunc = "forward");
std::unique_ptr<Pass> createCreateAxiInterfacePass();

/// Loop optimization passes.
std::unique_ptr<Pass>
createFuncPreprocessPass(std::string hlsTopFunc = "forward");
std::unique_ptr<Pass>
createConvertCopyToAffineLoopsPass(bool convertInternCopyOnly = true);
std::unique_ptr<Pass> createMaterializeReductionPass();
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createRemoveVariableBoundPass();
std::unique_ptr<Pass> createAffineLoopOrderOptPass();
std::unique_ptr<Pass> createAffineLoopTilePass(unsigned loopTileSize = 1);
std::unique_ptr<Pass>
createAffineLoopUnrollJamPass(unsigned loopUnrollFactor = 1,
                              bool unrollPointLoopOnly = false);
std::unique_ptr<Pass> createAffineLoopDataflowPass(unsigned dataflowGran = 1,
                                                   bool dataflowBalance = true);
std::unique_ptr<Pass> createSimplifyAffineIfPass();

/// Memory optimization passes.
std::unique_ptr<Pass> createCreateMemrefSubviewPass();
std::unique_ptr<Pass> createPromoteBufferPass();
std::unique_ptr<Pass> createAffineStoreForwardPass();
std::unique_ptr<Pass> createSimplifyMemrefAccessPass();
std::unique_ptr<Pass> createRaiseImplicitCopyPass();
std::unique_ptr<Pass> createReduceInitialIntervalPass();

/// Directive optimization passes.
std::unique_ptr<Pass> createFuncPipeliningPass();
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createArrayPartitionPass();
std::unique_ptr<Pass> createCreateHLSPrimitivePass();
std::unique_ptr<Pass> createQoREstimationPass(std::string qorTargetSpec = "");

#define GEN_PASS_CLASSES
#include "scalehls/Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
