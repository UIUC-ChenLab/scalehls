//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSTYPES_TD
#define SCALEHLS_DIALECT_HLS_HLSTYPES_TD

include "scalehls/Dialect/HLS/IR/HLSAttributes.td"

class HLSType<string name, list<Trait> traits = [],
              string baseCppClass = "::mlir::Type">
    : TypeDef<HLSDialect, name, traits, baseCppClass> {
  let mnemonic = ?;
}

def StreamType : HLSType<"Stream"> {
  let summary = "An HLS stream type";
  let description = [{
    Represents a stream of any type that can be transfered between HLS modules.
    This type is equal to the hls::stream<> type in Xilinx Vivado HLS.
  }];
  let mnemonic = "stream";

  let parameters = (ins "mlir::Type":$elementType, "unsigned":$depth);
  let assemblyFormat = "`<` qualified($elementType) `,` $depth `>`";

  let extraClassDeclaration = [{
    static StreamType get(mlir::Type elementType, unsigned depth) {
      return get(elementType.getContext(), elementType, depth);
    }
    static StreamType get(mlir::Type elementType) {
      return get(elementType, 1);
    }
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
