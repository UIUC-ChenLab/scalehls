//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_CNNOPS_TD
#define SCALEHLS_DIALECT_HLSKERNEL_CNNOPS_TD

def ConvOp : HLSKernelOp<"conv", [HLSKernelOpInterface]> {
  let summary = "convolution operation";
  let description = [{
    Convolution operation. For now, only static shaped 4-dims X (batch, channel,
    row, and col), 4-dims W (input channel, output channel, kernel row, and
    kernel col), 1-dim B (output channel), and 4-dims Y (batch, channel, row,
    and col) is supported. Verifiers will ensure the legalness of the operation.
  }];

  let arguments = (ins
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$X,
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$W,
    AnyTypeOf<[AnyTensor, AnyMemRef, NoneType]>:$B,
    OptionalAttr<I64ArrayAttr>:$pads,
    OptionalAttr<I64ArrayAttr>:$strides
  );
  let results = (outs
    AnyTypeOf<[AnyTensor, AnyMemRef, NoneType]>:$Y
  );
}

def MaxPoolOp : HLSKernelOp<"maxpool", [HLSKernelOpInterface]> {
  let summary = "max pooling operation";
  let description = [{
    Max pooling operation. For now, only static shaped 4-dims X (batch, channel,
    row, and col) and 4-dims Y (batch, channel, row, and col) are supported.
    Verifiers will ensure the legalness of the operation.
  }];

  let arguments = (ins
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$X,
    I64ArrayAttr:$kernel_shape,
    OptionalAttr<I64ArrayAttr>:$pads,
    OptionalAttr<I64ArrayAttr>:$strides
  );
  let results = (outs
    AnyTypeOf<[AnyTensor, AnyMemRef, NoneType]>:$Y
  );
}

def ReluOp : HLSKernelOp<"relu", [HLSKernelOpInterface]> {
  let summary = "relu operation";
  let description = [{
    ReLU operation. For now, only static shaped 4-dims X (batch, channel, row,
    and col) and 4-dims Y (batch, channel, row, and col) are supported.
    Verifiers will ensure the legalness of the operation.
  }];

  let arguments = (ins
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$X
  );
  let results = (outs
    AnyTypeOf<[AnyTensor, AnyMemRef, NoneType]>:$Y
  );
}

def DenseOp : HLSKernelOp<"dense", [HLSKernelOpInterface]> {
  let summary = "dense operation";
  let description = [{
    Dense operation. For now, only static shaped 2-dims X (batch and channel),
    2-dims W (input and output channel), 1-dim B (output channel), and 2-dims Y
    (batch and channel) are supported. Verifiers will ensure the legalness of
    the operation.
  }];

  let arguments = (ins
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$X,
    AnyTypeOf<[AnyTensor, AnyMemRef]>:$W,
    AnyTypeOf<[AnyTensor, AnyMemRef, NoneType]>:$B
  );
  let results = (outs
    AnyTypeOf<[AnyTensor, AnyMemRef, NoneType]>:$Y
  );
}

def ConcatOp : HLSKernelOp<"concat", [HLSKernelOpInterface]> {
  let summary = "concatenate operation";
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_CNNOPS_TD
