//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD
#define SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD

include "mlir/IR/OpBase.td"

def HLSCppDialect : Dialect {
  let name = "hlscpp";
  let summary = "An HLSCpp out-of-tree MLIR dialect";
  let description = [{
    This dialect contains dedicated operations, attributes, and passes designed
    for representing HLS C++ specific structures and components in MLIR, while
    enabling comprehensive optimization for both performance and area. Passes
    in this dialect can optimize and generate IRs, which can then be translated
    to synthesizable HLS C++ code by scalehls-translate tool.
  }];
  let cppNamespace = "::mlir::scalehls::hlscpp";
}

class HLSCppOp<string mnemonic, list<OpTrait> traits = []> :
    Op<HLSCppDialect, mnemonic, traits>;

include "Ops.td"

#endif // SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD
