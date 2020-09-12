//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD
#define SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD

include "mlir/IR/OpBase.td"

def HLSCppDialect : Dialect {
  let name = "hlscpp";
  let summary = "An HLSCpp out-of-tree MLIR dialect.";
  let description = [{
    This dialect is designed for HLS-specific C++ operations, attributes, and
    types. Operations in this dialect can be emitted as optimization directives
    decorated C++ code, which is fully synthesizable for commercial HLS tools,
    such as Vivado HLS.
  }];
  let cppNamespace = "hlscpp";
}

class HLSCppOp<string mnemonic, list<OpTrait> traits = []> :
    Op<HLSCppDialect, mnemonic, traits>;

include "Ops.td"

#endif // SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD
