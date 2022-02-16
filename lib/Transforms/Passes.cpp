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
        pm.addPass(createLegalizeOnnxPass());
        pm.addPass(createAffineLoopNormalizePass());
        pm.addPass(createSimplifyAffineStructuresPass());
        pm.addPass(createCanonicalizerPass());

        pm.addPass(createLegalizeDataflowPass());
        pm.addPass(createSplitFunctionPass());
        pm.addPass(createConvertLinalgToAffineLoopsPass());
        pm.addPass(createCanonicalizerPass());

        pm.addPass(createMaterializeReductionPass());
        pm.addPass(createLegalizeToHLSCppPass(opts));
        pm.addPass(createPartialAffineLoopTilePass());
        pm.addPass(createSimplifyAffineIfPass());
        pm.addPass(createAffineStoreForwardPass());
        pm.addPass(createSimplifyMemrefAccessPass());
        pm.addPass(createArrayPartitionPass());

        pm.addPass(createReduceInitialIntervalPass());
        // pm.addPass(createCreateHLSCppPrimitivePass());
        pm.addPass(createCSEPass());
        pm.addPass(createCanonicalizerPass());
      });
}

void scalehls::registerTransformsPasses() {
  registerScaleHLSPassPipeline();
  registerPasses();
}
