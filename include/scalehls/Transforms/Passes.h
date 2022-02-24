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
      *this, "top-func", llvm::cl::init("forward"),
      llvm::cl::desc("Specify the top function of the design")};

  Option<unsigned> optLevel{
      *this, "opt-level", llvm::cl::init(1),
      llvm::cl::desc("Optimization level from 0 to 7 (default level is 1)")};

  Option<unsigned> dataflowGran{
      *this, "dataflow-gran",
      llvm::cl::desc("The granularity of dataflow (set 0 to disable)")};

  Option<unsigned> loopUnrollSize{
      *this, "loop-unroll-size",
      llvm::cl::desc("The size of unrolling (set 0 to disable)")};

  Option<unsigned> vectorSize{
      *this, "vector-size",
      llvm::cl::desc("The size of vectorization (set 0 to disable)")};
};

/// QoR estimation and DSE passes.
std::unique_ptr<Pass> createQoREstimationPass();
std::unique_ptr<Pass> createMultipleLevelDSEPass();

/// Graph optimization passes.
std::unique_ptr<Pass> createSimplifyTosaGraphPass();
std::unique_ptr<Pass> createLegalizeDataflowPass();
std::unique_ptr<Pass> createLegalizeDataflowPass(unsigned dataflowGran);
std::unique_ptr<Pass> createSplitFunctionPass();
std::unique_ptr<Pass> createConvertCopyToAffineLoopsPass();

/// HLSCpp legalization pass.
std::unique_ptr<Pass> createLegalizeToHLSCppPass();
std::unique_ptr<Pass> createLegalizeToHLSCppPass(const ScaleHLSOptions &opts);

/// Loop optimization passes.
std::unique_ptr<Pass> createMaterializeReductionPass();
std::unique_ptr<Pass> createAffineLoopPerfectionPass();
std::unique_ptr<Pass> createRemoveVariableBoundPass();
std::unique_ptr<Pass> createAffineLoopOrderOptPass();
std::unique_ptr<Pass> createAffineLoopUnrollAndPipelinePass();
std::unique_ptr<Pass>
createAffineLoopUnrollAndPipelinePass(unsigned loopUnrollSize);

/// Tensor optimization passes. 
std::unique_ptr<Pass> createShareTensorOperationPass();

/// Simplification passes.
std::unique_ptr<Pass> createSimplifyAffineIfPass();
std::unique_ptr<Pass> createAffineStoreForwardPass();
std::unique_ptr<Pass> createSimplifyMemrefAccessPass();
std::unique_ptr<Pass> createReduceInitialIntervalPass();

void registerScaleHLSPassPipeline();
/// Directive optimization passes.
std::unique_ptr<Pass> createFuncPipeliningPass();
std::unique_ptr<Pass> createLoopPipeliningPass();
std::unique_ptr<Pass> createArrayPartitionPass();
std::unique_ptr<Pass> createCreateHLSCppPrimitivePass();

void registerScaleHLSPyTorchPipeline();
void registerTransformsPasses();

/// Other passes.
std::unique_ptr<Pass> createPreserveUnoptimizedPass();

#define GEN_PASS_CLASSES
#include "scalehls/Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
