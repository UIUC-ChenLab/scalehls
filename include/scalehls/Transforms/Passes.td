//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

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
