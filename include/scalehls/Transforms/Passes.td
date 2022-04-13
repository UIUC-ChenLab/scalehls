//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// Design Space Exploration Pass
//===----------------------------------------------------------------------===//

def DesignSpaceExplore : Pass<"scalehls-dse", "ModuleOp"> {
  let summary = "Optimize HLS design at multiple abstraction level";
  let description = [{
    This dse pass will automatically conduct the design space exploration (DSE)
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
           "File path: target backend specifications and configurations">,
    Option<"forSharedFuncs", "for-shared-funcs", "bool", /*default=*/"false",
           "Apply DSE to all shared functions">
  ];
}

//===----------------------------------------------------------------------===//
// Graph Optimization Passes
//===----------------------------------------------------------------------===//

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

def TosaNodeFusion : Pass<"scalehls-tosa-node-fusion", "func::FuncOp"> {
  let summary = "Node fusion on TOSA operations";
  let constructor = "mlir::scalehls::createTosaNodeFusionPass()";
}

def CreateFuncDataflow : Pass<"scalehls-create-func-dataflow", "func::FuncOp"> {
  let summary = "Create dataflow hierarchy to functions";
  let constructor = "mlir::scalehls::createCreateFuncDataflowPass()";
}

def CreateLoopDataflow : Pass<"scalehls-create-loop-dataflow", "func::FuncOp"> {
  let summary = "Create dataflow hierarchy to affine loops";
  let constructor = "mlir::scalehls::createCreateLoopDataflowPass()";
}

def LegalizeDataflow : Pass<"scalehls-legalize-dataflow", "func::FuncOp"> {
  let summary = "Legalize dataflow to a one-way feed-forward path";
  let description = [{
    This legalize-dataflow pass will legalize the dataflow scheduling to meet
    the requirements of the dataflow pragma: 1) single-producer single-consumer;
    2) no bypass paths. Then, it will fuse operations/loops scheduled at the
    same dataflow level into one dataflow node and apply the dataflow directive.
  }];
  let constructor = "mlir::scalehls::createLegalizeDataflowPass()";
}

def CreateTokenDepends : Pass<"scalehls-create-token-depends", "func::FuncOp"> {
  let summary = "Create token dependencies based on the dataflow";
  let description = [{
    This create-token-depends pass will create a token flow to represent the
    dependency graph of the original dataflow.
  }];
  let constructor = "mlir::scalehls::createCreateTokenDependsPass()";
}

def BufferizeDataflow : Pass<"scalehls-bufferize-dataflow", "func::FuncOp"> {
  let summary = "Bufferize tensor and scalar to memref and stream";
  let constructor = "mlir::scalehls::createBufferizeDataflowPass()";
}

def ConvertDataflowToFunc :
      Pass<"scalehls-convert-dataflow-to-func", "ModuleOp"> {
  let summary = "Convert dataflow to function dialect";
  let constructor = "mlir::scalehls::createConvertDataflowToFuncPass()";
}

def TosaToLinalgCleanup :
      Pass<"scalehls-tosa-to-linalg-cleanup", "func::FuncOp"> {
  let summary = "Lower tosa::ReshapeOp and tensor::PadOp";
  let constructor = "mlir::scalehls::createTosaToLinalgCleanupPass()";
}

def ShareTensorOperation : Pass<"share-tensor-operation", "ModuleOp"> {
  let summary = "Share kernels for repetitive tensor operations";
  let description = [{
    This share-tensor-operation pass will analyze all tensor operations to see 
    if there are any operations with exact same computation, and make them call 
    a single function so that the operation is only instantiated once. 
  }];

  let constructor = "mlir::scalehls::createShareTensorOperationPass()";
}

//===----------------------------------------------------------------------===//
// Runtime-related Passes
//===----------------------------------------------------------------------===//

