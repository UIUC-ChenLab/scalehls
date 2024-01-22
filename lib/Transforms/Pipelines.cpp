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
#include "mlir/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace bufferization;
using namespace scalehls;

void scalehls::addLinalgTransformPasses(OpPassManager &pm) {
  pm.addPass(mlir::createConvertTensorToLinalgPass());
  pm.addPass(mlir::createLinalgGeneralizationPass());
  pm.addPass(mlir::createLinalgElementwiseOpFusionPass());
  pm.addPass(mlir::createLinalgFoldUnitExtentDimsPass());
  pm.addPass(bufferization::createEmptyTensorEliminationPass());
  pm.addPass(mlir::createLinalgInlineScalarOperandsPass());
  pm.addPass(mlir::createCSEPass());
  pm.addNestedPass<func::FuncOp>(hls::createPreprocessDataflowPass());
  pm.addPass(mlir::createCanonicalizerPass());
}

void scalehls::addCreateDataflowPasses(OpPassManager &pm) {
  pm.addNestedPass<func::FuncOp>(hls::createCreateDataflowPass());
  pm.addPass(mlir::createCanonicalizerPass());
}

void scalehls::addComprehensiveBufferizePasses(OpPassManager &pm) {
  pm.addPass(scalehls::createComprehensiveBufferizePass());
  pm.addPass(memref::createResolveShapedTypeResultDimsPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(mlir::createCSEPass());
  // There are redundant memcpy (with linalg.generic form) ops created, which
  // can be deleted by canonicalizer. We have to run it again because the
  // memrefs are unified in CSE pass, so we can truely remove redundant memcpy.
  pm.addPass(mlir::createCanonicalizerPass());
}

void scalehls::addLowerDataflowPasses(OpPassManager &pm) {
  pm.addNestedPass<func::FuncOp>(hls::createLowerDataflowPass());
  pm.addPass(mlir::createCanonicalizerPass());
}

void scalehls::addConvertDataflowToFuncPasses(OpPassManager &pm) {
  pm.addPass(hls::createConvertDataflowToFuncPass());
  pm.addPass(scalehls::createGenerateRuntimeFuncPass());
  // Lower linalg to affine loops.
  pm.addNestedPass<func::FuncOp>(mlir::createConvertLinalgToAffineLoopsPass());
  pm.addNestedPass<func::FuncOp>(scalehls::createLowerCopyToAffineLoopsPass());
  pm.addPass(memref::createFoldMemRefAliasOpsPass());
  pm.addNestedPass<func::FuncOp>(affine::createAffineLoopNormalizePass());
  pm.addNestedPass<func::FuncOp>(affine::createSimplifyAffineStructuresPass());
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
        addLinalgTransformPasses(pm);
        addCreateDataflowPasses(pm);
        addComprehensiveBufferizePasses(pm);
        addLowerDataflowPasses(pm);
        addConvertDataflowToFuncPasses(pm);
      });
}

void scalehls::registerScaleHLSPipelines() {
  registerScaleHLSPyTorchPipeline();
}
