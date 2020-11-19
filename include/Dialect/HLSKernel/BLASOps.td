//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_BLASOPS_TD
#define SCALEHLS_DIALECT_HLSKERNEL_BLASOPS_TD

def GemmOp : HLSKernelOp<"gemm", [HLSKernelOpInterface]> {
  let summary = "gemm operation";
  let description = [{
    Cout = alpha * A * B + beta * C
  }];

  let arguments = (ins
    AnyType:$alpha,
    AnyType:$beta,
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$A,
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$B,
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$C
  );
  let results = (outs
    AnyTypeOf<[AnyTensor, AnyMemRef, NoneType]>:$Cout
  );
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_BLASOPS_TD
