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

def MultipleLevelDSE : Pass<"multiple-level-dse", "ModuleOp"> {
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
    Option<"targetSpec", "target-spec", "std::string",
           /*default=*/"\"../config/target-spec.ini\"",
           "File path: target backend specifications and configurations">,

    Option<"dumpFile", "dump-file", "std::string",
           /*default=*/"\"-\"", "File path: the dump file path">,

    Option<"topFunc", "top-func", "std::string", /*default=*/"\"main\"",
           "The top function for HLS synthesis">,

    Option<"depAnalysis", "dep-analysis", "bool", /*default=*/"true",
           "Whether a comprehensive dependency analysis is conducted">,

    Option<"maxInitParallel", "max-init-parallel", "unsigned", /*default=*/"16",
           "Positive number: the maximum parallelism of initialization">,
    Option<"maxIterNum", "max-iter-num", "unsigned", /*default=*/"8",
           "Positive number: the maximum DSE iteration number">,
    Option<"maxDistance", "max-distance", "float", /*default=*/"1.0",
           "Positive float number: the maximum distance of neighbor points">,
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
}

//===----------------------------------------------------------------------===//
// Loop Optimization Passes
//===----------------------------------------------------------------------===//

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
    only tile the first "tileLevel" outermost loop levels rather than all loops
    levels.
  }];

  let constructor = "mlir::scalehls::createPartialAffineLoopTilePass()";

  let options = [
    Option<"tileSize", "tile-size", "unsigned", /*default=*/"2",
           "Positive number: the size of tiling">
  ];
}

//===----------------------------------------------------------------------===//
// Directive Optimization Passes
//===----------------------------------------------------------------------===//

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

def ArrayPartition : Pass<"array-partition", "FuncOp"> {
  let summary = "Apply optimized array partition strategy";
  let description = [{
    This array-partition pass will automatically search for the best array
    partition solution for each on-chip memory instance and apply the solution
    through changing the layout AffineMap of the corresponding MemRefType.
  }];

  let constructor = "mlir::scalehls::createArrayPartitionPass()";
}

//===----------------------------------------------------------------------===//
// Standard Operation Optimization Passes
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

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
