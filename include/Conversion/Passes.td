//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_CONVERSION_PASSES_TD
#define SCALEHLS_CONVERSION_PASSES_TD

include "mlir/Pass/PassBase.td"

def ConvertToHLSCpp : Pass<"convert-to-hlscpp", "FuncOp"> {
  let summary = "Convert to emittable MLIR code";
  let description = [{
    This convert-to-hlscpp converts MLIR code in Affine/Standard/SCF level to
    emittable MLIR code.
  }];

  let constructor = "mlir::scalehls::createConvertToHLSCppPass()";

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

#endif // SCALEHLS_CONVERSION_PASSES_TD
