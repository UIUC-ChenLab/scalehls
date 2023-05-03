//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// Conversion Passes
//===----------------------------------------------------------------------===//

def ConvertLinalgToFDF :
    Pass<"scalehls-convert-linalg-to-fdf", "func::FuncOp"> {
  let summary = "Convert linalg to functional dataflow";
  let constructor = "mlir::scalehls::createConvertLinalgToFDFPass()";
}

def ConvertFDFToSDF : Pass<"scalehls-convert-fdf-to-sdf", "func::FuncOp"> {
  let summary = "Convert functional to structural dataflow";
  let constructor = "mlir::scalehls::createConvertFDFToSDFPass()";
}

def ConvertSDFToFunc : Pass<"scalehls-convert-sdf-to-func", "mlir::ModuleOp"> {
  let summary = "Convert structural dataflow to function for C++ emission";
  let constructor = "mlir::scalehls::createConvertSDFToFuncPass()";
}

//===----------------------------------------------------------------------===//
// Transform Passes
//===----------------------------------------------------------------------===//

def ComprehensiveBufferize :
    Pass<"scalehls-comprehensive-bufferize", "mlir::ModuleOp"> {
  let summary = "Comprehensively bufferize the program";
  let constructor = "mlir::scalehls::createComprehensiveBufferizePass()";
}

def GenerateRuntimeFunc :
    Pass<"scalehls-generate-runtime-func", "mlir::ModuleOp"> {
  let summary = "Outline the top function for HLS";
  let constructor = "mlir::scalehls::createGenerateRuntimeFuncPass()";
  
  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"forward\"",
           "Name of the top function for HLS">,
    Option<"runtimeFunc", "runtime-func", "std::string",
           /*default=*/"\"runtime\"", "Name of the runtime function.">
  ];
}

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
