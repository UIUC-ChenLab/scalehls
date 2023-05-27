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

def TypeType : HLSType<"Type"> {
  let summary = "Used to represent a type";
  let mnemonic = "type";
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
  let mnemonic = "memory";
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
