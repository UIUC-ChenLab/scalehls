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
    InterfaceMethod<"Return the source stream.",
      "TypedValue<StreamType>", "getSource", (ins), [{
        return $_op.getSource();
      }]>,
    InterfaceMethod<"Return the result stream.",
      "TypedValue<StreamType>", "getResult", (ins), [{
        return $_op.getResult();
      }]>
  ];

  let extraSharedClassDeclaration = [{
    StreamType getSourceType() { return $_op.getSource().getType(); }
    StreamType getResultType() { return $_op.getResult().getType(); }

    OpFoldResult foldRedundantViews() {
      if (getSourceType() == getResultType())
        return $_op.getSource();
      if (auto prevView =
          $_op.getSource().template getDefiningOp<StreamViewLikeInterface>())
        if (prevView.getSourceType() == getResultType())
          return prevView.getSource();
      return {};
    }

    StreamViewLikeInterface cloneWith(Value source) {
      IRMapping mapping;
      mapping.map($_op.getSource(), source);
      return cast<StreamViewLikeInterface>($_op->clone(mapping));
    }
  }];
}

def StreamReadLikeInterface : OpInterface<"StreamReadLikeInterface"> {
  let description = [{
    This interface is used to represent stream read operations.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [
    InterfaceMethod<"Return the stream source.",
      "TypedValue<StreamType>", "getSource", (ins), [{
        return $_op.getSource();
      }]>
  ];

  let extraSharedClassDeclaration = [{
    StreamType getSourceType() { return $_op.getSource().getType(); }
  }];
}

def StreamWriteLikeInterface : OpInterface<"StreamWriteLikeInterface"> {
  let description = [{
    This interface is used to represent stream write operations.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [
    InterfaceMethod<"Return the stream destinations.",
      "ValueRange", "getDests", (ins), [{
        return $_op.getDests();
      }]>
  ];

  let extraSharedClassDeclaration = [{
    TypedValue<StreamType> getDest(unsigned idx) {
      return cast<TypedValue<StreamType>>($_op.getDests()[idx]);
    }
    StreamType getDestType() { return getDest(0).getType(); }

    LogicalResult verifyDests() {
      if ($_op.getDests().empty())
        return $_op.emitOpError("no dest stream specified");
      for (auto dest : $_op.getDests()) {
        // TODO: Support more flexible dest streams.
        if (auto defOp = dest.getDefiningOp())
          if (!isa<StreamOp>(defOp))
            return $_op.emitOpError("dest must be defined by a stream op");
        if (dest.getType() != getDestType())
          return $_op.emitOpError("dest stream type mismatch");
      }
      return success();
    }
  }];
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
