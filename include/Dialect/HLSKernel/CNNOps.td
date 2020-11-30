//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_CNNOPS_TD
#define SCALEHLS_DIALECT_HLSKERNEL_CNNOPS_TD

def DenseOp : HLSKernelOp<"dense", [HLSKernelOpInterface]> {
  let summary = "dense operation";
  let description = [{
    Dense layer (fully-connected layer).

    I: (N, C)
    K: (F, C)
    B: (F)
    O: (N, F)
  }];

  let arguments = (ins
    AnyMemRef:$I,
    AnyMemRef:$K,
    AnyMemRef:$B,
    AnyMemRef:$O
  );
}

def ConvOp : HLSKernelOp<"conv", [HLSKernelOpInterface]> {
  let summary = "convolution operation";
  let description = [{
    Convolutional layer.

    I: (N, C, H, W)
    K: (F, C, KH, KW)
    B: (F)
    O: (N, F, H, W)

    Strides and padding are integer attributes of the same rank as the number of
    window dimensions. The padding attribute specifies the amount of zero
    padding to be applied to the base area, which is a n-d array of (low, high)
    padding. Each pair has the low padding as the first element and the high
    padding as the second element. Using padding is equivalent to inserting
    those same zero values into the input before the convolution.
  }];

  let arguments = (ins
    AnyMemRef:$I,
    AnyMemRef:$K,
    AnyMemRef:$B,
    AnyMemRef:$O,
    OptionalAttr<I64ArrayAttr>:$strides,
    OptionalAttr<I64ElementsAttr>:$padding
  );
}

def MaxPoolOp : HLSKernelOp<"maxpool", [HLSKernelOpInterface]> {
  let summary = "max pooling operation";
  let description = [{
    Max pooling layer. Only support 2D pooling, aka dimension of kernel_shape
    attribute is 2.

    I: (N, C, H, W)
    O: (N, C, H, W)
  }];

  let arguments = (ins
    AnyMemRef:$I,
    AnyMemRef:$O,
    OptionalAttr<I64ArrayAttr>:$kernel_shape,
    OptionalAttr<I64ArrayAttr>:$strides,
    OptionalAttr<I64ElementsAttr>:$padding
  );
}

def ReluOp : HLSKernelOp<"relu", [HLSKernelOpInterface]> {
  let summary = "relu operation";
  let description = [{
    ReLU activation layer.

    I: (N, C, H, W) or (N, C)
    O: (N, C, H, W) or (N, C)
  }];

  let arguments = (ins
    AnyMemRef:$I,
    AnyMemRef:$O
  );
}

def MergeOp : HLSKernelOp<"merge", [HLSKernelOpInterface]> {
  let summary = "merge operation";
  let description = [{
    Element-wisely add I0 with I1, where I0 and I1 should have identical shape.
  }];

  let arguments = (ins
    AnyMemRef:$I0,
    AnyMemRef:$I1,
    AnyMemRef:$O
  );
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_CNNOPS_TD
