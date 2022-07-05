//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLS_TD
#define SCALEHLS_DIALECT_HLS_HLS_TD

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/EnumAttr.td"
include "mlir/IR/OpBase.td"

def HLSDialect : Dialect {
  let name = "hls";
  let summary = "An HLS out-of-tree MLIR dialect";
  let description = [{
    This dialect contains dedicated operations, types, and attributes designed
    for representing HLS C++ specific structures and components in MLIR, while
    enabling comprehensive optimization for both performance and area.
  }];
  let cppNamespace = "::mlir::scalehls::hls";
}

class HLSType<string name> : TypeDef<HLSDialect, name>;

class HLSAttr<string name> : AttrDef<HLSDialect, name>;

class HLSOp<string mnemonic, list<Trait> traits = []> :
    Op<HLSDialect, mnemonic, traits>;

include "scalehls/Dialect/HLS/Types.td"
include "scalehls/Dialect/HLS/Attributes.td"
include "scalehls/Dialect/HLS/Ops.td"

#endif // SCALEHLS_DIALECT_HLS_HLS_TD
