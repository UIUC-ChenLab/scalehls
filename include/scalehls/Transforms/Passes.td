//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def DesignSpaceExplore : Pass<"scalehls-dse", "ModuleOp"> {
  let summary = "Optimize HLS design at multiple abstraction level";
  let description = [{
    This pass will automatically conduct the design space exploration (DSE)
    across multiple abstraction levels. By calling methods provided by
    qor-estimation, this pass is able to rapidly obtain the QoR estimation of
    the current design point, and feed it back to the DSE engine for an
    efficient optimization convergence.
  }];
  let constructor = "mlir::scalehls::createDesignSpaceExplorePass()";

  let options = [
    Option<"outputPath", "output-path", "std::string",
           /*default=*/"\"./\"",
           "File path: the path for dumping the MLIR of pareto design points">,
    Option<"csvPath", "csv-path", "std::string",
           /*default=*/"\"./\"",
           "File path: the path for dumping the CSV of design spaces">,

    Option<"targetSpec", "target-spec", "std::string",
           /*default=*/"\"./config.json\"",
           "File path: target backend specifications and configurations">
  ];
}

def FuncDuplication : Pass<"scalehls-func-duplication", "mlir::ModuleOp"> {
  let summary = "Duplicate function for each function call";
  let constructor = "mlir::scalehls::createFuncDuplicationPass()";
}

def FuncPreprocess : Pass<"scalehls-func-preprocess", "func::FuncOp"> {
  let summary = "Preprocess the functions subsequent ScaleHLS optimizations";
  let constructor = "mlir::scalehls::createFuncPreprocessPass()";

  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"main\"",
           "The top function for HLS synthesis">
  ];
}

//===----------------------------------------------------------------------===//
// Dataflow-related Passes
//===----------------------------------------------------------------------===//

def BalanceDataflowNode :
      Pass<"scalehls-balance-dataflow-node", "func::FuncOp"> {
  let summary = "Balance dataflow nodes";
  let constructor = "mlir::scalehls::createBalanceDataflowNodePass()";
}

def BufferizeDataflow : Pass<"scalehls-bufferize-dataflow", "func::FuncOp"> {
  let summary = "Bufferize dataflow operations";
  let constructor = "mlir::scalehls::createBufferizeDataflowPass()";
}

def ConvertDataflowToFunc :
      Pass<"scalehls-convert-dataflow-to-func", "ModuleOp"> {
  let summary = "Convert dataflow to function dialect";
  let constructor = "mlir::scalehls::createConvertDataflowToFuncPass()";
}

def CreateDataflowFromAffine :
      Pass<"scalehls-create-dataflow-from-affine", "func::FuncOp"> {
  let summary = "Create dataflow hierarchy from affine loops";
  let constructor = "mlir::scalehls::createCreateDataflowFromAffinePass()";
}

def CreateDataflowFromLinalg :
      Pass<"scalehls-create-dataflow-from-linalg", "func::FuncOp"> {
  let summary = "Create dataflow hierarchy from linalg";
  let constructor = "mlir::scalehls::createCreateDataflowFromLinalgPass()";
}

def CreateDataflowFromTosa :
      Pass<"scalehls-create-dataflow-from-tosa", "func::FuncOp"> {
  let summary = "Create dataflow hierarchy from tosa";
  let constructor = "mlir::scalehls::createCreateDataflowFromTosaPass()";
}

def CreateTokenStream : Pass<"scalehls-create-token-stream", "func::FuncOp"> {
  let summary = "Create token stream channels for DRAM buffers";
  let constructor = "mlir::scalehls::createCreateTokenStreamPass()";
}

def EliminateMultiProducer :
      Pass<"scalehls-eliminate-multi-producer", "func::FuncOp"> {
  let summary = "Try to eliminate multi-producer violations";
  let constructor = "mlir::scalehls::createEliminateMultiProducerPass()";
}

