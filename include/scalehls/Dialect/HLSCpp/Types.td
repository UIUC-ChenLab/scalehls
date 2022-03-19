//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_TYPES_TD
#define SCALEHLS_DIALECT_HLSCPP_TYPES_TD

def StreamType : HLSCppType<"Stream"> {
  let summary = "An HLSCpp stream type";
  let description = [{
    Represents a stream of any type that can be transfered between HLS modules.
    This type is equal to the hls::stream<> type in Xilinx Vivado HLS.
  }];

  let mnemonic = "stream";
  let parameters = (ins "::mlir::Type":$elementType);

  let assemblyFormat = "`<` qualified($elementType) `>`";
}

#endif // SCALEHLS_DIALECT_HLSCPP_TYPES_TD
