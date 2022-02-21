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

struct ScaleHLSOptions : public PassPipelineOptions<ScaleHLSOptions> {
  Option<std::string> hlscppTopFunc{
      *this, "top-func", llvm::cl::init("main"),
      llvm::cl::desc("Specify the top function of the design")};

  Option<unsigned> optLevel{
      *this, "opt-level", llvm::cl::init(1),
      llvm::cl::desc("Optimization level from 0 to 7. Default is 1.")};

  Option<unsigned> dataflowGran{
      *this, "dataflow-gran",
      llvm::cl::desc("The granularity of dataflow. 0 indicates disabled.")};

  Option<unsigned> loopTileSize{
      *this, "loop-tile-size",
      llvm::cl::desc("The size of tiling. 0 indicates disabled.")};

  Option<unsigned> vectorSize{
      *this, "vector-size",
      llvm::cl::desc("The size of vectorization. 0 indicates disabled.")};
};

/// QoR estimation pass.
std::unique_ptr<Pass> createQoREstimationPass();

/// Design space exploration pass.
std::unique_ptr<Pass> createMultipleLevelDSEPass();

/// Dataflow optimization passes.
std::unique_ptr<Pass> createLegalizeDataflowPass();
std::unique_ptr<Pass> createLegalizeDataflowPass(unsigned dataflowGran);
std::unique_ptr<Pass> createSplitFunctionPass();

/// Loop optimization passes.
std::unique_ptr<Pass> createMaterializeReductionPass();
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createRemoveVariableBoundPass();
std::unique_ptr<Pass> createAffineLoopOrderOptPass();
std::unique_ptr<Pass> createPartialAffineLoopTilePass();
std::unique_ptr<Pass> createPartialAffineLoopTilePass(unsigned loopTileSize);

/// Directive optimization passes.
std::unique_ptr<Pass> createLegalizeToHLSCppPass();
std::unique_ptr<Pass> createLegalizeToHLSCppPass(const ScaleHLSOptions &opts);
std::unique_ptr<Pass> createFuncPipeliningPass();
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createArrayPartitionPass();
std::unique_ptr<Pass> createCreateHLSCppPrimitivePass();

/// Simplification passes.
std::unique_ptr<Pass> createSimplifyAffineIfPass();
std::unique_ptr<Pass> createAffineStoreForwardPass();
std::unique_ptr<Pass> createSimplifyMemrefAccessPass();
std::unique_ptr<Pass> createReduceInitialIntervalPass();

/// Other passes.
std::unique_ptr<Pass> createPreserveUnoptimizedPass();

void registerScaleHLSPassPipeline();
void registerTransformsPasses();

#define GEN_PASS_CLASSES
#include "scalehls/Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
