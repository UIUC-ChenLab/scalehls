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
  PassPipelineRegistration<ScaleHLSOptions>(
      "scalehls-pytorch-pipeline", "Compile TOSA (from Torch-MLIR) to HLS C++",
      [](OpPassManager &pm, const ScaleHLSOptions &opts) {
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

        // Graph-level optimizations.
        if (dataflowGran) {
          pm.addPass(scalehls::createSimplifyTosaGraphPass());
          pm.addPass(scalehls::createLegalizeDataflowPass(dataflowGran));
        }
        pm.addPass(scalehls::createSplitFunctionPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Lower graph to affine.
        pm.addPass(tosa::createTosaToLinalgNamed());
        pm.addPass(tosa::createTosaToLinalg());
        pm.addPass(tosa::createTosaToStandard());
        pm.addPass(mlir::createLinalgGeneralizationPass());
        pm.addPass(mlir::createLinalgBufferizePass());
        pm.addPass(mlir::createFuncBufferizePass());
        pm.addPass(bufferization::createBufferResultsToOutParamsPass());
        pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
        pm.addPass(scalehls::createConvertCopyToAffineLoopsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Loop-level optimizations.
        if (vectorSize) {
          pm.addPass(mlir::createSuperVectorizePass({vectorSize}));
        }
        pm.addPass(memref::createFoldSubViewOpsPass());
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(scalehls::createLegalizeToHLSCppPass(opts));
        pm.addPass(scalehls::createMaterializeReductionPass());
        if (loopUnrollSize) {
          pm.addPass(scalehls::createAffineLoopPerfectionPass());
          pm.addPass(scalehls::createRemoveVariableBoundPass());
          pm.addPass(
              scalehls::createAffineLoopUnrollAndPipelinePass(loopUnrollSize));
          pm.addPass(mlir::createCanonicalizerPass());
        }

        // Memory accessing simplifications.
        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createSimplifyMemrefAccessPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Directive-level optimizations.
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSCppPrimitivePass());
        pm.addPass(mlir::createCSEPass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

void scalehls::registerTransformsPasses() {
  registerScaleHLSPyTorchPipeline();
  registerPasses();
}
