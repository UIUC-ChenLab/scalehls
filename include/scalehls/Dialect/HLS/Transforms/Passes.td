//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def PreprocessDataflow : Pass<"scalehls-preprocess-dataflow", "func::FuncOp"> {
  let summary = "Preprocess the IR for dataflow transformation";
  let constructor = "mlir::scalehls::hls::createPreprocessDataflowPass()";
}

def CreateDataflow : Pass<"scalehls-create-dataflow", "func::FuncOp"> {
  let summary = "Convert linalg to functional dataflow";
  let constructor = "mlir::scalehls::hls::createCreateDataflowPass()";
}

def LowerDataflow : Pass<"scalehls-lower-dataflow", "func::FuncOp"> {
  let summary = "Convert functional to structural dataflow";
  let constructor = "mlir::scalehls::hls::createLowerDataflowPass()";
}

def ConvertDataflowToFunc :
    Pass<"scalehls-convert-dataflow-to-func", "mlir::ModuleOp"> {
  let summary = "Convert structural dataflow to function for C++ emission";
  let constructor = "mlir::scalehls::hls::createConvertDataflowToFuncPass()";
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
