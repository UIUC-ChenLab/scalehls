//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/StandardOps/Transforms/Passes.h"
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
        unsigned dataflowGran = 0;
        unsigned loopTileSize = 0;
        unsigned vectorSize = 0;

        if (opts.optLevel > 0 && opts.optLevel < 8) {
          dataflowGran = 9 - opts.optLevel;
          loopTileSize = 1 << opts.optLevel;
        }

        if (opts.dataflowGran.hasValue())
          dataflowGran = opts.dataflowGran;
        if (opts.loopTileSize.hasValue())
          loopTileSize = opts.loopTileSize;
        if (opts.vectorSize.hasValue())
          vectorSize = opts.vectorSize;

        // Adapt the model from torch-mlir or onnx-mlir front-end.
        if (opts.frontend == "torch") {
          pm.addPass(mlir::createLinalgGeneralizationPass());
          pm.addPass(mlir::createLinalgBufferizePass());
          pm.addPass(mlir::createFuncBufferizePass());
          pm.addPass(mlir::createCanonicalizerPass());
        } else if (opts.frontend == "onnx") {
          pm.addPass(scalehls::createLegalizeOnnxPass());
          pm.addPass(mlir::createAffineLoopNormalizePass());
          pm.addPass(mlir::createSimplifyAffineStructuresPass());
          pm.addPass(mlir::createCanonicalizerPass());
        } else
          llvm_unreachable("please use support front-end: torch or onnx.");

        // Graph-level optimizations.
        if (dataflowGran) {
          pm.addPass(scalehls::createLegalizeDataflowPass(dataflowGran));
          pm.addPass(scalehls::createSplitFunctionPass());
          pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
          pm.addPass(mlir::createCanonicalizerPass());
        }

        // Loop-level optimizations. Loop pipelining is included.
        if (vectorSize)
          pm.addPass(mlir::createSuperVectorizePass({vectorSize}));
        pm.addPass(scalehls::createLegalizeToHLSCppPass(opts));
        pm.addPass(scalehls::createMaterializeReductionPass());
        if (loopTileSize) {
          pm.addPass(scalehls::createAffineLoopPerfectionPass());
          pm.addPass(scalehls::createRemoveVariableBoundPass());
          pm.addPass(scalehls::createPartialAffineLoopTilePass(loopTileSize));
          pm.addPass(mlir::createCanonicalizerPass());
        }

        // Simplifications.
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
  registerScaleHLSPassPipeline();
  registerPasses();
}
