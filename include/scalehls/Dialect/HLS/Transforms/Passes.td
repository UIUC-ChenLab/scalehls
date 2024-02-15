//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def Preprocess : Pass<"scalehls-preprocess", "func::FuncOp"> {
  let summary = "Preprocess the IR for subsequent transforms";
  let constructor = "mlir::scalehls::hls::createPreprocessPass()";
}

def ScalarizeStream : Pass<"scalehls-scalarize-stream", "func::FuncOp"> {
  let summary = "Scalarize stream channels";
  let constructor = "mlir::scalehls::hls::createScalarizeStreamPass()";
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

//===----------------------------------------------------------------------===//
// Transform Passes
//===----------------------------------------------------------------------===//

def ApplyTransformPattern :
    Pass<"scalehls-apply-transform-pattern", "func::FuncOp"> {
  let summary = "A test pass to apply transformation patterns";
  let constructor = "mlir::scalehls::hls::createApplyTransformPatternPass()";
}

def RaiseSCFToAffine : Pass<"scalehls-raise-scf-to-affine"> {
  let summary = "Raise SCF to affine";
  let constructor = "mlir::scalehls::hls::createRaiseSCFToAffinePass()";
}

def ComprehensiveBufferize :
    Pass<"scalehls-comprehensive-bufferize", "mlir::ModuleOp"> {
  let summary = "Comprehensively bufferize the program";
  let constructor = "mlir::scalehls::hls::createComprehensiveBufferizePass()";
}

def LowerCopyToAffineLoops :
    Pass<"scalehls-lower-copy-to-affine-loops", "func::FuncOp"> {
  let summary = "Convert memref copy to affine loops";
  let constructor = "mlir::scalehls::hls::createLowerCopyToAffineLoopsPass()";
}

def GenerateRuntimeFunc :
    Pass<"scalehls-generate-runtime-func", "mlir::ModuleOp"> {
  let summary = "Outline the top function for HLS";
  let constructor = "mlir::scalehls::hls::createGenerateRuntimeFuncPass()";
  
  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"forward\"",
           "Name of the top function for HLS">,
    Option<"runtimeFunc", "runtime-func", "std::string",
           /*default=*/"\"runtime\"", "Name of the runtime function.">
  ];
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
