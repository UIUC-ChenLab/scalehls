//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// QoR Estimation Pass
//===----------------------------------------------------------------------===//

def QoREstimation : Pass<"qor-estimation", "ModuleOp"> {
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
           /*default=*/"\"./target-spec.ini\"",
           "File path: target backend specifications and configurations">,

    Option<"depAnalysis", "dep-analysis", "bool", /*default=*/"true",
           "Whether a comprehensive dependency analysis is conducted">
  ];
}

//===----------------------------------------------------------------------===//
// Design Space Exploration Pass
//===----------------------------------------------------------------------===//

def MultipleLevelDSE : Pass<"dse", "ModuleOp"> {
  let summary = "Optimize HLS design at multiple abstraction level";
  let description = [{
    This multiple-level-dse pass will automatically conduct the design space
    exploration (DSE) across multiple abstraction levels. By calling methods
    provided by qor-estimation, this pass is able to rapidly obtain the QoR
    estimation of the current design point, and feed it back to the DSE engine
    for an efficient optimization convergence.
  }];

  let constructor = "mlir::scalehls::createMultipleLevelDSEPass()";

  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"main\"",
           "The top function for HLS synthesis">,
    Option<"outputPath", "output-path", "std::string",
           /*default=*/"\"./\"",
           "File path: the path for dumping the MLIR of pareto design points">,
    Option<"csvPath", "csv-path", "std::string",
           /*default=*/"\"./\"",
           "File path: the path for dumping the CSV of design spaces">,

    Option<"targetSpec", "target-spec", "std::string",
           /*default=*/"\"./target-spec.ini\"",
           "File path: target backend specifications and configurations">,

    Option<"depAnalysis", "dep-analysis", "bool", /*default=*/"true",
           "Whether a comprehensive dependency analysis is conducted">
  ];
}

//===----------------------------------------------------------------------===//
// Dataflow Optimization Passes
//===----------------------------------------------------------------------===//

def LegalizeDataflow : Pass<"legalize-dataflow", "FuncOp"> {
  let summary = "Legalize the dataflow scheduling";
  let description = [{
    This legalize-dataflow pass will legalize the dataflow scheduling to meet
    the requirements of the dataflow pragma: 1) single-producer single-consumer;
    2) no bypass paths.
  }];

  let constructor = "mlir::scalehls::createLegalizeDataflowPass()";

  let options = [
    Option<"insertCopy", "insert-copy", "bool", /*default=*/"true",
           "Whether insert copy operations to break bypass paths">,
    Option<"minGran", "min-gran", "unsigned", /*default=*/"1",
           "Positive number: the minimum granularity of dataflow">
  ];
}

def SplitFunction : Pass<"split-function", "ModuleOp"> {
  let summary = "Split function for enabling the dataflow pragma";
  let description = [{
    This split-function pass will split operations/loops scheduled at the same
    dataflow level into a separate sub-function for applying the dataflow pragma
    to the top function.
  }];

  let constructor = "mlir::scalehls::createSplitFunctionPass()";

  let options = [
    Option<"splitSubFunc", "split-sub-func", "bool", /*default=*/"false",
           "Whether to further split the sub-functions so that each generated"
           "function only contains one loop band">
  ];
}

//===----------------------------------------------------------------------===//
// Loop Optimization Passes
//===----------------------------------------------------------------------===//

def MaterializeReduction : Pass<"materialize-reduction", "FuncOp"> {
  let summary = "Materialize loop reductions";
  let description = [{
    This materialize-reduction pass will materialize loop reductions with local
    buffer read/writes in order to expose more optimizations targeting HLS.
  }];

  let constructor = "mlir::scalehls::createMaterializeReductionPass()";
}

def AffineLoopPerfection : Pass<"affine-loop-perfection", "FuncOp"> {
  let summary = "Try to perfect a nested loop";
  let description = [{
    This affine-loop-perfection pass will try to perfect all affine loops.
    Specifically, this pass will move operations under non-innermost loops into
    innermost loop and create AffineIf regions to ensure the correctness of the
    transformation.
  }];

  let constructor = "mlir::scalehls::createAffineLoopPerfectionPass()";
}

def RemoveVariableBound : Pass<"remove-variable-bound", "FuncOp"> {
  let summary = "Try to remove variable loop bounds";
  let description = [{
    This remove-variable-bound pass will try to remove the variable loop bounds.
    Specifically, this is only feasible when the loop bound is an affine
    expression of induction variables of other loops with constant lower and
    upper bound.
  }];

  let constructor = "mlir::scalehls::createRemoveVariableBoundPass()";
}

def AffineLoopOrderOpt : Pass<"affine-loop-order-opt", "FuncOp"> {
  let summary = "Optimize the order of affine loop nests";
  let description = [{
    This affine-loop-order-opt pass will optimize the order of perfect affine
    loop nests through polyhedral-based dependency analysis.
  }];

  let constructor = "mlir::scalehls::createAffineLoopOrderOptPass()";
}