def CreateRuntimeMain : Pass<"scalehls-create-runtime-main", "ModuleOp"> {
  let summary = "Create the main function of runtime";
  let description = [{
    This create-runtime-main pass will create a new "main" function calling the
    original top function. All constant tensors are instantiated in the new
    "main" function and passed into the original top function as arguments after
    the transform.
  }];
  let constructor = "mlir::scalehls::createCreateRuntimeMainPass()";

  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"main\"",
           "The top function for HLS synthesis">
  ];
}

def CreateAxiInterface : Pass<"scalehls-create-axi-interface", "ModuleOp"> {
  let summary = "Create AXI interfaces for the top function";
  let constructor = "mlir::scalehls::createCreateAxiInterfacePass()";
}

//===----------------------------------------------------------------------===//
// Loop Optimization Passes
//===----------------------------------------------------------------------===//

def FuncPreprocess : Pass<"scalehls-func-preprocess", "func::FuncOp"> {
  let summary = "Preprocess the functions for loop and directive optimizations";
  let constructor = "mlir::scalehls::createFuncPreprocessPass()";

  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"main\"",
           "The top function for HLS synthesis">
  ];
}

def ConvertCopyToAffineLoops :
      Pass<"scalehls-convert-copy-to-affine-loops", "func::FuncOp"> {
  let summary = "Convert copy and assign to affine loops";
  let description = [{
    This convert-copy-to-affine-loops pass will first remove redundant copies
    and lower assigns to copies, and then convert copies to affine loops.
  }];
  let constructor = "mlir::scalehls::createConvertCopyToAffineLoopsPass()";

  let options = [
    Option<"internCopyOnly", "intern-copy-only", "bool", /*default=*/"true",
           "only convert copy between internal memories">
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
           "Only apply unroll and jam to point loop band">,
    Option<"loopOrderOpt", "loop-order-opt", "bool", /*default=*/"false",
           "Whether loop order optimization after unrolling">
  ];
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

//===----------------------------------------------------------------------===//
// Directive Optimization Passes
//===----------------------------------------------------------------------===//

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

//===----------------------------------------------------------------------===//
// Memory Optimization Passes
//===----------------------------------------------------------------------===//

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
}

def PromoteBuffer : Pass<"scalehls-promote-buffer", "func::FuncOp"> {
  let summary = "Promote external buffer to on-chip buffer";
  let constructor = "mlir::scalehls::createPromoteBufferPass()";
}

def AffineStoreForward : Pass<"scalehls-affine-store-forward", "func::FuncOp"> {
  let summary = "Forward store to load, including conditional stores";
  let description = [{
    This affine-store-forward pass is similar to scal-repl, but supports to
    forward stores located in if statements.
  }];
  let constructor = "mlir::scalehls::createAffineStoreForwardPass()";
}

def SimplifyMemrefAccess :
      Pass<"scalehls-simplify-memref-access", "func::FuncOp"> {
  let summary = "Remove redundant load and store operations";
  let description = [{
    This simplify-memref-access pass will eliminate the known redundant load and
    store operations for simplifying the memref access.
  }];
  let constructor = "mlir::scalehls::createSimplifyMemrefAccessPass()";
}

def RaiseImplicitCopy : Pass<"scalehls-raise-implicit-copy", "func::FuncOp"> {
  let summary = "Raise copy in affine loops to memref.copy";
  let description = [{
    This raise-implicit-copy pass will detect implicit copy in affine loops and
    raise to memref.copy in order to eliminate redundant copies.
  }];
  let constructor = "mlir::scalehls::createRaiseImplicitCopyPass()";
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

def LowerCastAndSubview :
      Pass<"scalehls-lower-cast-and-subview", "func::FuncOp"> {
  let summary = "Lower the cast and subviews into alloc and copy";
  let description = [{}];
  let constructor = "mlir::scalehls::createLowerCastAndSubviewPass()";
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

def PreserveUnoptimized : Pass<"preserve-unoptimized", "ModuleOp"> {
  let summary = "Return unoptimized version of code along with the optimized one";
  let description = [{
    This preserve-unoptimized pass will create a copy of unoptimized module
    before optimization and return it along with the optimized version. 
  }];

  let constructor = "mlir::scalehls::createPreserveUnoptimizedPass()";
}

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
