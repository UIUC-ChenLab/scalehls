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

def SpaceType : HLSType<"Space"> {
  let summary = "Represent a design space containing multiple parameters";
  let mnemonic = "space";
}

def TypeParamType : HLSType<"TypeParam"> {
  let summary = "Used to represent a type parameter";
  let mnemonic = "type_param";
}

def ValueParamType : HLSType<"ValueParam"> {
  let summary = "Used to represent a static or dynamic value parameter";
  let mnemonic = "value_param";
}

def PortType : HLSType<"Port"> {
  let summary = "Used to represent an input/output";
  let mnemonic = "port";
}

def TaskImplType : HLSType<"TaskImpl"> {
  let summary = "An IP identifier type";
  let mnemonic = "impl";
}

def MemoryKindType : HLSType<"MemoryKind"> {
  let summary = "A memory kind type";
  let mnemonic = "mem";
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
