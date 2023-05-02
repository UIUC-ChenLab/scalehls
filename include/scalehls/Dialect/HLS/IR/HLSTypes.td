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

def TypeParamType : HLSType<"TypeParam"> {
  let summary = "Used to represent a type parameter";
  let mnemonic = "uip.type_param";
}

def ValueParamType : HLSType<"ValueParam"> {
  let summary = "Used to represent a static or dynamic value parameter";
  let mnemonic = "uip.value_param";
}

def PortType : HLSType<"Port"> {
  let summary = "Used to represent an input/output";
  let mnemonic = "uip.port";
}

def IPIdentifierType : HLSType<"IPIdentifier"> {
  let summary = "An IP identifier type";
  let mnemonic = "uip.ip";

  let parameters = (ins IPLibraryParam:$library, IPNameParam:$name);
  let assemblyFormat = "`<` $library `_` $name `>`";
}

def MemoryKindType : HLSType<"MemoryKind"> {
  let summary = "A memory kind type";
  let mnemonic = "ubuf.mem";

  let parameters = (ins MemoryKindParam:$kind);
  let assemblyFormat = "`<` $kind `>`";
}

def StreamType : HLSType<"Stream"> {
  let summary = "An HLS stream type";
  let description = [{
    Represents a stream of any type that can be transfered between HLS modules.
    This type is equal to the hls::stream<> type in Xilinx Vivado HLS.
  }];
  let mnemonic = "ubuf.stream";

  let parameters = (ins "mlir::Type":$elementType, "unsigned":$depth);
  let assemblyFormat = "`<` qualified($elementType) `,` $depth `>`";
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
