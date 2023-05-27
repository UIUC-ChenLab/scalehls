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

def GenerateTaskDesignSpace :
    Pass<"scalehls-generate-task-design-space", "mlir::ModuleOp"> {
  let summary = "Generate design space for each dataflow task";
  let constructor = "mlir::scalehls::hls::createGenerateTaskDesignSpacePass()";

  let options = [
    Option<"defaultTileFactor", "default-tile-factor", "unsigned",
           /*default=*/"32", "Positive number">,
    Option<"defaultParallelFactor", "default-parallel-factor", "unsigned",
           /*default=*/"2", "Positive number">
  ];
}

def SimplifyDesignSpace :
      Pass<"scalehls-simplify-design-space", "mlir::ModuleOp"> {
  let summary = "Simplify design space";
  let constructor = "mlir::scalehls::hls::createSimplifyDesignSpacePass()";
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
