//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
#define SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD

include "mlir/IR/OpBase.td"

def StreamViewLikeInterface : OpInterface<"StreamViewLikeInterface"> {
  let description = [{
    This interface is used to represent stream views.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [
    InterfaceMethod<"Return the input stream",
      "TypedValue<StreamType>", "getInput", (ins), [{
        return $_op.getInput();
      }]>,
    InterfaceMethod<"Return the output stream",
      "TypedValue<StreamType>", "getOutput", (ins), [{
        return $_op.getOutput();
      }]>,
    InterfaceMethod<"Return the input stream type",
      "StreamType", "getInputType", (ins), [{
        return $_op.getInput().getType();
      }]>,
    InterfaceMethod<"Return the output stream type",
      "StreamType", "getOutputType", (ins), [{
        return $_op.getOutput().getType();
      }]>
  ];
}

def BufferLikeInterface : OpInterface<"BufferLikeInterface"> {
  let description = [{
    This interface is used to represent dataflow buffers.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [
    InterfaceMethod<"Return the memref result of the buffer",
      "mlir::Value", "getMemref", (ins), [{ return $_op.getMemref(); }]
    >,
    InterfaceMethod<"Return the memref type of the buffer",
      "mlir::MemRefType", "getMemrefType", (ins), [{
        return $_op.getMemref().getType().template cast<mlir::MemRefType>();
      }]
    >,
    InterfaceMethod<"Return the initial value of the buffer",
                    "std::optional<mlir::TypedAttr>", "getBufferInitValue">,
  ];
}

#endif // SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