def PartialAffineLoopTile : Pass<"partial-affine-loop-tile", "FuncOp"> {
  let summary = "Partially tile affine nested loops";
  let description = [{
    This partial-affine-loop-tile pass will try to tile all affine nested loops.
    The difference with the official affine-loop-tile pass is this pass will
    tile the outermost loop until the overall tiling size is equal to or larfer
    than "tileSize".
  }];

  let constructor = "mlir::scalehls::createPartialAffineLoopTilePass()";

  let options = [
    Option<"tileSize", "tile-size", "unsigned", /*default=*/"1",
           "Positive number: the size of tiling">,
    Option<"applyOrderOpt", "apply-order-opt", "bool", /*default=*/"true",
           "Whether apply loop order optimization after tiling">,
    Option<"applyPipeline", "apply-pipeline", "bool", /*default=*/"true",
           "Whether apply loop pipeline after tiling">
  ];
}

//===----------------------------------------------------------------------===//
// Directive Optimization Passes
//===----------------------------------------------------------------------===//

def LegalizeToHLSCpp : Pass<"legalize-to-hlscpp", "FuncOp"> {
  let summary = "Convert to emittable MLIR code";
  let description = [{
    This legalize-to-hlscpp pass will legalize the input IR to make it
    emittable. Meanwhile, this pass will set some default pragmas for the
    convenience of the subsequent transforms and analysis.
  }];

  let constructor = "mlir::scalehls::createLegalizeToHLSCppPass()";

  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"main\"",
           "The top function for HLS synthesis">
  ];
}

def CreateHLSCppPrimitive : Pass<"create-hlscpp-primitive", "FuncOp"> {
  let summary = "Create HLS C++ multiplification primitives";
  let description = [{
    This create-hlscpp-primitive pass will convert 8-bits multiplifications to
    HLS C++ primitives in order to utilize DSP instances in FPGA.
  }];

  let constructor = "mlir::scalehls::createCreateHLSCppPrimitivePass()";
}

def FuncPipelining : Pass<"func-pipelining", "FuncOp"> {
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

def LoopPipelining : Pass<"loop-pipelining", "FuncOp"> {
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

def ArrayPartition : Pass<"array-partition", "ModuleOp"> {
  let summary = "Apply optimized array partition strategy";
  let description = [{
    This array-partition pass will automatically search for the best array
    partition solution for each on-chip memory instance and apply the solution
    through changing the layout AffineMap of the corresponding MemRefType.
  }];

  let constructor = "mlir::scalehls::createArrayPartitionPass()";
}

//===----------------------------------------------------------------------===//
// Simplification Passes
//===----------------------------------------------------------------------===//

def SimplifyAffineIf : Pass<"simplify-affine-if", "FuncOp"> {
  let summary = "Simplify affine if operations";
  let description = [{
    This simplify-affine-if pass will eliminate all redundant affine if
    operations which will always take then or else branch, and merge all affine
    if operations that having the same statement.
  }];

  let constructor = "mlir::scalehls::createSimplifyAffineIfPass()";
}

def AffineStoreForward : Pass<"affine-store-forward", "FuncOp"> {
  let summary = "Forward store to load, including conditional stores";
  let description = [{
    This affine-store-forward pass is similar to memref-dataflow-opt, but
    supports to forward stores located in AffineIfOp regions.
  }];

  let constructor = "mlir::scalehls::createAffineStoreForwardPass()";
}

def SimplifyMemrefAccess : Pass<"simplify-memref-access", "FuncOp"> {
  let summary = "Remove redundant load and store operations";
  let description = [{
    This simplify-memref-access pass will eliminate the known redundant load and
    store operations for simplifying the memref access.
  }];

  let constructor = "mlir::scalehls::createSimplifyMemrefAccessPass()";
}

//===----------------------------------------------------------------------===//
// Other Passes
//===----------------------------------------------------------------------===//

def PreserveUnoptimized : Pass<"preserve-unoptimized", "ModuleOp"> {
  let summary = "Return unoptimized version of code along with the optimized one";
  let description = [{
    This preserve-unoptimized pass will create a copy of unoptimized module
    before optimization and return it along with the optimized version. 
  }];

  let constructor = "mlir::scalehls::createPreserveUnoptimizedPass()";
}

def ReduceInitialInterval : Pass<"reduce-initial-interval", "FuncOp"> {
  let summary = "Try to reduce the intiail interval";
  let description = [{
    This reduce-initial-interval pass try to reduce the II by optimizing the
    commutative operator trees and iteration variables.
  }];

  let constructor = "mlir::scalehls::createReduceInitialIntervalPass()";
}

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
