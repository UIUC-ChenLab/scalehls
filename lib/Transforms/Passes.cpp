//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
#include "mlir/Dialect/Tensor/Transforms/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "scalehls/Transforms/Passes.h.inc"
} // namespace

namespace {
struct ScaleHLSDSEPipelineOptions
    : public PassPipelineOptions<ScaleHLSDSEPipelineOptions> {
  Option<std::string> hlsTopFunc{
      *this, "top-func", llvm::cl::init("main"),
      llvm::cl::desc("Specify the top function of the design")};

  Option<std::string> dseTargetSpec{
      *this, "target-spec", llvm::cl::init("./config.json"),
      llvm::cl::desc(
          "File path: target backend specifications and configurations")};
};
} // namespace

void scalehls::registerScaleHLSDSEPipeline() {
  PassPipelineRegistration<ScaleHLSDSEPipelineOptions>(
      "scalehls-dse-pipeline",
      "Launch design space exploration for C/C++ kernel",
      [](OpPassManager &pm, const ScaleHLSDSEPipelineOptions &opts) {
        // Legalize the input program.
        pm.addPass(scalehls::createFuncPreprocessPass(opts.hlsTopFunc));
        pm.addPass(scalehls::createMaterializeReductionPass());

        // Apply the automatic design space exploration to the top function.
        pm.addPass(scalehls::createDesignSpaceExplorePass(opts.dseTargetSpec));

        // Finally, estimate the QoR of the DSE result.
        pm.addPass(scalehls::createQoREstimationPass(opts.dseTargetSpec));
      });
}

namespace {
struct ScaleHLSPyTorchPipelineV2Options
    : public PassPipelineOptions<ScaleHLSPyTorchPipelineV2Options> {
  Option<std::string> hlsTopFunc{
      *this, "top-func", llvm::cl::init("forward"),
      llvm::cl::desc("Specify the top function of the design")};

  // Option<unsigned> optLevel{
  //     *this, "opt-level", llvm::cl::init(1),
  //     llvm::cl::desc("Optimization level from 0 to 7 (default level is 1)")};

  // Option<unsigned> dataflowGranularity{
  //     *this, "dataflow-granularity",
  //     llvm::cl::desc("The granularity of dataflow (set 0 to disable)")};

  Option<double> fusionComputeTolerance{
      *this, "fusion-compute-tolerance", llvm::cl::init(100.0),
      llvm::cl::desc("Fractional increase in additional computation tolerated "
                     "while loop fusing (default is 100.0)")};

  Option<unsigned> loopTileSize{
      *this, "loop-tile-size", llvm::cl::init(2),
      llvm::cl::desc("The tile size of each loop (must larger than 1)")};

  Option<unsigned> loopUnrollFactor{
      *this, "loop-unroll-factor", llvm::cl::init(0),
      llvm::cl::desc("The overall loop unrolling factor (set 0 to disable)")};

  // Option<unsigned> vectorSize{
  //     *this, "vector-size",
  //     llvm::cl::desc("The size of vectorization (set 0 to disable)")};

  Option<bool> fakeQuantize{
      *this, "fake-quantize", llvm::cl::init(false),
      llvm::cl::desc("Trigger the fake quantization (just for testing use)")};
};
} // namespace

