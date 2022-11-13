//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Arith/Transforms/Passes.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
#include "mlir/Dialect/Tensor/Transforms/Passes.h"
#include "mlir/Dialect/Tosa/Transforms/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
#include "scalehls/Transforms/Passes.h"

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
        pm.addPass(bufferization::createBufferLoopHoistingPass());

        // Apply the automatic design space exploration to the top function.
        pm.addPass(scalehls::createDesignSpaceExplorePass(opts.dseTargetSpec));

        // Finally, estimate the QoR of the DSE result.
        pm.addPass(scalehls::createQoREstimationPass(opts.dseTargetSpec));
      });
}

void scalehls::addCreateSubviewPasses(OpPassManager &pm,
                                      CreateSubviewMode mode) {
  pm.addPass(scalehls::createCreateMemrefSubviewPass(mode));
  pm.addPass(mlir::createCSEPass());
  pm.addPass(mlir::createCanonicalizerPass());
}

void scalehls::addSimplifyAffineLoopPasses(OpPassManager &pm) {
  pm.addPass(mlir::createAffineLoopNormalizePass());
  pm.addPass(mlir::createSimplifyAffineStructuresPass());
  pm.addPass(mlir::createCanonicalizerPass());
}

namespace {
struct ScaleFlowPyTorchPipelineOptions
    : public PassPipelineOptions<ScaleFlowPyTorchPipelineOptions> {
  Option<std::string> hlsTopFunc{
      *this, "top-func", llvm::cl::init("forward"),
      llvm::cl::desc("Specify the top function of the design")};

  // Option<unsigned> optLevel{
  //     *this, "opt-level", llvm::cl::init(1),
  //     llvm::cl::desc("Optimization level from 0 to 7 (default level is 1)")};

  // Option<unsigned> dataflowGranularity{
  //     *this, "dataflow-granularity",
  //     llvm::cl::desc("The granularity of dataflow (set 0 to disable)")};

  Option<double> fusionTolerance{
      *this, "fusion-tolerance", llvm::cl::init(100.0),
      llvm::cl::desc("Additional computation tolerated while loop fusing "
                     "(default is 100.0)")};

  Option<unsigned> loopTileSize{
      *this, "loop-tile-size", llvm::cl::init(2),
      llvm::cl::desc("The tile size of each loop (must larger equal to 1)")};

  Option<unsigned> loopUnrollFactor{
      *this, "loop-unroll-factor", llvm::cl::init(0),
      llvm::cl::desc("The overall loop unrolling factor (set 0 to disable)")};

  Option<unsigned> parallelizeOptimizeLevel{
      *this, "parallelize-optimize-level", llvm::cl::init(2),
      llvm::cl::desc(
          "The optimization level in dataflow parallelization: 0 = none; 1 = "
          "complexity-aware; 2 = complexity and correlation-aware")};

  Option<bool> placeExternalBuffer{
      *this, "place-external-buffer", llvm::cl::init(true),
      llvm::cl::desc("Place buffers in external memories")};

  Option<bool> axiInterface{*this, "axi-interface", llvm::cl::init(true),
                            llvm::cl::desc("Create AXI interface")};

  Option<bool> vectorize{*this, "vectorize", llvm::cl::init(false),
                         llvm::cl::desc("Vectorize with factor of 2")};

  Option<bool> tosaInput{*this, "tosa-input", llvm::cl::init(false),
                         llvm::cl::desc("Inidicate the input IR is TOSA")};

  Option<bool> fakeQuantize{
      *this, "fake-quantize", llvm::cl::init(false),
      llvm::cl::desc("Trigger the fake quantization (just for testing use)")};

  Option<unsigned> debugPoint{
      *this, "debug-point", llvm::cl::init(0),
      llvm::cl::desc("Stop the pipeline at the given debug point")};
};
} // namespace

