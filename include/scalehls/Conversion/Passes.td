//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_CONVERSION_PASSES_TD
#define SCALEHLS_CONVERSION_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// HLSKernel and HLSCpp Conversion passes
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

//===----------------------------------------------------------------------===//
// Onnx Kernel Legalization Pass
//===----------------------------------------------------------------------===//

def LegalizeOnnx : Pass<"legalize-onnx", "ModuleOp"> {
  let summary = "Legalize model lowered from onnx-mlir flow";
  let description = [{
    This legalize-onnx pass will legalize all operations lowered from onnx-mlir
    flow, e.g. krnl.packed_const, krnl.global, and krnl.memcpy.
  }];

  let constructor = "mlir::scalehls::createLegalizeOnnxPass()";
}

#endif // SCALEHLS_CONVERSION_PASSES_TD
