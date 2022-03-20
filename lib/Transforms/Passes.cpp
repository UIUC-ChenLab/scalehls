//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Func/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
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

  Option<bool> hlsAxiInterf{
      *this, "axi-interf", llvm::cl::init(false),
      llvm::cl::desc("Whether to create AXI interfaces for the top function")};

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
        pm.addPass(scalehls::createLegalizeToHLSCppPass(opts.hlsTopFunc));
        if (opts.hlsAxiInterf)
          pm.addPass(scalehls::createCreateAxiInterfacePass());

        // We first run several passes to simplify the input program.
        pm.addPass(scalehls::createPromoteBufferPass());
        pm.addPass(scalehls::createMaterializeReductionPass());
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());
        pm.addPass(mlir::createLoopFusionPass());
        pm.addPass(mlir::createAffineScalarReplacementPass());

        // Apply the automatic design space exploration to the top function.
        pm.addPass(scalehls::createMultipleLevelDSEPass(opts.dseTargetSpec));

        // If AXI interfaces are created, we need to dataflow the program to
        // hide the latency of data load/store from/to external memories.
        if (opts.hlsAxiInterf) {
          pm.addPass(scalehls::createFuncDataflowPass(
              /*dataflowGran=*/(unsigned)1, /*dataflowInsertCopy=*/false));
          pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());
        }

        // Finally, estimate the QoR of the DSE result.
        pm.addPass(scalehls::createQoREstimationPass(opts.dseTargetSpec));
      });
}

namespace {
struct ScaleHLSPyTorchPipelineOptions
    : public PassPipelineOptions<ScaleHLSPyTorchPipelineOptions> {
  Option<std::string> hlsTopFunc{
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

  Option<bool> fakeQuantize{
      *this, "fake-quantize", llvm::cl::init(false),
      llvm::cl::desc("Trigger the fake quantization (just for testing use)")};
};
} // namespace

void scalehls::registerScaleHLSPyTorchPipeline() {
  PassPipelineRegistration<ScaleHLSPyTorchPipelineOptions>(
      "scalehls-pytorch-pipeline", "Compile TOSA (from Torch-MLIR) to HLS C++",
      [](OpPassManager &pm, const ScaleHLSPyTorchPipelineOptions &opts) {
        unsigned dataflowGran = 0;
        unsigned loopUnrollSize = 0;
        unsigned vectorSize = 0;

        if (opts.optLevel > 0 && opts.optLevel < 8) {
          dataflowGran = 9 - opts.optLevel;
          loopUnrollSize = 1 << opts.optLevel;
        }

        if (opts.dataflowGran.hasValue())
          dataflowGran = opts.dataflowGran;
        if (opts.loopUnrollSize.hasValue())
          loopUnrollSize = opts.loopUnrollSize;
        if (opts.vectorSize.hasValue())
          vectorSize = opts.vectorSize;

        if (opts.fakeQuantize)
          pm.addPass(scalehls::createFakeQuantizePass());

        // Graph-level optimizations.
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createSimplifyTosaGraphPass());
        if (dataflowGran)
          pm.addPass(scalehls::createFuncDataflowPass(dataflowGran));
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(tosa::createTosaToLinalgNamed());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createTosaToLinalgCleanupPass());
        pm.addPass(tosa::createTosaToLinalg());
        pm.addPass(tosa::createTosaToStandard());

        // Create runtime main function.
        pm.addPass(scalehls::createCreateRuntimeMainPass(opts.hlsTopFunc));

        // Lower graph to affine.
        pm.addPass(mlir::createLinalgGeneralizationPass());
        pm.addPass(mlir::createLinalgBufferizePass());
        pm.addPass(func::createFuncBufferizePass());
        pm.addPass(bufferization::createBufferResultsToOutParamsPass());
        pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());

        // Loop-level optimizations.
        pm.addPass(memref::createFoldSubViewOpsPass());
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());
        if (vectorSize) {
          pm.addPass(mlir::createSuperVectorizePass({vectorSize}));
          pm.addPass(mlir::createCanonicalizerPass());
        }
        pm.addPass(scalehls::createLegalizeToHLSCppPass(opts.hlsTopFunc));
        pm.addPass(scalehls::createMaterializeReductionPass());
        if (loopUnrollSize) {
          pm.addPass(scalehls::createAffineLoopPerfectionPass());
          pm.addPass(scalehls::createRemoveVariableBoundPass());
          pm.addPass(scalehls::createAffineLoopUnrollJamPass(loopUnrollSize));
        }

        // Apply memory optimizations.
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createSimplifyMemrefAccessPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());

        // Directive-level optimizations.
        pm.addPass(mlir::createCSEPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createLoopPipeliningPass());
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSCppPrimitivePass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

namespace {
struct ScaleHLSTestPipelineOptions
    : public PassPipelineOptions<ScaleHLSTestPipelineOptions> {
  Option<std::string> hlsTopFunc{
      *this, "top-func", llvm::cl::init("main"),
      llvm::cl::desc("Specify the top function of the design")};

  Option<bool> hlsAxiInterf{
      *this, "axi-interf", llvm::cl::init(false),
      llvm::cl::desc("Whether to create AXI interfaces for the top function")};

  Option<unsigned> loopTileSize{*this, "loop-tile-size", llvm::cl::init(1),
                                llvm::cl::desc("The size of loop tiling")};

  Option<unsigned> loopUnrollFactor{
      *this, "loop-unroll-factor", llvm::cl::init(1),
      llvm::cl::desc("The overall loop unrolling factor")};
};
} // namespace

void scalehls::registerScaleHLSTestPipeline() {
  PassPipelineRegistration<ScaleHLSTestPipelineOptions>(
      "scalehls-test-pipeline",
      "Launch design space exploration for C/C++ kernel",
      [](OpPassManager &pm, const ScaleHLSTestPipelineOptions &opts) {
        pm.addPass(scalehls::createLegalizeToHLSCppPass(opts.hlsTopFunc));
        if (opts.hlsAxiInterf)
          pm.addPass(scalehls::createCreateAxiInterfacePass());
        pm.addPass(scalehls::createMaterializeReductionPass());
        pm.addPass(scalehls::createAffineLoopPerfectionPass());
        pm.addPass(scalehls::createRemoveVariableBoundPass());

        pm.addPass(scalehls::createAffineLoopTilePass(opts.loopTileSize));
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createAffineLoopOrderOptPass());

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

        pm.addPass(scalehls::createAffineLoopUnrollJamPass(
            opts.loopUnrollFactor, /*unrollPointLoopOnly=*/true));
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createSimplifyMemrefAccessPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());

        pm.addPass(scalehls::createLoopPipeliningPass());
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createAffineLoopDataflowPass(
            /*dataflowGran=*/1, /*dataflowBalance=*/false));
      });
}

void scalehls::registerTransformsPasses() {
  registerScaleHLSDSEPipeline();
  registerScaleHLSPyTorchPipeline();
  registerScaleHLSTestPipeline();
  registerPasses();
}
