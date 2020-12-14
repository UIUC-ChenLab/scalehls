//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// Pragma Optimization Passes
//===----------------------------------------------------------------------===//

def PragmaDSE : Pass<"pragma-dse", "ModuleOp"> {
  let summary = "Optimize pragma configuration of each optimizable region";
  let description = [{
    This pragma-dse pass will automatically tune HLS pragma insertion and
    configuration for performance and area optimization. By calling methods
    provided by hlscpp-qor-estimation, this pass is able to rapidly obtain the
    QoR estimation of the current design point, and feed it back to the design
    space exploration engine for an efficient convergence.
  }];

  let constructor = "mlir::scalehls::createPragmaDSEPass()";
}

def ArrayPartition : Pass<"array-partition", "FuncOp"> {
  let summary = "Apply optimized array partition optimization";
  let description = [{
    This array-partition pass will automatically search for the best array
    partition solution of each on-chip memory instance and insert array
    partition pragmas.
  }];

  let constructor = "mlir::scalehls::createArrayPartitionPass()";
}

def InsertPipelinePragma : Pass<"insert-pipeline-pragma", "FuncOp"> {
  let summary = "Insert pipeline pragma";
  let description = [{
    This insert-pipeline-pragma pass will insert pipeline pragma to the
    innermost loop level.
  }];

  let constructor = "mlir::scalehls::createInsertPipelinePragmaPass()";

  let options = [
    Option<"insertLevel", "insert-level", "unsigned", /*default=*/"1", 
           "Positive number: loop level to be pipelined (from innermost)">
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
    innermost loop and create affine if regions to ensure the correctness of the
    movement.
  }];

  let constructor = "mlir::scalehls::createAffineLoopPerfectionPass()";
}

def PartialAffineLoopTile : Pass<"partial-affine-loop-tile", "FuncOp"> {
  let summary = "Partially tile affine nested loops";
  let description = [{
    This partial-affine-loop-tile pass will try to tile the nested loops. The
    difference with the official affine-loop-tile pass is this pass will only
    tile the first "tileLevel" outermost loop levels rather than all loops
    levels.
  }];

  let constructor = "mlir::scalehls::createPartialAffineLoopTilePass()";

  let options = [
    Option<"tileLevel", "tile-level", "unsigned", /*default=*/"1", 
           "Positive number: the level of loops to be tiles">,
    Option<"tileSize", "tile-size", "unsigned", /*default=*/"2", 
           "Positive number: the size of tiling">
  ];
}

def RemoveVarLoopBound : Pass<"remove-var-loop-bound", "FuncOp"> {
  let summary = "Try to remove variable loop bounds";
  let description = [{
    This remove-var-loop-bound pass will try to remove the variable loop bounds.
    Specifically, this is only possible when the variable loop bound is an
    affine expression of induction variables of other loops with constant lower
    or upper bound.
  }];

  let constructor = "mlir::scalehls::createRemoveVarLoopBoundPass()";
}

//===----------------------------------------------------------------------===//
// Dataflow Optimization Passes
//===----------------------------------------------------------------------===//

def SplitFunction : Pass<"split-function", "ModuleOp"> {
  let summary = "Split function for enabling dataflow";
  let description = [{
    This split-function pass should be applied in HLSKernel level. This pass
    will split each HLSKernel operation into a separate function for applying
    dataflow pragma to the top function.
  }];

  let constructor = "mlir::scalehls::createSplitFunctionPass()";
}

def LegalizeDataflow : Pass<"legalize-dataflow", "FuncOp"> {
  let summary = "Legalize code for the dataflow pragma";
  let description = [{
    This legalize-dataflow pass will legalize the dataflow by inserting some
    dummy nodes and grouping nodes in the same level to meet the requirements of
    the dataflow pragma: 1) single-producer single-consumer 2) no bypass.
  }];

  let constructor = "mlir::scalehls::createLegalizeDataflowPass()";
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

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
