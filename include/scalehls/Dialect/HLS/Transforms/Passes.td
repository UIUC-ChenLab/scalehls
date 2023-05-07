//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def EliminateBufferYield :
    Pass<"scalehls-fdf-eliminate-buffer-yield", "func::FuncOp"> {
  let summary = "Eliminate unecessary buffer yield operations";
  let constructor = "mlir::scalehls::hls::createEliminateBufferYieldPass()";
}

def ParameterizeDataflowTask :
    Pass<"scalehls-parameterize-dataflow-task", "mlir::ModuleOp"> {
  let summary = "Parameterize dataflow tasks";
  let constructor = "mlir::scalehls::hls::createParameterizeDataflowTaskPass()";

  let options = [
    Option<"defaultTileFactor", "default-tile-factor", "unsigned",
           /*default=*/"32", "Positive number">,
    Option<"defaultParallelFactor", "default-parallel-factor", "unsigned",
           /*default=*/"2", "Positive number">
  ];
}

def MatchIPCandidates : Pass<"scalehls-match-ip-candidates", "mlir::ModuleOp"> {
  let summary = "Match IP candidates for each dataflow task";
  let constructor = "mlir::scalehls::hls::createMatchIPCandidatesPass()";
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
