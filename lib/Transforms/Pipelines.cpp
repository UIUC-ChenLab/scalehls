//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Pipelines.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Arith/Transforms/Passes.h"
#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
#include "mlir/Dialect/Tensor/Transforms/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace bufferization;
using namespace scalehls;

static void addComprehensiveBufferizePasses(OpPassManager &pm) {
  pm.addPass(scalehls::createComprehensiveBufferizePass());
  pm.addPass(memref::createResolveShapedTypeResultDimsPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(mlir::createCSEPass());
  // There are redundant memcpy (with linalg.generic form) ops created, which
  // can be deleted by canonicalizer. We have to run it again because the
  // memrefs are unified in CSE pass, so we can truely remove redundant memcpy.
  pm.addPass(mlir::createCanonicalizerPass());
}

static void addLowerLinalgToAffinePasses(OpPassManager &pm) {
  pm.addPass(mlir::createConvertLinalgToAffineLoopsPass());
  pm.addPass(memref::createFoldMemRefAliasOpsPass());
  pm.addPass(affine::createAffineLoopNormalizePass());
  pm.addPass(affine::createSimplifyAffineStructuresPass());
  pm.addPass(mlir::createCanonicalizerPass());
}

namespace {
struct ScaleHLSPyTorchPipelineOptions
    : public PassPipelineOptions<ScaleHLSPyTorchPipelineOptions> {};
} // namespace

void scalehls::registerScaleHLSPyTorchPipeline() {
  PassPipelineRegistration<ScaleHLSPyTorchPipelineOptions>(
      "scalehls-pytorch-pipeline",
      "Compile from Torch-MLIR (Linalg) to HLS C++",
      [](OpPassManager &pm, const ScaleHLSPyTorchPipelineOptions &opts) {
        // Linalg-level transformation.
        pm.addPass(mlir::createConvertTensorToLinalgPass());
        pm.addPass(mlir::createLinalgElementwiseOpFusionPass());
        pm.addPass(bufferization::createEmptyTensorEliminationPass());

        // FDF-level transformation.
        pm.addPass(scalehls::createConvertLinalgToFDFPass());
        pm.addPass(hls::createParametricTaskTilingPass(32));
        addComprehensiveBufferizePasses(pm);
        pm.addPass(hls::createEliminateBufferYieldPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // SDF-level transformation.
        pm.addPass(scalehls::createConvertFDFToSDFPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Func-level transformation.
        pm.addPass(scalehls::createConvertSDFToFuncPass());
        pm.addPass(scalehls::createGenerateRuntimeFuncPass());
        addLowerLinalgToAffinePasses(pm);
      });
}

void scalehls::registerScaleHLSPipelines() {
  registerScaleHLSPyTorchPipeline();
}
