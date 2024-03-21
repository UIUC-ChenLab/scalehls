//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
#define SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD

include "mlir/IR/OpBase.td"

def ITensorReadLikeOpInterface : OpInterface<"ITensorReadLikeOpInterface"> {
  let description = [{
    This interface is used to represent read-like itensor operations. Read-like
    operations must have a `source` itensor argument.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [
    InterfaceMethod<"Return the source itensor.",
      "TypedValue<ITensorType>", "getSource", (ins), [{
        return $_op.getSource();
      }]>
  ];

  let extraSharedClassDeclaration = [{
    ITensorType getSourceType() { return $_op.getSource().getType(); }
  }];
}

def ITensorWriteLikeOpInterface : OpInterface<"ITensorWriteLikeOpInterface"> {
  let description = [{
    This interface is used to represent write-like itensor operations. Write-
    like operations must have a `dest` itensor argument and a `result` itensor
    result, representing the writing behavior in a destination style.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [
    InterfaceMethod<"Return the destination itensor.",
      "TypedValue<ITensorType>", "getDest", (ins), [{
        return $_op.getDest();
      }]>,
    InterfaceMethod<"Return the result itensor.",
      "TypedValue<ITensorType>", "getResult", (ins), [{
        return $_op.getResult();
      }]>
  ];

  let extraSharedClassDeclaration = [{
    ITensorType getDestType() { return $_op.getDest().getType(); }
    ITensorType getResultType() { return $_op.getResult().getType(); }
  }];
}

def ITensorViewLikeOpInterface : OpInterface<"ITensorViewLikeOpInterface"> {
  let description = [{
    This interface is used to represent view-like itensor operations. View-like
    operations must have a `source` itensor argument and a `result` itensor
    result.
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
          $_op.getSource().template getDefiningOp<ITensorViewLikeOpInterface>())
        if (prevView.getSourceType() == getResultType())
          return prevView.getSource();
      return {};
    }

    ITensorViewLikeOpInterface
    cloneWith(Value source, PatternRewriter &rewriter) {
      IRMapping mapping;
      mapping.map($_op.getSource(), source);
      return cast<ITensorViewLikeOpInterface>(rewriter.clone(*$_op, mapping));
    }
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
