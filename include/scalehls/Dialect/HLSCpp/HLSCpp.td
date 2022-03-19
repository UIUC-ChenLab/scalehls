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
    This dialect contains dedicated operations, types, and attributes designed
    for representing HLS C++ specific structures and components in MLIR, while
    enabling comprehensive optimization for both performance and area.
  }];
  let cppNamespace = "::mlir::scalehls::hlscpp";
}

class HLSCppType<string name> : TypeDef<HLSCppDialect, name>;

class HLSCppAttr<string name> : AttrDef<HLSCppDialect, name>;

class HLSCppOp<string mnemonic, list<Trait> traits = []> :
    Op<HLSCppDialect, mnemonic, traits>;

include "scalehls/Dialect/HLSCpp/Types.td"
include "scalehls/Dialect/HLSCpp/Attributes.td"
include "scalehls/Dialect/HLSCpp/Ops.td"

#endif // SCALEHLS_DIALECT_HLSCPP_HLSCPP_TD
