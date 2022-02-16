//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_CONVERSION_PASSES_TD
#define SCALEHLS_CONVERSION_PASSES_TD

include "mlir/Pass/PassBase.td"

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

//===----------------------------------------------------------------------===//
// ONNX to TOSA Pass
//===----------------------------------------------------------------------===//

def ConvertOnnxToTosa : Pass<"convert-onnx-to-tosa", "ModuleOp"> {
  let summary = "Convert the operations from ONNX dialect into TOSA dialect";
  let description = [{
    This pass only supports Constant, Conv, Relu, MaxPoolSingleOut operation of
    ONNX dialect.
  }];

  let constructor = "mlir::scalehls::createConvertOnnxToTosaPass()";

  let options = [
    Option<"externalizeConstant", "externalize-constant", "bool",
           /*default=*/"true", "Whether externalize constant operations">
  ];
}

#endif // SCALEHLS_CONVERSION_PASSES_TD