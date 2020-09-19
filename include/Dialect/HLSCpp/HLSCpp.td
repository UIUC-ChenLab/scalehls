//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD
#define SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD

include "mlir/IR/OpBase.td"

def HLSCppDialect : Dialect {
  let name = "hlscpp";
  let summary = "An HLSCpp out-of-tree MLIR dialect";
  let description = [{
    This dialect contains dedicated operations, interfaces, and passes designed
    for representing HLS C++ specific structures and components in MLIR, while
    enabling comprehensive optimization for both performance and area. Passes
    in this dialect can optimize and generate IRs, which can be translated to
    synthesizable HLS C++ code by EmitHLSCpp tool.
  }];
  let cppNamespace = "hlscpp";
}

class HLSCppOp<string mnemonic, list<OpTrait> traits = []> :
    Op<HLSCppDialect, mnemonic, traits>;

include "PragmaOps.td"
include "ParameterOps.td"
include "StructureOps.td"

#endif // SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD
