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

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
