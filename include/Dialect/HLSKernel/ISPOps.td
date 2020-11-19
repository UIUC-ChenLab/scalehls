//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_ISPOPS_TD
#define SCALEHLS_DIALECT_HLSKERNEL_ISPOPS_TD

def CpOp : HLSKernelOp<"cp", [HLSKernelOpInterface]> {
  let summary = "camera pipeline operation";
}

def SobelOp : HLSKernelOp<"sobel", [HLSKernelOpInterface]> {
  let summary = "sobel operation";
}

def HarrisOp : HLSKernelOp<"harris", [HLSKernelOpInterface]> {
  let summary = "harris operation";
}

def DeblurOp : HLSKernelOp<"deblur", [HLSKernelOpInterface]> {
  let summary = "deblur operation";
}

def UpsampleOp : HLSKernelOp<"upsample", [HLSKernelOpInterface]> {
  let summary = "upsample operation";
}

def DownsampleOp : HLSKernelOp<"downsample", [HLSKernelOpInterface]> {
  let summary = "downsample operation";
}

#endif // SCALEHLS_DIALECT_HLSKERNEL_ISPOPS_TD