def LegalizeDataflowSchedule :
      Pass<"scalehls-legalize-dataflow-schedule", "func::FuncOp"> {
  let summary = "Legalize dataflow at node level";
  let description = [{
    This pass will legalize the dataflow to meet the single-producer and
    single-consumer requirements of the dataflow schedule.
  }];
  let constructor = "mlir::scalehls::createLegalizeDataflowSchedulePass()";
}

def LowerDataflow : Pass<"scalehls-lower-dataflow", "func::FuncOp"> {
  let summary = "Lower dataflow from task level to node level";
  let constructor = "mlir::scalehls::createLowerDataflowPass()";
}

def ParallelizeDataflowNode :
      Pass<"scalehls-parallelize-dataflow-node", "func::FuncOp"> {
  let summary = "Unroll affine loop nests based on the dataflow structure";
  let description = [{
    This pass calculates the overall loop unroll factor of each dataflow node
    based on the amount of associated computations. Then, unroll and jam from
    the outermost loop until the overall unroll factor reaches the caculated
    factor. Optionally, optimize the loop order after the unrolling.
  }];
  let constructor = "mlir::scalehls::createParallelizeDataflowNodePass()";

  let options = [
    Option<"maxUnrollFactor", "max-unroll-factor", "unsigned", /*default=*/"1",
           "Positive number: the maximum factor of unrolling">,
    Option<"pointLoopOnly", "point-loop-only", "bool", /*default=*/"false",
           "Only apply unroll and jam to point loop band">
  ];
}

def PlaceDataflowBuffer :
      Pass<"scalehls-place-dataflow-buffer", "func::FuncOp"> {
  let summary = "Place dataflow buffers";
  let constructor = "mlir::scalehls::createPlaceDataflowBufferPass()";

  let options = [
    Option<"placeExternalBuffer", "place-external-buffer", "bool",
           /*default=*/"true", "Place buffers in external buffers">
  ];
}

def ScheduleDataflowNode :
      Pass<"scalehls-schedule-dataflow-node", "func::FuncOp"> {
  let summary = "Schedule dataflow nodes";
  let constructor = "mlir::scalehls::createScheduleDataflowNodePass()";
}

def StreamDataflowTask : Pass<"scalehls-stream-dataflow-task", "func::FuncOp"> {
  let summary = "Stream dataflow tasks";
  let constructor = "mlir::scalehls::createStreamDataflowTaskPass()";
}

//===----------------------------------------------------------------------===//
// Tensor-related Passes
//===----------------------------------------------------------------------===//

def ConvertTensorToLinalg :
      Pass<"scalehls-convert-tensor-to-linalg", "func::FuncOp"> {
  let summary = "Lower tosa::ReshapeOp and tensor::PadOp";
  let constructor = "mlir::scalehls::createConvertTensorToLinalgPass()";
}

def LinalgFakeQuantize : Pass<"scalehls-linalg-fake-quantize", "ModuleOp"> {
  let summary = "Convert to quantized model (only for testing use)";
  let constructor = "mlir::scalehls::createLinalgFakeQuantizePass()";

  let options = [
    Option<"quanBits", "quan-bits", "unsigned", /*default=*/"8",
           "the number of bits for quantization">
  ];
}

def TosaFakeQuantize : Pass<"scalehls-tosa-fake-quantize", "ModuleOp"> {
  let summary = "Convert to 8-bits quantized model (only for testing use)";
  let constructor = "mlir::scalehls::createTosaFakeQuantizePass()";
}

def TosaSimplifyGraph : Pass<"scalehls-tosa-simplify-graph", "func::FuncOp"> {
  let summary = "Remove redundant TOSA operations";
  let description = [{
    This simplify-tosa-graph pass will try to remove redundant transpose ops
    through pattern matching.
  }];
  let constructor = "mlir::scalehls::createTosaSimplifyGraphPass()";
}

//===----------------------------------------------------------------------===//
// Loop-related Passes
//===----------------------------------------------------------------------===//

def AffineLoopFusion : Pass<"scalehls-affine-loop-fusion", "func::FuncOp"> {
  let summary = "Fuse affine loop nests";
  let description = [{
    This pass performs fusion of loop nests using a slicing-based approach. It
    combines two fusion strategies: producer-consumer fusion and sibling fusion.
    Producer-consumer fusion is aimed at fusing pairs of loops where the first
    one writes to a memref that the second reads. Sibling fusion targets pairs
    of loops that share no dependences between them but that load from the same
    memref. The fused loop nests, when possible, are rewritten to access
    significantly smaller local buffers instead of the original memref's, and
    the latter are often either completely optimized away or contracted. This
    transformation leads to enhanced locality and lower memory footprint through
    the elimination or contraction of temporaries/intermediate memref's. These
    benefits are sometimes achieved at the expense of redundant computation
    through a cost model that evaluates available choices such as the depth at
    which a source slice should be materialized in the designation slice.
  }];
  let constructor = "mlir::scalehls::createAffineLoopFusionPass()";

  let options = [
    Option<"computeToleranceThreshold", "fusion-compute-tolerance", "double",
           /*default=*/"0.30f", "Fractional increase in additional computation "
                                "tolerated while fusing">,
    Option<"fastMemorySpace", "fusion-fast-mem-space", "unsigned",
           /*default=*/"0",
           "Faster memory space number to promote fusion buffers to">,
    Option<"localBufSizeThreshold", "fusion-local-buf-threshold", "uint64_t",
           /*default=*/"0", "Threshold size (KiB) for promoting local buffers "
                            "to fast memory space">,
    Option<"maximalFusion", "fusion-maximal", "bool", /*default=*/"false",
           "Enables maximal loop fusion">,
    Option<"affineFusionMode", "mode", "enum AffineFusionMode",
           "AffineFusionMode::Greedy", "fusion mode to attempt",
           "llvm::cl::values(clEnumValN(AffineFusionMode::Greedy,"
           " \"greedy\", \"Perform greedy fusion\"), "
           "clEnumValN( AffineFusionMode::ProducerConsumer, "
           "\"producer\", \"Perform only producer-consumer fusion\"), "
           "clEnumValN( AffineFusionMode::Sibling, "
           "\"sibling\", \"Perform only sibling fusion\"))">,
    ];
}

def AffineLoopOrderOpt :
      Pass<"scalehls-affine-loop-order-opt", "func::FuncOp"> {
  let summary = "Optimize the order of affine loop nests";
  let description = [{
    This affine-loop-order-opt pass will optimize the order of perfect affine
    loop nests through polyhedral-based dependency analysis. The objective of
    this pass is to maximize the distance of loop-carried dependencies.
  }];
  let constructor = "mlir::scalehls::createAffineLoopOrderOptPass()";
}

def AffineLoopPerfection :
      Pass<"scalehls-affine-loop-perfection", "func::FuncOp"> {
  let summary = "Try to perfect a nested loop";
  let description = [{
    This affine-loop-perfection pass will try to perfect all affine loops.
    Specifically, this pass will move operations under non-innermost loops into
    innermost loop and create if statements to ensure the correctness of the
    transformation.
  }];
  let constructor = "mlir::scalehls::createAffineLoopPerfectionPass()";
}

def AffineLoopTile : Pass<"scalehls-affine-loop-tile", "func::FuncOp"> {
  let summary = "Tile affine loop nests and annotate point loops";
  let description = [{
    Apply the same "tile-size" to each affine loop in the nests.
  }];
  let constructor = "mlir::scalehls::createAffineLoopTilePass()";

  let options = [
    Option<"tileSize", "tile-size", "unsigned", /*default=*/"4",
           "Use this tile size for all loops">
  ];
}

def AffineLoopUnrollJam :
      Pass<"scalehls-affine-loop-unroll-jam", "func::FuncOp"> {
  let summary = "Unroll and jam affine loop nests";
  let description = [{
    Unroll and jam from the outermost loop until the overall unroll factor
    reaches the specified "unroll-factor". Optionally, optimize the loop order
    after the unrolling.
  }];
  let constructor = "mlir::scalehls::createAffineLoopUnrollJamPass()";

  let options = [
    Option<"unrollFactor", "unroll-factor", "unsigned", /*default=*/"1",
           "Positive number: the factor of unrolling">,
    Option<"pointLoopOnly", "point-loop-only", "bool", /*default=*/"false",
           "Only apply unroll and jam to point loop band">
  ];
}

