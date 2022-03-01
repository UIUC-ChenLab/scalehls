//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
#include "mlir/Dialect/StandardOps/Transforms/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "scalehls/Transforms/Passes.h.inc"
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
          pm.addPass(scalehls::createLegalizeDataflowPass(dataflowGran));
        pm.addPass(scalehls::createSplitFunctionPass());
        pm.addPass(tosa::createTosaToLinalgNamed());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(tosa::createTosaToLinalg());
        pm.addPass(tosa::createTosaToStandard());
        pm.addPass(scalehls::createCreateRuntimeMainPass(opts));

        // Lower graph to affine.
        pm.addPass(mlir::createLinalgGeneralizationPass());
        pm.addPass(mlir::createLinalgBufferizePass());
        pm.addPass(mlir::createFuncBufferizePass());
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
        pm.addPass(scalehls::createLegalizeToHLSCppPass(opts));
        pm.addPass(scalehls::createMaterializeReductionPass());
        if (loopUnrollSize) {
          pm.addPass(scalehls::createAffineLoopPerfectionPass());
          pm.addPass(scalehls::createRemoveVariableBoundPass());
          pm.addPass(
              scalehls::createAffineLoopUnrollAndPipelinePass(loopUnrollSize));
        }

        // Apply simplifications.
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
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSCppPrimitivePass());
      });
}

void scalehls::registerTransformsPasses() {
  registerScaleHLSPyTorchPipeline();
  registerPasses();
}
