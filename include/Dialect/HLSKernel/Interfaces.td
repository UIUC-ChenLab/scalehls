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

  let methods = [
    InterfaceMethod<
      "Return the shaped type of the i-th operand",
      "ShapedType", "getOperandShapedType", (ins "unsigned" : $i),
      [{ return $_op.getOperation()->getOperand(i).getType().template cast<ShapedType>(); }]
    >
  ];
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_INTERFACES_TD