def MaterializeReduction :
      Pass<"scalehls-materialize-reduction", "func::FuncOp"> {
  let summary = "Materialize loop reductions";
  let description = [{
    This materialize-reduction pass will materialize loop reductions with local
    buffer read/writes in order to expose more optimization opportunities
    targeting HLS.
  }];
  let constructor = "mlir::scalehls::createMaterializeReductionPass()";
}

def RemoveVariableBound :
      Pass<"scalehls-remove-variable-bound", "func::FuncOp"> {
  let summary = "Try to remove variable loop bounds";
  let description = [{
    This remove-variable-bound pass will try to remove the variable loop bounds.
    Specifically, this is only feasible when the loop bound is an affine
    expression of induction variables of other loops with constant lower and
    upper bound.
  }];
  let constructor = "mlir::scalehls::createRemoveVariableBoundPass()";
}

//===----------------------------------------------------------------------===//
// Memory-related Passes
//===----------------------------------------------------------------------===//

def AffineStoreForward : Pass<"scalehls-affine-store-forward", "func::FuncOp"> {
  let summary = "Forward store to load, including conditional stores";
  let description = [{
    This affine-store-forward pass is similar to scal-repl, but supports to
    forward stores located in if statements.
  }];
  let constructor = "mlir::scalehls::createAffineStoreForwardPass()";
}

def CreateLocalBuffer : Pass<"scalehls-create-local-buffer", "func::FuncOp"> {
  let summary = "Promote external buffer to on-chip buffer";
  let constructor = "mlir::scalehls::createCreateLocalBufferPass()";

  let options = [
    Option<"externalBufferOnly", "external-buffer-only", "bool",
           /*default=*/"true", "only handle external buffers">,
    Option<"registerOnly", "register-only", "bool",
           /*default=*/"false", "only registers or single-element buffers">
  ];
}

def CreateMemrefSubview :
      Pass<"scalehls-create-memref-subview", "func::FuncOp"> {
  let summary = "Create subviews based on loop analysis";
  let description = [{
    Through loop analysis, this pass can identify the memory partition that each
    sub-function is accessing. Then, by creating subview operations, the program
    in each sub-function can access the memory subview rather than the original
    memory.
  }];
  let constructor = "mlir::scalehls::createCreateMemrefSubviewPass()";

  let options = [
    Option<"createSubviewMode", "mode", "enum CreateSubviewMode",
           /*default=*/"CreateSubviewMode::Point",
           "loop band mode to create subviews", "llvm::cl::values("
           "clEnumValN(CreateSubviewMode::Point, \"point\", "
           "\"Create subviews on point loop band\"), "
           "clEnumValN(CreateSubviewMode::Reduction, \"reduction\", "
           "\"Create subviews on reduction loop band\"))">
  ];
}

def LowerCopyToAffine : Pass<"scalehls-lower-copy-to-affine", "func::FuncOp"> {
  let summary = "Convert copy and assign to affine loops";
  let constructor = "mlir::scalehls::createLowerCopyToAffinePass()";

  let options = [
    Option<"internalCopyOnly", "internal-copy-only", "bool", /*default=*/"false",
           "only convert copy between internal buffers">
  ];
}

def RaiseAffineToCopy : Pass<"scalehls-raise-affine-to-copy", "func::FuncOp"> {
  let summary = "Raise copy in affine loops to memref.copy";
  let constructor = "mlir::scalehls::createRaiseAffineToCopyPass()";
}

def ReduceInitialInterval :
      Pass<"scalehls-reduce-initial-interval", "func::FuncOp"> {
  let summary = "Try to reduce the intiail interval";
  let description = [{
    This reduce-initial-interval pass try to reduce the II by optimizing the
    commutative operator trees and iteration variables.
  }];
  let constructor = "mlir::scalehls::createReduceInitialIntervalPass()";
}