void scalehls::registerScaleFlowPyTorchPipeline() {
  PassPipelineRegistration<ScaleFlowPyTorchPipelineOptions>(
      "scaleflow-pytorch-pipeline",
      "Compile TOSA (from Torch-MLIR) to HLS C++ with ScaleFlow",
      [](OpPassManager &pm, const ScaleFlowPyTorchPipelineOptions &opts) {
        if (opts.tosaInput) {
          // TOSA optimization.
          pm.addPass(scalehls::createTosaSimplifyGraphPass());
          pm.addPass(scalehls::createCreateDataflowFromTosaPass());
          pm.addPass(mlir::createCanonicalizerPass());

          // TOSA to Linalg conversion.
          tosa::addTosaToLinalgPasses(pm);
          pm.addPass(tosa::createTosaToArith());
          pm.addPass(tosa::createTosaToTensor());
        }

        // Linalg fake quantization.
        if (opts.fakeQuantize)
          pm.addPass(scalehls::createLinalgFakeQuantizePass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 1)
          return;

        // Linalg optimization.
        pm.addPass(mlir::createLinalgElementwiseOpFusionPass());
        pm.addPass(scalehls::createCreateDataflowFromLinalgPass());
        pm.addPass(mlir::createConvertTensorToLinalgPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 2)
          return;

        // Bufferization.
        pm.addPass(mlir::createLinalgBufferizePass());
        pm.addPass(arith::createArithBufferizePass());
        pm.addPass(mlir::createTensorBufferizePass());
        pm.addPass(func::createFuncBufferizePass());
        pm.addPass(bufferization::createBufferResultsToOutParamsPass());
        pm.addPass(scalehls::createBufferizeDataflowPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 3)
          return;

        // Linalg to Affine conversion.
        pm.addPass(mlir::createLinalgGeneralizationPass());
        pm.addPass(scalehls::createSimplifyCopyPass());
        pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(memref::createFoldMemRefAliasOpsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 4)
          return;

        // Affine loop fusion.
        pm.addPass(scalehls::createFuncPreprocessPass(opts.hlsTopFunc));
        pm.addPass(scalehls::createAffineLoopFusionPass(opts.fusionTolerance));
        scalehls::addSimplifyAffineLoopPasses(pm);
        scalehls::addCreateSubviewPasses(pm);
        pm.addPass(scalehls::createRaiseAffineToCopyPass());
        pm.addPass(scalehls::createSimplifyCopyPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(memref::createFoldMemRefAliasOpsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 5)
          return;

        // Place dataflow buffers.
        pm.addPass(
            scalehls::createPlaceDataflowBufferPass(opts.placeExternalBuffer));

        // if (opts.vectorize) {
        //   pm.addPass(mlir::createSuperVectorizePass({2}));
        //   pm.addPass(mlir::createCanonicalizerPass());
        // }

        if (opts.debugPoint == 6)
          return;

        // Affine loop tiling.
        pm.addPass(scalehls::createFuncPreprocessPass(opts.hlsTopFunc));
        pm.addPass(bufferization::createBufferLoopHoistingPass());
        pm.addPass(scalehls::createAffineLoopPerfectionPass());
        pm.addPass(scalehls::createAffineLoopOrderOptPass());
        pm.addPass(scalehls::createAffineLoopTilePass(opts.loopTileSize));
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 7)
          return;

        // Local buffer allocation.
        scalehls::addCreateSubviewPasses(pm);
        pm.addPass(scalehls::createCreateLocalBufferPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(memref::createFoldMemRefAliasOpsPass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 8)
          return;

        // Affine loop dataflowing.
        pm.addPass(scalehls::createCollapseMemrefUnitDimsPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createCreateDataflowFromAffinePass());
        pm.addPass(scalehls::createStreamDataflowTaskPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 9)
          return;

        // Lower and optimize dataflow.
        pm.addPass(scalehls::createLowerDataflowPass());
        pm.addPass(scalehls::createEliminateMultiProducerPass());
        pm.addPass(scalehls::createEliminateMultiConsumerPass());
        pm.addPass(scalehls::createScheduleDataflowNodePass());
        pm.addPass(scalehls::createBalanceDataflowNodePass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 10)
          return;

        // Parallelize dataflow.
        if (opts.loopUnrollFactor) {
          pm.addPass(scalehls::createParallelizeDataflowNodePass(
              opts.loopUnrollFactor, /*unrollPointLoopOnly=*/true,
              opts.parallelizeOptimizeLevel));
          pm.addPass(mlir::createSimplifyAffineStructuresPass());
          pm.addPass(mlir::createCanonicalizerPass());
        }

        if (opts.debugPoint == 11)
          return;

        // Memory optimization.
        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 12)
          return;

        // Convert dataflow to func.
        pm.addPass(scalehls::createCreateTokenStreamPass());
        pm.addPass(scalehls::createConvertDataflowToFuncPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 13)
          return;

        // Directive-level optimization.
        if (opts.axiInterface)
          pm.addPass(scalehls::createCreateAxiInterfacePass(opts.hlsTopFunc));
        pm.addPass(scalehls::createLoopPipeliningPass());
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSPrimitivePass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

/// FIXME: Don't use! This is just for testing purpose.
void scalehls::registerScaleFlowPyTorchPipelinePost() {
  PassPipelineRegistration<ScaleFlowPyTorchPipelineOptions>(
      "scaleflow-pytorch-pipeline-post",
      "Compile TOSA (from Torch-MLIR) to HLS C++ with ScaleFlow",
      [](OpPassManager &pm, const ScaleFlowPyTorchPipelineOptions &opts) {
        // Parallelize dataflow.
        if (opts.loopUnrollFactor) {
          pm.addPass(scalehls::createParallelizeDataflowNodePass(
              opts.loopUnrollFactor, /*unrollPointLoopOnly=*/true));
          // pm.addPass(scalehls::createAffineLoopUnrollJamPass(
          //     opts.loopUnrollFactor, /*unrollPointLoopOnly=*/true));
          pm.addPass(mlir::createSimplifyAffineStructuresPass());
          pm.addPass(mlir::createCanonicalizerPass());
        }

        if (opts.debugPoint == 11)
          return;

        // Memory optimization.
        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 12)
          return;

        // Convert dataflow to func.
        pm.addPass(scalehls::createCreateTokenStreamPass());
        pm.addPass(scalehls::createConvertDataflowToFuncPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 13)
          return;

        // Directive-level optimization.
        if (opts.axiInterface)
          pm.addPass(scalehls::createCreateAxiInterfacePass(opts.hlsTopFunc));
        pm.addPass(scalehls::createLoopPipeliningPass());
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSPrimitivePass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

void scalehls::registerScaleHLSPyTorchPipeline() {
  PassPipelineRegistration<ScaleFlowPyTorchPipelineOptions>(
      "scalehls-pytorch-pipeline",
      "Compile TOSA (from Torch-MLIR) to HLS C++ with ScaleHLS",
      [](OpPassManager &pm, const ScaleFlowPyTorchPipelineOptions &opts) {
        if (opts.tosaInput) {
          // TOSA optimization.
          pm.addPass(scalehls::createTosaSimplifyGraphPass());
          pm.addPass(scalehls::createCreateDataflowFromTosaPass());
          pm.addPass(mlir::createCanonicalizerPass());

          // TOSA to Linalg conversion.
          tosa::addTosaToLinalgPasses(pm);
          pm.addPass(tosa::createTosaToArith());
          pm.addPass(tosa::createTosaToTensor());
        }

        // Linalg fake quantization.
        if (opts.fakeQuantize)
          pm.addPass(scalehls::createLinalgFakeQuantizePass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 1)
          return;

        // Linalg optimization.
        pm.addPass(mlir::createLinalgElementwiseOpFusionPass());
        pm.addPass(scalehls::createCreateDataflowFromLinalgPass());
        pm.addPass(mlir::createConvertTensorToLinalgPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 2)
          return;

        // Bufferization.
        pm.addPass(mlir::createLinalgBufferizePass());
        pm.addPass(arith::createArithBufferizePass());
        pm.addPass(mlir::createTensorBufferizePass());
        pm.addPass(func::createFuncBufferizePass());
        pm.addPass(bufferization::createBufferResultsToOutParamsPass());
        pm.addPass(scalehls::createBufferizeDataflowPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 3)
          return;

        // Linalg to Affine conversion.
        pm.addPass(mlir::createLinalgGeneralizationPass());
        pm.addPass(scalehls::createSimplifyCopyPass());
        pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(memref::createFoldMemRefAliasOpsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 4)
          return;

        // Affine loop fusion.
        pm.addPass(scalehls::createFuncPreprocessPass(opts.hlsTopFunc));
        pm.addPass(scalehls::createAffineLoopFusionPass(opts.fusionTolerance));
        scalehls::addSimplifyAffineLoopPasses(pm);
        scalehls::addCreateSubviewPasses(pm);
        pm.addPass(scalehls::createRaiseAffineToCopyPass());
        pm.addPass(scalehls::createSimplifyCopyPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(memref::createFoldMemRefAliasOpsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 5)
          return;

        // Place dataflow buffers.
        pm.addPass(
            scalehls::createPlaceDataflowBufferPass(opts.placeExternalBuffer));

        // if (opts.vectorize) {
        //   pm.addPass(mlir::createSuperVectorizePass({2}));
        //   pm.addPass(mlir::createCanonicalizerPass());
        // }

        if (opts.debugPoint == 6)
          return;

        // Affine loop tiling.
        pm.addPass(scalehls::createFuncPreprocessPass(opts.hlsTopFunc));
        pm.addPass(bufferization::createBufferLoopHoistingPass());
        pm.addPass(scalehls::createAffineLoopPerfectionPass());
        pm.addPass(scalehls::createAffineLoopOrderOptPass());
        pm.addPass(scalehls::createAffineLoopTilePass(opts.loopTileSize));
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 7)
          return;

        // Local buffer allocation.
        scalehls::addCreateSubviewPasses(pm);
        pm.addPass(scalehls::createCreateLocalBufferPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(memref::createFoldMemRefAliasOpsPass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 8)
          return;

        // Affine loop dataflowing.
        pm.addPass(scalehls::createCollapseMemrefUnitDimsPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createCreateDataflowFromAffinePass());
        pm.addPass(scalehls::createStreamDataflowTaskPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 9)
          return;

        // Lower and optimize dataflow.
        pm.addPass(scalehls::createLowerDataflowPass());
        pm.addPass(scalehls::createEliminateMultiProducerPass());
        pm.addPass(scalehls::createScheduleDataflowNodePass(
            /*ignoreViolations=*/true));
        pm.addPass(scalehls::createBalanceDataflowNodePass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 10)
          return;

        // Parallelize dataflow.
        if (opts.loopUnrollFactor) {
          pm.addPass(scalehls::createAffineLoopUnrollJamPass(
              opts.loopUnrollFactor, /*unrollPointLoopOnly=*/true));
          pm.addPass(mlir::createSimplifyAffineStructuresPass());
          pm.addPass(mlir::createCanonicalizerPass());
        }

        if (opts.debugPoint == 11)
          return;

        // Memory optimization.
        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 12)
          return;

        // Convert dataflow to func.
        pm.addPass(scalehls::createEliminateMultiConsumerDeprecatedPass());
        pm.addPass(scalehls::createCreateTokenStreamPass());
        pm.addPass(scalehls::createConvertDataflowToFuncPass());
        pm.addPass(mlir::createCanonicalizerPass());

        if (opts.debugPoint == 13)
          return;

        // Directive-level optimization.
        if (opts.axiInterface)
          pm.addPass(scalehls::createCreateAxiInterfacePass(opts.hlsTopFunc));
        pm.addPass(scalehls::createLoopPipeliningPass());
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSPrimitivePass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

void scalehls::registerTransformsPasses() {
  registerScaleHLSDSEPipeline();
  registerScaleFlowPyTorchPipeline();
  registerScaleFlowPyTorchPipelinePost();
  registerScaleHLSPyTorchPipeline();
  registerPasses();
}
