//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_HLSKERNEL_TD
#define SCALEHLS_DIALECT_HLSKERNEL_HLSKERNEL_TD

include "mlir/IR/OpBase.td"

def HLSKernelDialect : Dialect {
  let name = "hlskernel";
  let summary = "A HLSKernel out-of-tree MLIR dialect";
  let description = [{
    This dialect contains a set of frequently used high-level operations (e.g.
    convolution, relu, pooling, etc.) which can be lowered to Standard/Affine
    dialect for benchmarking the estimation and optimization of HLS techiques.
  }];
  let cppNamespace = "::mlir::scalehls::hlskernel";
}

class HLSKernelOp<string mnemonic, list<OpTrait> traits = []> :
    Op<HLSKernelDialect, mnemonic, traits>;

include "Ops.td"

#endif // SCALEHLS_DIALECT_HLSKERNEL_HLSKERNEL_TD