def SimplifyAffineIf : Pass<"scalehls-simplify-affine-if", "func::FuncOp"> {
  let summary = "Simplify affine if operations";
  let description = [{
    This simplify-affine-if pass will eliminate all redundant affine if
    operations which will always take then or else branch, and merge all affine
    if operations that having the same statement.
  }];
  let constructor = "mlir::scalehls::createSimplifyAffineIfPass()";
}

def SimplifyCopy : Pass<"scalehls-simplify-copy", "func::FuncOp"> {
  let summary = "Simplify memref copy ops";
  let constructor = "mlir::scalehls::createSimplifyCopyPass()";
}

//===----------------------------------------------------------------------===//
// Directive-related Passes
//===----------------------------------------------------------------------===//

def ArrayPartition : Pass<"scalehls-array-partition", "ModuleOp"> {
  let summary = "Apply optimized array partition strategy";
  let description = [{
    This array-partition pass will automatically search for the best array
    partition solution for each on-chip memory instance and apply the solution
    through changing the layout of the corresponding memref.
  }];
  let constructor = "mlir::scalehls::createArrayPartitionPass()";
}

def CreateHLSPrimitive : Pass<"scalehls-create-hls-primitive", "func::FuncOp"> {
  let summary = "Create HLS C++ multiplification primitives";
  let description = [{
    This create-hls-primitive pass will convert 8-bits multiplifications to HLS
    C++ primitives in order to utilize DSP instances in FPGA.
  }];
  let constructor = "mlir::scalehls::createCreateHLSPrimitivePass()";
}

def CreateAxiInterface : Pass<"scalehls-create-axi-interface", "ModuleOp"> {
  let summary = "Create AXI interfaces for the top function";
  let description = [{
    This create-runtime-main pass will create a new "main" function calling the
    original top function. All constant tensors are instantiated in the new
    "main" function and passed into the original top function as arguments after
    the transform.
  }];
  let constructor = "mlir::scalehls::createCreateAxiInterfacePass()";

  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"main\"",
           "The top function for HLS synthesis">
  ];
}

def FuncPipelining : Pass<"scalehls-func-pipelining", "func::FuncOp"> {
  let summary = "Apply function pipelining";
  let description = [{
    This func-pipelining pass will insert pipeline pragma to the specified
    function, all contained loops will be automatically unrolled.
  }];
  let constructor = "mlir::scalehls::createFuncPipeliningPass()";

  let options = [
    Option<"targetFunc", "target-func", "std::string",
           /*default=*/"\"main\"", "The target function to be pipelined">,
    Option<"targetII", "target-ii", "unsigned", /*default=*/"1",
           "Positive number: the targeted II to achieve">
  ];
}

def LoopPipelining : Pass<"scalehls-loop-pipelining", "func::FuncOp"> {
  let summary = "Apply loop pipelining";
  let description = [{
    This loop-pipelining pass will insert pipeline pragma to the target loop
    level, and automatically unroll all inner loops.
  }];
  let constructor = "mlir::scalehls::createLoopPipeliningPass()";

  let options = [
    Option<"pipelineLevel", "pipeline-level", "unsigned", /*default=*/"0",
           "Positive number: loop level to be pipelined (from innermost)">,
    Option<"targetII", "target-ii", "unsigned", /*default=*/"1",
           "Positive number: the targeted II to achieve">
  ];
}

def QoREstimation : Pass<"scalehls-qor-estimation", "ModuleOp"> {
  let summary = "Estimate the performance and resource utilization";
  let description = [{
    This qor-estimation pass will analyze the input IR and estimate the latency
    and resource utilization of HLS C++ synthesis. This pass will take all
    dependency and resource constraints and pragma settings into consideration,
    and conduct the estimation through an ALAP scheduling.
  }];
  let constructor = "mlir::scalehls::createQoREstimationPass()";

  let options = [
    Option<"targetSpec", "target-spec", "std::string",
           /*default=*/"\"./config.json\"",
           "File path: target backend specifications and configurations">
  ];
}

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
