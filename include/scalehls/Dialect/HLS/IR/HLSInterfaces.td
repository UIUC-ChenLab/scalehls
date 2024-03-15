//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
#define SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD

include "mlir/IR/OpBase.td"

def ITensorViewLikeInterface : OpInterface<"ITensorViewLikeInterface"> {
  let description = [{
    This interface is used to represent itensor views.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [
    InterfaceMethod<"Return the source itensor.",
      "TypedValue<ITensorType>", "getSource", (ins), [{
        return $_op.getSource();
      }]>,
    InterfaceMethod<"Return the result itensor.",
      "TypedValue<ITensorType>", "getResult", (ins), [{
        return $_op.getResult();
      }]>
  ];

  let extraSharedClassDeclaration = [{
    ITensorType getSourceType() { return $_op.getSource().getType(); }
    ITensorType getResultType() { return $_op.getResult().getType(); }

    OpFoldResult foldRedundantViews() {
      if (getSourceType() == getResultType())
        return $_op.getSource();
      if (auto prevView =
          $_op.getSource().template getDefiningOp<ITensorViewLikeInterface>())
        if (prevView.getSourceType() == getResultType())
          return prevView.getSource();
      return {};
    }

    ITensorViewLikeInterface cloneWith(Value source, PatternRewriter &rewriter) {
      IRMapping mapping;
      mapping.map($_op.getSource(), source);
      return cast<ITensorViewLikeInterface>(rewriter.clone(*$_op, mapping));
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
