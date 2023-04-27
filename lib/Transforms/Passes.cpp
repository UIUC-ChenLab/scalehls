//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Arith/Transforms/Passes.h"
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
struct ScaleFlowPyTorchPipelineOptions
    : public PassPipelineOptions<ScaleFlowPyTorchPipelineOptions> {
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
      llvm::cl::desc("Additional computation tolerated while loop fusing "
                     "(default is 100.0)")};

  Option<unsigned> loopTileSize{
      *this, "loop-tile-size", llvm::cl::init(2),
      llvm::cl::desc("The tile size of each loop (must larger equal to 1)")};

  Option<unsigned> loopUnrollFactor{
      *this, "loop-unroll-factor", llvm::cl::init(0),
      llvm::cl::desc("The overall loop unrolling factor (set 0 to disable)")};

  Option<bool> complexityAware{
      *this, "complexity-aware", llvm::cl::init(true),
      llvm::cl::desc("Whether to consider node complexity in the transform")};

  Option<bool> correlationAware{
      *this, "correlation-aware", llvm::cl::init(true),
      llvm::cl::desc("Whether to consider node correlation in the transform")};

  Option<unsigned> externalBufferThreshold{
      *this, "external-buffer-threshold", llvm::cl::init(1024),
      llvm::cl::desc("The threshold of placing external buffers")};

  Option<bool> placeExternalBuffer{
      *this, "place-external-buffer", llvm::cl::init(true),
      llvm::cl::desc("Place buffers in external memories")};

  Option<bool> balanceDataflow{
      *this, "balance-dataflow", llvm::cl::init(true),
      llvm::cl::desc("Whether to balance the dataflow")};

  Option<bool> axiInterface{*this, "axi-interface", llvm::cl::init(true),
                            llvm::cl::desc("Create AXI interface")};

  Option<bool> vectorize{*this, "vectorize", llvm::cl::init(false),
                         llvm::cl::desc("Vectorize with factor of 2")};

  Option<bool> tosaInput{*this, "tosa-input", llvm::cl::init(false),
                         llvm::cl::desc("Inidicate the input IR is TOSA")};

  Option<bool> fakeQuantize{
      *this, "fake-quantize", llvm::cl::init(false),
      llvm::cl::desc("Trigger the fake quantization (just for testing use)")};

  Option<unsigned> debugPoint{
      *this, "debug-point", llvm::cl::init(0),
      llvm::cl::desc("Stop the pipeline at the given debug point")};
};
} // namespace

void scalehls::registerScaleFlowPyTorchPipeline() {
  PassPipelineRegistration<ScaleFlowPyTorchPipelineOptions>(
      "scaleflow-pytorch-pipeline",
      "Compile TOSA (from Torch-MLIR) to HLS C++ with ScaleFlow",
      [](OpPassManager &pm, const ScaleFlowPyTorchPipelineOptions &opts) {});
}

void scalehls::registerTransformsPasses() {
  registerScaleFlowPyTorchPipeline();
  registerPasses();
}
