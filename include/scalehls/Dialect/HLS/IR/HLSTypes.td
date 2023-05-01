//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSTYPES_TD
#define SCALEHLS_DIALECT_HLS_HLSTYPES_TD

include "scalehls/Dialect/HLS/IR/HLSAttributes.td"

class HLSType<string name, list<Trait> traits = []> :
    TypeDef<HLSDialect, name, traits>;

def MemoryKindType : HLSType<"MemoryKind"> {
  let summary = "A memory kind type";
  let mnemonic = "mem";

  let parameters = (ins MemoryKindParam:$kind);
  let assemblyFormat = "`<` $kind `>`";
}

def IPIdentifierType : HLSType<"IPIdentifier"> {
  let summary = "An IP identifier type";
  let mnemonic = "ip";

  let parameters = (ins IPLibraryParam:$library, IPNameParam:$name);
  let assemblyFormat = "`<` $library `_` $name `>`";
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
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
