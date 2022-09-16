//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_INTERFACES_TD
#define SCALEHLS_DIALECT_HLS_INTERFACES_TD

include "mlir/IR/OpBase.td"

def BufferLikeInterface : OpInterface<"BufferLikeInterface"> {
  let description = [{
    This interface is used to represent dataflow buffers.
  }];

  let methods = [
    InterfaceMethod<
      "Return the memref result of the buffer",
      "mlir::Value", "getMemref", (ins), [{ return $_op.memref(); }]
    >,
    InterfaceMethod<
      "Return the memref type of the buffer",
      "mlir::MemRefType", "getMemrefType", (ins), [{
        return $_op.memref().getType().template cast<mlir::MemRefType>();
      }]
    >,
  ];
}

#endif // SCALEHLS_DIALECT_HLS_INTERFACES_TD