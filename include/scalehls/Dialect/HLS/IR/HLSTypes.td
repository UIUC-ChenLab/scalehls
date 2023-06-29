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

def SpaceType : HLSType<"Space"> {
  let summary = "Represent a design space containing multiple parameters";
  let mnemonic = "space";
}

def StructType : HLSType<"Struct"> {
  let summary = "Represent a struct type";
  let mnemonic = "struct";
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

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
