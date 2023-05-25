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

def LowerDataflow : Pass<"scalehls-lower-dataflow", "func::FuncOp"> {
  let summary = "Convert functional to structural dataflow";
  let constructor = "mlir::scalehls::hls::createLowerDataflowPass()";
}

def ParameterizeTileParallelFactor :
    Pass<"scalehls-parameterize-tile-parallel-factor", "mlir::ModuleOp"> {
  let summary = "Parameterize tile and parallel factor for each dataflow task";
  let constructor = "mlir::scalehls::hls::createParameterizeTileParallelFactorPass()";

  let options = [
    Option<"defaultTileFactor", "default-tile-factor", "unsigned",
           /*default=*/"32", "Positive number">,
    Option<"defaultParallelFactor", "default-parallel-factor", "unsigned",
           /*default=*/"2", "Positive number">
  ];
}

def ParameterizeIPCandidate :
    Pass<"scalehls-parameterize-ip-candidates", "mlir::ModuleOp"> {
  let summary = "Paremterize matched IP candidates for each dataflow task";
  let constructor = "mlir::scalehls::hls::createParameterizeIPCandidatePass()";
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
