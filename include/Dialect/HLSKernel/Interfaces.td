//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_INTERFACES_TD
#define SCALEHLS_DIALECT_HLSKERNEL_INTERFACES_TD

include "mlir/IR/OpBase.td"

def HLSKernelOpInterface : OpInterface<"HLSKernelOpInterface"> {
  let description = [{
    This interface indicates the operation is an HLS kernel.
  }];
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_INTERFACES_TD
