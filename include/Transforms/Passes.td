//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

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
           "File path: target backend specifications and configurations">
  ];
}

//===----------------------------------------------------------------------===//
// Pragma Optimization Passes
//===----------------------------------------------------------------------===//

def ArrayPartition : Pass<"array-partition", "FuncOp"> {
  let summary = "Apply optimized array partition strategy";
  let description = [{
    This array-partition pass will automatically search for the best array
    partition solution for each on-chip memory instance and apply the solution
    through changing the layout AffineMap of the corresponding MemRefType.
  }];

  let constructor = "mlir::scalehls::createArrayPartitionPass()";
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
           "Positive number: loop level to be pipelined (from innermost)">
  ];
}

def FuncPipelining : Pass<"func-pipelining", "FuncOp"> {
  let summary = "Apply function pipelining";
  let description = [{
    This func-pipelining pass will insert pipeline pragma to the specified
    function, all contained loops will be automatically unrolled.
  }];

  let constructor = "mlir::scalehls::createFuncPipeliningPass()";

  let options = [
    Option<"targetFunction", "target-function", "std::string",
           /*default=*/"\"main\"", "The target function to be pipelined">
  ];
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
    Option<"tileLevel", "tile-level", "unsigned", /*default=*/"1", 
           "Positive number: the level of loops to be tiled">,
    Option<"tileSize", "tile-size", "unsigned", /*default=*/"2", 
           "Positive number: the size of tiling">
  ];
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
// Bufferization Passes
//===----------------------------------------------------------------------===//

def HLSKernelBufferize : Pass<"hlskernel-bufferize", "FuncOp"> {
  let summary = "Bufferize HLSKernel operations";
  let description = [{
    This hlskernel-bufferize pass will bufferize HLSKernel operations.
  }];

  let constructor = "mlir::scalehls::createHLSKernelBufferizePass()";
}

//===----------------------------------------------------------------------===//
// MemRef Optimization Passes
//===----------------------------------------------------------------------===//

def AffineStoreForward : Pass<"affine-store-forward", "FuncOp"> {
  let summary = "Forward store to load, including conditional stores";
  let description = [{
    This affine-store-forward pass is similar to memref-dataflow-opt, but
    supports to forward stores located in AffineIf regions.
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
