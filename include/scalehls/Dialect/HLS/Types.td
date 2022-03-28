//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TYPES_TD
#define SCALEHLS_DIALECT_HLS_TYPES_TD

def StreamType : HLSType<"Stream"> {
  let summary = "An HLS stream type";
  let description = [{
    Represents a stream of any type that can be transfered between HLS modules.
    This type is equal to the hls::stream<> type in Xilinx Vivado HLS.
  }];

  let mnemonic = "stream";
  let parameters = (ins
    "::mlir::Type":$elementType,
    "int64_t":$depth
  );

  let assemblyFormat = "`<` qualified($elementType) `,` $depth `>`";
}

#endif // SCALEHLS_DIALECT_HLS_TYPES_TD
