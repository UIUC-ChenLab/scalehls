//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_OPS_TD
#define SCALEHLS_DIALECT_HLSKERNEL_OPS_TD

def ConvOp : HLSKernelOp<"conv", []> {
  let summary = "convolution operation";
  let description = [{ Convolution operation. }];
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_OPS_TD
