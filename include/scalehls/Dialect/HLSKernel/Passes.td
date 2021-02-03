//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_PASSES_TD
#define SCALEHLS_DIALECT_HLSKERNEL_PASSES_TD

include "mlir/Pass/PassBase.td"

def HLSKernelBufferize : Pass<"hlskernel-bufferize", "FuncOp"> {
  let summary = "Bufferize HLSKernel operations";
  let description = [{
    This hlskernel-bufferize pass will bufferize HLSKernel operations.
  }];

  let constructor = "mlir::scalehls::createHLSKernelBufferizePass()";
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_PASSES_TD
