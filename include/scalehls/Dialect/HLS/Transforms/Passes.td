//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def ReduceFullTensorToITensorBuffer :
    Pass<"scalehls-reduce-full-tensor-to-itensor-buffer", "func::FuncOp"> {
  let summary = "Reduce immediate full tensors to itensor buffers";
}

def PackITensorDMA : Pass<"scalehls-pack-itensor-dma", "func::FuncOp"> {
  let summary = "Pack/unpack itensor DMAs";
}

def MaterializeITensorDMA :
    Pass<"scalehls-materialize-itensor-dma", "func::FuncOp"> {
  let summary = "Materialize itensor DMAs";
}

def EnsureITensorSingleUse :
    Pass<"scalehls-ensure-itensor-single-use", "func::FuncOp"> {
  let summary = "Ensure each itensor has a single use";
}

def ConvertEmptyToInstance :
    Pass<"scalehls-convert-empty-to-instance", "func::FuncOp"> {
  let summary = "Convert tensor/itensor empty op to tensor/itensor instance op";
}

def GenerateDataflowHierarchy :
    Pass<"scalehls-generate-dataflow-hierarchy", "func::FuncOp"> {
  let summary = "Generate dataflow hierarchy";
}

def ScheduleDataflow : Pass<"scalehls-schedule-dataflow", "func::FuncOp"> {
  let summary = "Schedule dataflow";
}

def ScalarizeITensor : Pass<"scalehls-scalarize-itensor", "func::FuncOp"> {
  let summary = "Scalarize itensor elements";
}

def LowerITensorToStream :
    Pass<"scalehls-lower-itensor-to-stream", "func::FuncOp"> {
  let summary = "Lower itensor operations to stream operations";
}

def ComprehensiveBufferize :
    Pass<"scalehls-comprehensive-bufferize", "mlir::ModuleOp"> {
  let summary = "Comprehensively bufferize the program";
}

def ConvertDataflowToFunc :
    Pass<"scalehls-convert-dataflow-to-func", "mlir::ModuleOp"> {
  let summary = "Convert structural dataflow to function for C++ emission";
}

def RaiseSCFToAffine : Pass<"scalehls-raise-scf-to-affine", "func::FuncOp"> {
  let summary = "Raise SCF to affine";
}

def GenerateDirectives : Pass<"scalehls-generate-directives", "func::FuncOp"> {
  let summary = "Generate HLS directives";
}

def ApplyDirectives : Pass<"scalehls-apply-directives", "func::FuncOp"> {
  let summary = "Apply HLS directives";
}

def FuseLinalgFill : Pass<"scalehls-fuse-linalg-fill", "func::FuncOp"> {
  let summary = "Fuse linalg fill op into generic op";
}

def StripAnnotations : Pass<"scalehls-strip-annotations", "func::FuncOp"> {
  let summary = "Strip all annotations with the given name";
  let options = [
    Option<"annotationName", "annotation-name", "std::string",
           /*default=*/[{""}], "">
  ];
}

def TransformInterpreter : Pass<"scalehls-transform-interpreter"> {
  let summary = "Interprete transform sequence with the given entry point";

  let options = [
    Option<"debugPayloadRootTag", "debug-payload-root-tag", "std::string",
           /*default=*/[{""}],
           "Select the operation with 'transform.target_tag' attribute having "
           "the given value as payload IR root. If empty select the pass "
           "anchor operation as the payload IR root.">,
    Option<"disableExpensiveChecks", "disable-expensive-checks", "bool",
           "false",
           "Disable expensive checks in the interpreter for a faster run.">,
    Option<"entryPoint", "entry-point", "std::string",
           /*default=*/"\"__transform_main\"",
           "Entry point of the pass pipeline.">,
    Option<"deleteEntryPoint", "delete-entry-point", "bool", /*default=*/"true",
           "Delete the entry point after transformation.">
  ];
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_TD
