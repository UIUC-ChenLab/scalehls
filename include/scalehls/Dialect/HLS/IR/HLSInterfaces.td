//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
#define SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD

include "mlir/IR/OpBase.td"

def SlidingTypeInterface : TypeInterface<"SlidingTypeInterface"> {
  let description = [{
    Represents a sliding tensor/buffer of any data type. A sliding tensor/buffer
    is a "window" of a full tensor/buffer that is accessed in a sliding manner.
    The window is defined by the iteration space, which is represented by the
    iteration trip counts, iteration steps, and the iteration map. The iteration
    map is an affine map that maps the iteration space to the full tensor space.

    For example, a sliding tensor/buffer with type `<f32 [8, 8], tripcounts
    [2, 4], steps [8, 8], (d0, d1) -> (d1, d0)>` represents a 8x8 window of a
    32x16 full tensor/buffer. The iteration space is a 2x4 grid, and the
    iteration map maps the iteration space to the full tensor/buffer space by
    permutating the two dimensions.
  }];
  string cppNamespace = "mlir::scalehls::hls";

  let methods = [
    InterfaceMethod<"Return the element type.",
      "Type", "getElementType">,
    InterfaceMethod<"Return the shape of the window.",
      "ArrayRef<int64_t>", "getShape">,
    InterfaceMethod<"Return the trip counts of the iteration space.",
      "ArrayRef<int64_t>", "getIterTripCounts">,
    InterfaceMethod<"Return the steps of the iteration space.",
      "ArrayRef<int64_t>", "getIterSteps">,
    InterfaceMethod<"Return the iteration map of the iteration space.",
      "AffineMap", "getIterMap">
  ];

  let extraSharedClassDeclaration = [{
    /// Get the rank of the window.
    int64_t getRank() const { return $_type.getShape().size(); }

    /// Return the dimension size of the window.
    int64_t getDimSize(unsigned dim) const { return $_type.getShape()[dim]; }

    /// Return the rank of the iteration space.
    int64_t getIterRank() const { return $_type.getIterMap().getNumDims(); }

    /// Return the iteration bounds.
    SmallVector<int64_t> getIterBounds() const;

    /// Return the rank of the full tensor.
    int64_t getFullRank() const { return $_type.getIterMap().getNumResults(); }

    /// Infer and return the shape of the full tensor.
    SmallVector<int64_t> getFullShape() const;

    /// Return whether the iteration map is a projected permutation.
    bool isProjectedPermutation() const;

    /// Return whether the window is non-overlapped and non-gapped.
    bool isRegular() const;
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
