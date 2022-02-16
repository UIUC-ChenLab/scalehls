//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
#include "scalehls/Conversion/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "scalehls/Transforms/Passes.h.inc"
} // namespace

void scalehls::registerScaleHLSPassPipeline() {
  PassPipelineRegistration<ScaleHLSOptions>(
      "scalehls-pipeline", "Compile to HLS C++",
      [](OpPassManager &pm, const ScaleHLSOptions &opts) {
        pm.addPass(scalehls::createLegalizeOnnxPass());
        pm.addPass(mlir::createAffineLoopNormalizePass());
        pm.addPass(mlir::createSimplifyAffineStructuresPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Graph-level optimizations.
        pm.addPass(scalehls::createLegalizeDataflowPass(opts));
        pm.addPass(scalehls::createSplitFunctionPass());
        pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Loop-level optimizations.
        pm.addPass(scalehls::createMaterializeReductionPass());
        if (opts.vecSize != 1)
          pm.addPass(mlir::createSuperVectorizePass({opts.vecSize}));
        pm.addPass(scalehls::createAffineLoopPerfectionPass());
        pm.addPass(scalehls::createPartialAffineLoopTilePass(opts));
        pm.addPass(mlir::createCanonicalizerPass());

        // Simplifications.
        pm.addPass(scalehls::createSimplifyAffineIfPass());
        pm.addPass(scalehls::createAffineStoreForwardPass());
        pm.addPass(scalehls::createSimplifyMemrefAccessPass());
        pm.addPass(scalehls::createReduceInitialIntervalPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Directive-level optimizations.
        pm.addPass(scalehls::createLegalizeToHLSCppPass(opts));
        pm.addPass(scalehls::createArrayPartitionPass());
        pm.addPass(scalehls::createCreateHLSCppPrimitivePass());
        pm.addPass(mlir::createCSEPass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

void scalehls::registerTransformsPasses() {
  registerScaleHLSPassPipeline();
  registerPasses();
}
