//===-------------------------------------------------------*- tablegen -*-===//
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
    This legalize-to-hlscpp converts MLIR code in Affine/Standard/SCF level to
    emittable and estimatable MLIR code.
  }];

  let constructor = "mlir::scalehls::createLegalizeToHLSCppPass()";

  let options = [
    Option<"topFunction", "top-function", "std::string", /*default=*/"\"main\"", 
           "The top function for HLS synthesis">,
  ];
}

def HLSKernelToAffine : Pass<"hlskernel-to-affine", "FuncOp"> {
  let summary = "Convert HLSKernel operation to Affine loops";
  let description = [{
    This hlskernel-to-affine converts HLSKernel operations to their Affine level
    representations.
  }];

  let constructor = "mlir::scalehls::createHLSKernelToAffinePass()";
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
