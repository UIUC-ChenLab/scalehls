//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_OPS_TD
#define SCALEHLS_DIALECT_HLSKERNEL_OPS_TD

def ConvOp : HLSKernelOp<"conv", [HLSKernelOpInterface]> {
  let summary = "convolution operation";
  let description = [{
    Convolution operation. For now, only static shaped 4-dims X (batch, channel,
    row, and col), 4-dims W (input channel, output channel, kernel row, and
    kernel col), 1-dim B (output channel), and 4-dims Y (batch, channel, row,
    and col) are supported. Meanwhile, in the current lowering, padding is not
    allowed. Verifiers will ensure the legalness of the operation}];

  let arguments = (ins
    AnyTypeOf<[TensorOf<[F16]>, TensorOf<[F32]>, TensorOf<[F64]>, AnyMemRef]>:$X,
    AnyTypeOf<[TensorOf<[F16]>, TensorOf<[F32]>, TensorOf<[F64]>, AnyMemRef]>:$W,
    AnyTypeOf<[TensorOf<[F16]>, TensorOf<[F32]>, TensorOf<[F64]>, AnyMemRef, NoneType]>:$B,
    OptionalAttr<I64ArrayAttr>:$pads,
    OptionalAttr<I64ArrayAttr>:$strides
  );
  let results = (outs
    AnyTypeOf<[TensorOf<[F16]>, TensorOf<[F32]>, TensorOf<[F64]>, AnyMemRef, NoneType]>:$Y
  );
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_OPS_TD
