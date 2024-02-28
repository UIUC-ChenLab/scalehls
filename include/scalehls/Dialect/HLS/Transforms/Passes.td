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

def ReduceTensorToStream :
    Pass<"scalehls-reduce-tensor-to-stream", "func::FuncOp"> {
  let summary = "Reduce immediate tensors to stream buffers";
  let constructor = "mlir::scalehls::hls::createReduceTensorToStreamPass()";
}

def FuseStreamFork : Pass<"scalehls-fuse-stream-fork", "func::FuncOp"> {
  let summary = "Fuse stream fork operations";
  let constructor = "mlir::scalehls::hls::createFuseStreamForkPass()";
}

def MaterializeStream : Pass<"scalehls-materialize-stream", "func::FuncOp"> {
  let summary = "Materialize tensor/stream conversions and stream buffers";
  let constructor = "mlir::scalehls::hls::createMaterializeStreamPass()";

  let options = [
    Option<"enablePacking", "enable-packing", "bool", /*default=*/"true",
           "Whether to enable packing during the materialization">
  ];
}

def ScalarizeStream : Pass<"scalehls-scalarize-stream", "func::FuncOp"> {
  let summary = "Scalarize stream channel elements";
  let constructor = "mlir::scalehls::hls::createScalarizeStreamPass()";
}

def ScheduleDataflow : Pass<"scalehls-schedule-dataflow", "func::FuncOp"> {
  let summary = "Create a dataflow schedule";
  let constructor = "mlir::scalehls::hls::createScheduleDataflowPass()";
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
