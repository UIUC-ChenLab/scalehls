//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSTYPES_TD
#define SCALEHLS_DIALECT_HLS_HLSTYPES_TD

include "scalehls/Dialect/HLS/HLSAttributes.td"

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
}

def AxiType : HLSType<"Axi"> {
  let summary = "An HLS AXI interface type";
  let mnemonic = "axi";

  let parameters = (ins "mlir::Type":$elementType,
                        AxiKindParam:$kind);
  let assemblyFormat = "`<` qualified($elementType) `,` $kind `>`";
}

def BundleType : HLSType<"Bundle"> {
  let summary = "An HLS AXI bundle type";
  let mnemonic = "bundle";

  let parameters = (ins AxiKindParam:$kind);
  let assemblyFormat = "`<` $kind `>`";
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
