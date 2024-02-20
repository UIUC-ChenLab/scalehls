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
    InterfaceMethod<"Return the depth of the buffer", "int32_t",
                    "getBufferDepth">,
    InterfaceMethod<"Return the initial value of the buffer",
                    "std::optional<mlir::TypedAttr>", "getBufferInitValue">,
  ];
}

def ContainerLikeInterface : OpInterface<"ContainerLikeInterface"> {
  let description = [{
    This interface is used to represent containers, including dispatch, task,
    schedule, and node.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [    
    InterfaceMethod<"Return body region of the stage",
      "mlir::Region &", "getBody", (ins), "return $_op.getBody();">,
    InterfaceMethod<"Check whether the stage has hierarchy",
      "bool", "hasHierarchy", (ins), [{
        return $_op.walk([&](ContainerLikeInterface stage) {
          if (stage != $_op)
            return WalkResult::interrupt();
          return WalkResult::advance();
        }).wasInterrupted();
      }]>,
    InterfaceMethod<"Return whether the value is a stage livein",
                    "bool", "isLivein", (ins "mlir::Value":$value)>,
    InterfaceMethod<"Return the liveins of the stage",
                    "llvm::SmallVector<mlir::Value>", "getLiveins">,
    InterfaceMethod<"Return the internal users of a stage livein",
                    "llvm::SmallVector<mlir::Operation *>", "getLiveinUsers",
                    (ins "mlir::Value":$livein)>,
  ];
}

#endif // SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
