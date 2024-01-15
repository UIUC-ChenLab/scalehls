//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def ConvertEmptyTensorToAllocTensor :
    Pass<"scalehls-convert-empty-tensor-to-alloc-tensor", "func::FuncOp"> {
  let summary = "Convert tensor.empty to hls.fdf.alloc_tensor";
  let constructor = [{
      mlir::scalehls::hls::createConvertEmptyTensorToAllocTensorPass()
  }];
}

def ConvertDataflowToFunc :
    Pass<"scalehls-convert-dataflow-to-func", "mlir::ModuleOp"> {
  let summary = "Convert structural dataflow to function for C++ emission";
  let constructor = "mlir::scalehls::hls::createConvertDataflowToFuncPass()";
}

def CreateDataflow : Pass<"scalehls-create-dataflow", "func::FuncOp"> {
  let summary = "Convert linalg to functional dataflow";
  let constructor = "mlir::scalehls::hls::createCreateDataflowPass()";
}

def LowerDataflow : Pass<"scalehls-lower-dataflow", "func::FuncOp"> {
  let summary = "Convert functional to structural dataflow";
  let constructor = "mlir::scalehls::hls::createLowerDataflowPass()";
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