void scalehls::registerScaleHLSPyTorchPipelineV2() {
  PassPipelineRegistration<ScaleHLSPyTorchPipelineV2Options>(
      "scalehls-pytorch-pipeline-v2",
      "Compile TOSA (from Torch-MLIR) to HLS C++ version 2",
      [](OpPassManager &pm, const ScaleHLSPyTorchPipelineV2Options &opts) {
        if (opts.loopTileSize < 2)
          llvm_unreachable("loop tile size must be larger than 1");

        // TOSA fake quantization.
        if (opts.fakeQuantize)
          pm.addPass(scalehls::createTosaFakeQuantizePass());

        // Graph-level optimization.
        pm.addPass(scalehls::createTosaSimplifyGraphPass());
        pm.addPass(scalehls::createTosaNodeFusionPass());
        pm.addPass(scalehls::createCreateFuncDataflowPass());
        pm.addPass(scalehls::createLegalizeDataflowPass());
        pm.addPass(scalehls::createCreateTokenDependsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // TOSA to Linalg conversion.
        pm.addNestedPass<func::FuncOp>(tosa::createTosaToLinalgNamed());
        pm.addPass(scalehls::createTosaToLinalgCleanupPass());
        pm.addNestedPass<func::FuncOp>(tosa::createTosaToLinalg());
        pm.addPass(tosa::createTosaToStandard());
        pm.addPass(mlir::createLinalgGeneralizationPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Tensor bufferization.
        pm.addPass(mlir::createLinalgBufferizePass());
        pm.addPass(scalehls::createBufferizeDataflowPass());
        pm.addPass(func::createFuncBufferizePass());
        pm.addPass(bufferization::createBufferResultsToOutParamsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Dataflow and Linalg lowering.
        pm.addPass(scalehls::createConvertDataflowToFuncPass());
        pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());
        pm.addPass(memref::createFoldSubViewOpsPass());
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Affine loop fusion.
        pm.addPass(mlir::createLoopFusionPass(opts.fusionComputeTolerance));
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createRaiseImplicitCopyPass());
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());

        // Create runtime components.
        pm.addPass(scalehls::createCreateRuntimeMainPass(opts.hlsTopFunc));
        pm.addPass(scalehls::createCreateAxiInterfacePass());

        // // Vectorization.
        // if (opts.vectorSize) {
        //   pm.addPass(mlir::createSuperVectorizePass({opts.vectorSize}));
        //   pm.addPass(mlir::createCanonicalizerPass());
        // }

        // Affine loop perfectization.
        pm.addPass(scalehls::createFuncPreprocessPass(opts.hlsTopFunc));
        pm.addPass(scalehls::createMaterializeReductionPass());
        pm.addPass(bufferization::createBufferLoopHoistingPass());
        pm.addPass(scalehls::createAffineLoopPerfectionPass());
        pm.addPass(mlir::createAffineScalarReplacementPass());
        pm.addPass(scalehls::createRemoveVariableBoundPass());

        // Affine loop tiling.
        pm.addPass(scalehls::createAffineLoopTilePass(opts.loopTileSize));
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createAffineLoopOrderOptPass());

        // Local buffer allocation.
        pm.addPass(scalehls::createCreateMemrefSubviewPass());
        pm.addPass(mlir::createCSEPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createPromoteBufferPass());
        pm.addPass(bufferization::createBufferLoopHoistingPass());
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass(
            /*convertInternCopyOnly=*/false));
        pm.addPass(memref::createFoldSubViewOpsPass());
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Affine loop dataflowing.
        pm.addPass(scalehls::createCreateLoopDataflowPass());
        pm.addPass(scalehls::createLegalizeDataflowPass());
        pm.addPass(scalehls::createBufferizeDataflowPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createConvertDataflowToFuncPass());

        // Affine loop unrolling.
        if (opts.loopUnrollFactor) {
          pm.addPass(scalehls::createAffineLoopUnrollJamPass(
              opts.loopUnrollFactor, /*unrollPointLoopOnly=*/true));
          pm.addPass(mlir::createAffineLoopNormalizePass());
          pm.addPass(mlir::createSimplifyAffineStructuresPass());
          pm.addPass(mlir::createCanonicalizerPass());
        }

        // Memory optimization.
        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createSimplifyMemrefAccessPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Directive-level optimization.
        pm.addPass(scalehls::createLoopPipeliningPass());
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSPrimitivePass());
        pm.addPass(mlir::createCSEPass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

namespace {
struct ScaleHLSConvertTosaToHLSOptions
    : public PassPipelineOptions<ScaleHLSConvertTosaToHLSOptions> {
  Option<std::string> hlsTopFunc{
      *this, "top-func", llvm::cl::init("main"),
      llvm::cl::desc("Specify the top function of the design")};
};
} // namespace

void scalehls::registerScaleHLSConvertTosaToHLS() {
  PassPipelineRegistration<ScaleHLSConvertTosaToHLSOptions>(
      "scalehls-convert-tosa-to-hls",
      "Lower TOSA operations to Affine HLS code",
      [](OpPassManager &pm, const ScaleHLSConvertTosaToHLSOptions &opts) {
        // Graph-level optimization.
        pm.addPass(scalehls::createTosaSimplifyGraphPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // TOSA to Linalg conversion.
        pm.addNestedPass<func::FuncOp>(tosa::createTosaToLinalgNamed());
        pm.addPass(scalehls::createTosaToLinalgCleanupPass());
        pm.addNestedPass<func::FuncOp>(tosa::createTosaToLinalg());
        pm.addPass(tosa::createTosaToStandard());
        pm.addPass(mlir::createLinalgGeneralizationPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Tensor bufferization.
        pm.addPass(mlir::createLinalgBufferizePass());
        pm.addPass(mlir::createTensorBufferizePass());
        pm.addPass(func::createFuncBufferizePass());
        pm.addPass(bufferization::createBufferResultsToOutParamsPass());

        // Dataflow and Linalg lowering.
        pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());
        pm.addPass(memref::createFoldSubViewOpsPass());
        pm.addPass(scalehls::createLowerCastAndSubviewPass());
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());
        pm.addPass(memref::createFoldSubViewOpsPass());
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createLowerCastAndSubviewPass());

        // Create runtime components.
        pm.addPass(scalehls::createCreateRuntimeMainPass(opts.hlsTopFunc));
        // pm.addPass(scalehls::createCreateAxiInterfacePass());

        // Affine loop perfectization.
        pm.addPass(scalehls::createFuncPreprocessPass(opts.hlsTopFunc));
        pm.addPass(scalehls::createMaterializeReductionPass());
        pm.addPass(bufferization::createBufferLoopHoistingPass());
        pm.addPass(scalehls::createAffineLoopPerfectionPass());
        pm.addPass(mlir::createAffineScalarReplacementPass());
        pm.addPass(scalehls::createRemoveVariableBoundPass());

        // Affine loop tiling.
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Memory optimization.
        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createSimplifyMemrefAccessPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

namespace {
struct ScaleHLSApplyDSEResultsOptions
    : public PassPipelineOptions<ScaleHLSApplyDSEResultsOptions> {
  Option<std::string> ILPSolution{
      *this, "ilp-solution", llvm::cl::init("./ilp_solution.json"),
      llvm::cl::desc("File path: optimization solution found by ILP")};
};
} // namespace

void scalehls::registerScaleHLSApplyDSEResults() {
  PassPipelineRegistration<ScaleHLSApplyDSEResultsOptions>(
      "scalehls-apply-dse-results", "Apply DSE results to the design",
      [](OpPassManager &pm, const ScaleHLSApplyDSEResultsOptions &opts) {
        // Directive-level optimization.
        pm.addPass(scalehls::createApplyILPSolutionPass(opts.ILPSolution));
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());
        pm.addPass(scalehls::createLoopPipeliningPass());
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSPrimitivePass());
        pm.addPass(mlir::createCSEPass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

void scalehls::registerTransformsPasses() {
  registerScaleHLSDSEPipeline();
  registerScaleHLSPyTorchPipelineV2();
  registerScaleHLSConvertTosaToHLS();
  registerScaleHLSApplyDSEResults();
  registerPasses();
}
