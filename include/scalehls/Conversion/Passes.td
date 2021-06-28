//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_CONVERSION_PASSES_TD
#define SCALEHLS_CONVERSION_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// SCF2Affine Raising passes
//===----------------------------------------------------------------------===//

def SCFForRaising : Pass<"raise-scf-for", "FuncOp"> {
  let summary = "Raise SCF ForOps to Affine ForOps";
  let description = [{
    This raise-affine-for pass will check whether each scf.for op can be converted to affine.for op and convert it if it can.
  }];

  let constructor = "mlir::scalehls::createRaiseSCFForPass()";

}

def LoadStoreRaising : Pass<"raise-memref-ops", "FuncOp"> {
  let summary = "Raise MemoryOps (load & store) to Affine MemoryOps";
  let description = [{
    This raise-affine-for pass will check whether each memref.load or memref.store op can be converted to affine.load or affine.store op and convert it if it can.
  }];

  let constructor = "mlir::scalehls::createRaiseLoadStorePass()";
}

//===----------------------------------------------------------------------===//
// HLSKernel and HLSCpp Conversion passes
//===----------------------------------------------------------------------===//

def LegalizeToHLSCpp : Pass<"legalize-to-hlscpp", "FuncOp"> {
  let summary = "Convert to emittable MLIR code";
  let description = [{
    This legalize-to-hlscpp pass will legalize the input IR to make it
    emittable. Meanwhile, this pass will set some default pragmas for the
    convenience of the subsequent transforms and analysis.
  }];

  let constructor = "mlir::scalehls::createLegalizeToHLSCppPass()";

  let options = [
    Option<"topFunc", "top-func", "std::string", /*default=*/"\"main\"",
           "The top function for HLS synthesis">
  ];
}

def HLSKernelToAffine : Pass<"hlskernel-to-affine", "FuncOp"> {
  let summary = "Convert HLSKernel operation to Affine loops";
  let description = [{
    This hlskernel-to-affine pass converts HLSKernel operations to their Affine
    level representations.
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

//===----------------------------------------------------------------------===//
// Onnx Kernel Legalization Pass
//===----------------------------------------------------------------------===//

def QuantizeOnnx : Pass<"quantize-onnx", "FuncOp"> {
  let summary = "Quantize DNN model to integer representation";
  let description = [{
    This pass will quantize all inputs, weights, and outputs to 8-bits int and
    quantize bias and intermediate accumulation results to 32-bits int.
  }];

  let constructor = "mlir::scalehls::createQuantizeOnnxPass()";
}

#endif // SCALEHLS_CONVERSION_PASSES_TD
