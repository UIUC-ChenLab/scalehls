//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_H
#define SCALEHLS_TRANSFORMS_PASSES_H

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

/// Fusion mode to attempt. The default mode `Greedy` does both
/// producer-consumer and sibling fusion.
enum AffineFusionMode { Greedy, ProducerConsumer, Sibling };
enum CreateSubviewMode { Point, Reduction };

void registerScaleHLSDSEPipeline();
void registerScaleHLSPyTorchPipelineV2();
void registerTransformsPasses();

void addCreateSubviewPasses(OpPassManager &pm,
                            CreateSubviewMode mode = CreateSubviewMode::Point);
void addSimplifyCopyPasses(OpPassManager &pm);
void addSimplifyAffineLoopPasses(OpPassManager &pm);

std::unique_ptr<Pass>
createDesignSpaceExplorePass(std::string dseTargetSpec = "");
std::unique_ptr<Pass> createFuncDuplicationPass();
std::unique_ptr<Pass>
createFuncPreprocessPass(std::string hlsTopFunc = "forward");

/// Dataflow-related passes.
std::unique_ptr<Pass> createBalanceDataflowNodePass();
std::unique_ptr<Pass> createBufferizeDataflowPass();
std::unique_ptr<Pass> createConvertDataflowToFuncPass();
std::unique_ptr<Pass> createCreateDataflowFromTosaPass();
std::unique_ptr<Pass> createCreateDataflowFromLinalgPass();
std::unique_ptr<Pass> createCreateDataflowFromAffinePass();
std::unique_ptr<Pass> createCreateTokenStreamPass();
std::unique_ptr<Pass>
createDataflowAwareLoopUnrollJamPass(unsigned loopUnrollFactor = 1,
                                     bool unrollPointLoopOnly = false);
std::unique_ptr<Pass> createEliminateMultiProducerPass();
std::unique_ptr<Pass> createLegalizeDataflowSchedulePass();
std::unique_ptr<Pass> createLowerDataflowPass();
std::unique_ptr<Pass>
createPlaceDataflowBufferPass(bool placeExternalBuffer = true);
std::unique_ptr<Pass> createScheduleDataflowNodePass();
std::unique_ptr<Pass> createStreamDataflowTaskPass();

/// Tensor-related passes.
std::unique_ptr<Pass> createConvertTensorToLinalgPass();
std::unique_ptr<Pass> createTosaFakeQuantizePass();
std::unique_ptr<Pass> createTosaSimplifyGraphPass();

/// Loop-related passes.
std::unique_ptr<Pass> createAffineLoopFusionPass(
    double computeToleranceThreshold = 0.3, unsigned fastMemorySpace = 0,
    uint64_t localBufSizeThreshold = 0, bool maximalFusion = false,
    enum AffineFusionMode fusionMode = AffineFusionMode::Greedy);
std::unique_ptr<Pass> createAffineLoopOrderOptPass();
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createAffineLoopTilePass(unsigned loopTileSize = 1);
std::unique_ptr<Pass>
createAffineLoopUnrollJamPass(unsigned loopUnrollFactor = 1,
                              bool unrollPointLoopOnly = false);
std::unique_ptr<Pass> createDetectReductionPass();
std::unique_ptr<Pass> createMaterializeReductionPass();
std::unique_ptr<Pass> createRemoveVariableBoundPass();

/// Memory-related passes.
std::unique_ptr<Pass> createAffineStoreForwardPass();
std::unique_ptr<Pass>
createCreateLocalBufferPass(bool externalBufferOnly = true,
                            bool registerOnly = false);
std::unique_ptr<Pass> createCreateMemrefSubviewPass(
    CreateSubviewMode createSubviewMode = CreateSubviewMode::Point);
std::unique_ptr<Pass>
createLowerCopyToAffinePass(bool internalCopyOnly = false);
std::unique_ptr<Pass> createRaiseAffineToCopyPass();
std::unique_ptr<Pass> createReduceInitialIntervalPass();
std::unique_ptr<Pass> createSimplifyAffineIfPass();
std::unique_ptr<Pass> createSimplifyCopyPass();

/// Directive-related passes.
std::unique_ptr<Pass> createArrayPartitionPass();
std::unique_ptr<Pass>
createCreateAxiInterfacePass(std::string hlsTopFunc = "forward");
std::unique_ptr<Pass> createCreateHLSPrimitivePass();
std::unique_ptr<Pass> createFuncPipeliningPass();
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createQoREstimationPass(std::string qorTargetSpec = "");

#define GEN_PASS_CLASSES
#include "scalehls/Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
