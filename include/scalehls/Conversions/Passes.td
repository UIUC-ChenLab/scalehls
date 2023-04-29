//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_CONVERSIONS_PASSES_TD
#define SCALEHLS_CONVERSIONS_PASSES_TD

include "mlir/Pass/PassBase.td"

def ConvertLinalgToFDF :
    Pass<"scalehls-convert-linalg-to-fdf", "mlir::func::FuncOp"> {
  let summary = "Convert linalg to functional dataflow";
  let constructor = "mlir::scalehls::createConvertLinalgToFDFPass()";
}

def ConvertFDFToSDF :
    Pass<"scalehls-convert-fdf-to-sdf", "mlir::func::FuncOp"> {
  let summary = "Convert functional to structural dataflow";
  let constructor = "mlir::scalehls::createConvertFDFToSDFPass()";
}

def ConvertSDFToFunc :
    Pass<"scalehls-convert-sdf-to-func", "mlir::ModuleOp"> {
  let summary = "Convert structural dataflow to function for C++ emission";
  let constructor = "mlir::scalehls::createConvertSDFToFuncPass()";
}

#endif // SCALEHLS_CONVERSIONS_PASSES_TD
