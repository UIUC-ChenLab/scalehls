//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Arithmetic/Transforms/Passes.h"
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

  Option<double> fusionTolerance{
      *this, "fusion-tolerance", llvm::cl::init(100.0),
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

        // TOSA optimization.
        pm.addPass(scalehls::createTosaSimplifyGraphPass());
        pm.addPass(scalehls::createCreateDataflowFromTosaPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // TOSA to Linalg conversion.
        tosa::addTosaToLinalgPasses(pm);
        pm.addPass(scalehls::createTosaToLinalgCleanupPass());
        pm.addPass(tosa::createTosaToArith());
        pm.addPass(tosa::createTosaToTensor());
        pm.addPass(mlir::createLinalgGeneralizationPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Bufferization.
        pm.addPass(mlir::createLinalgBufferizePass());
        pm.addPass(arith::createArithmeticBufferizePass());
        pm.addPass(mlir::createTensorBufferizePass());
        pm.addPass(func::createFuncBufferizePass());
        pm.addPass(bufferization::createBufferResultsToOutParamsPass());
        pm.addPass(scalehls::createBufferizeDataflowPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Linalg to Affine conversion.
        pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
        pm.addPass(memref::createFoldMemRefAliasOpsPass());
        pm.addPass(scalehls::createSimplifyCopyPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Affine loop fusion.
        pm.addPass(scalehls::createAffineLoopFusionPass(opts.fusionTolerance));
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Post-fusion loop optimization.
        pm.addPass(scalehls::createRaiseAffineToCopyPass());
        pm.addPass(scalehls::createSimplifyCopyPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass());
        pm.addPass(mlir::createAffineScalarReplacementPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Place dataflow buffers.
        pm.addPass(scalehls::createPlaceDataflowBufferPass());

        // // Vectorization.
        // if (opts.vectorSize) {
        //   pm.addPass(mlir::createSuperVectorizePass({opts.vectorSize}));
        //   pm.addPass(mlir::createCanonicalizerPass());
        // }

        // Affine loop preprocess.
        pm.addPass(scalehls::createFuncPreprocessPass(opts.hlsTopFunc));
        pm.addPass(scalehls::createMaterializeReductionPass());
        pm.addPass(scalehls::createAffineLoopPerfectionPass());
        pm.addPass(scalehls::createRemoveVariableBoundPass());

        // Affine loop tiling.
        // pm.addPass(scalehls::createAffineLoopOrderOptPass());
        pm.addPass(scalehls::createAffineLoopTilePass(opts.loopTileSize));
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Local buffer allocation.
        pm.addPass(scalehls::createCreateMemrefSubviewPass());
        pm.addPass(mlir::createCSEPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createCreateLocalBufferPass());
        pm.addPass(scalehls::createLowerCopyToAffinePass(
            /*InternalCopyOnly=*/false));
        pm.addPass(memref::createFoldMemRefAliasOpsPass());
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Affine loop dataflowing.
        pm.addPass(scalehls::createCreateDataflowFromAffinePass());
        pm.addPass(scalehls::createStreamDataflowTaskPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Lower dataflow.
        pm.addPass(scalehls::createLowerDataflowPass());
        pm.addPass(scalehls::createEliminateMultiProducerPass());
        pm.addPass(scalehls::createScheduleDataflowNodePass());
        pm.addPass(scalehls::createBalanceDataflowNodePass());
        pm.addPass(scalehls::createLegalizeDataflowSchedulePass());
        pm.addPass(scalehls::createLowerCopyToAffinePass(
            /*InternalCopyOnly=*/false));
        pm.addPass(mlir::createCanonicalizerPass());

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
        pm.addPass(mlir::createAffineScalarReplacementPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createSimplifyMemrefAccessPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Convert dataflow to func.
        pm.addPass(scalehls::createCreateTokenStreamPass());
        pm.addPass(scalehls::createConvertDataflowToFuncPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Directive-level optimization.
        pm.addPass(scalehls::createCreateAxiInterfacePass(opts.hlsTopFunc));
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
  registerPasses();
}
