//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSDIALECT_TD
#define SCALEHLS_DIALECT_HLS_HLSDIALECT_TD

include "mlir/IR/OpBase.td"

def HLSDialect : Dialect {
  let name = "hls";
  let summary = "An HLS out-of-tree MLIR dialect";
  let description = [{
    This dialect contains dedicated operations, types, and attributes designed
    for representing HLS-specific structures and components in MLIR, while
    enabling comprehensive optimization for both performance and area.
  }];
  let useDefaultTypePrinterParser = 1;
  let useDefaultAttributePrinterParser = 1;
  let cppNamespace = "::mlir::scalehls::hls";
}

#endif // SCALEHLS_DIALECT_HLS_HLSDIALECT_TD
