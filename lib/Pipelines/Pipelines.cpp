//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Pipelines/Pipelines.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Arith/Transforms/Passes.h"
#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Dialect/MemRef/Transforms/Passes.h"
#include "mlir/Dialect/SCF/Transforms/Passes.h"
#include "mlir/Dialect/Tensor/Transforms/Passes.h"
#include "mlir/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace bufferization;
using namespace scalehls;
using namespace hls;

void scalehls::addLinalgTransformPasses(OpPassManager &pm) {
  pm.addPass(mlir::createConvertTensorToLinalgPass());
  pm.addPass(mlir::createLinalgGeneralizationPass());
  pm.addPass(mlir::createLinalgElementwiseOpFusionPass());
  pm.addPass(mlir::createLinalgFoldUnitExtentDimsPass());
  pm.addPass(bufferization::createEmptyTensorEliminationPass());
  pm.addPass(mlir::createLinalgInlineScalarOperandsPass());
  pm.addNestedPass<func::FuncOp>(hls::createPreprocessPass());
  pm.addPass(mlir::createCSEPass());
  pm.addPass(mlir::createCanonicalizerPass());
}

void scalehls::addComprehensiveBufferizePasses(OpPassManager &pm) {
  pm.addPass(hls::createComprehensiveBufferizePass());
  pm.addPass(memref::createResolveShapedTypeResultDimsPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(mlir::createCSEPass());
  pm.addPass(mlir::createCanonicalizerPass());
}

void scalehls::addConvertDataflowToFuncPasses(OpPassManager &pm) {
  pm.addNestedPass<func::FuncOp>(hls::createStripStreamIterInfoPass());
  pm.addPass(hls::createRaiseSCFToAffinePass());
  pm.addNestedPass<func::FuncOp>(mlir::createConvertLinalgToAffineLoopsPass());
  pm.addNestedPass<func::FuncOp>(affine::createAffineLoopNormalizePass());
  pm.addNestedPass<func::FuncOp>(affine::createSimplifyAffineStructuresPass());
  pm.addPass(memref::createFoldMemRefAliasOpsPass());
  pm.addPass(hls::createConvertDataflowToFuncPass());
  pm.addPass(hls::createGenerateRuntimeFuncPass());
  pm.addPass(mlir::createCSEPass());
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
        addComprehensiveBufferizePasses(pm);
        pm.addNestedPass<func::FuncOp>(hls::createScheduleDataflowPass());
        pm.addPass(mlir::createCanonicalizerPass());
        addConvertDataflowToFuncPasses(pm);
      });
}

void scalehls::registerScaleHLSPipelines() {
  registerScaleHLSPyTorchPipeline();
}
