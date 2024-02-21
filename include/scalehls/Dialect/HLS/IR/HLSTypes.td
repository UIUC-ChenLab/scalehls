//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSTYPES_TD
#define SCALEHLS_DIALECT_HLS_HLSTYPES_TD

include "scalehls/Dialect/HLS/IR/HLSAttributes.td"
include "mlir/IR/BuiltinTypeInterfaces.td"

class HLSType<string name, list<Trait> traits = [],
              string baseCppClass = "::mlir::Type">
    : TypeDef<HLSDialect, name, traits, baseCppClass> {
  let mnemonic = ?;
}

class IterativeType<string name, list<Trait> traits = []>
    : HLSType<name, !listconcat(traits, [IterativeTypeInterface])> {

  let skipDefaultBuilders = 1;
  let genVerifyDecl = 1;

  code commonExtraClassDeclaration = [{
    /// Return the rank of the iteration space.
    int64_t getIterRank() const { return getIterMap().getNumDims(); }

    /// Return the iteration bounds.
    SmallVector<int64_t> getIterBounds() const {
      return llvm::map_to_vector(llvm::zip(getIterTripCounts(), getIterSteps()),
          [](std::tuple<int64_t, int64_t> tuple) {
              return std::get<0>(tuple) * std::get<1>(tuple);
          });
    }

    /// Return the rank of the full tensor.
    int64_t getFullRank() const { return getIterMap().getNumResults(); }

    /// Infer and return the shape of the full tensor.
    SmallVector<int64_t> getFullShape() const;

    /// Return whether this type is castable with the "other" type.
    bool isCastableWith(}] # name # [{Type other) const {
      return getElementType() == other.getElementType() &&
             getFullShape() == other.getFullShape();
    }
  }];
}

//===----------------------------------------------------------------------===//
// SlidingTensorType
//===----------------------------------------------------------------------===//

def SlidingTensorType : IterativeType<"SlidingTensor"> {
  let summary = "A sliding tensor type";
  let description = [{
    Represents a sliding tensor of any data type. A sliding tensor is a "window"
    of a full tensor that is accessed in a sliding window manner. The sliding
    window is defined by the iteration space, which is represented by the
    iteration trip counts, iteration steps, and the iteration map. The iteration
    map is an affine map that maps the iteration space to the full tensor space.

    For example, a sliding tensor with type `stensor<f32 [8, 8], tripcounts
    [2, 4], steps [8, 8], (d0, d1) -> (d1, d0)>` represents a 8x8 sliding window
    of a 32x16 full tensor. The iteration space is a 2x4 grid, and the iteration
    map maps the iteration space to the full tensor space by permutating the two
    dimensions.
  }];
  let mnemonic = "stensor";

  let parameters = (ins
      "mlir::Type":$elementType, ArrayRefParameter<"int64_t">:$shape,
      ArrayRefParameter<"int64_t">:$iterTripCounts,
      ArrayRefParameter<"int64_t">:$iterSteps, "mlir::AffineMap":$iterMap);
  let assemblyFormat = [{
    `<` qualified($elementType) `[` $shape `]` `,` `tripcounts`
    `[` $iterTripCounts `]` `,` `steps` `[` $iterSteps `]` `,` $iterMap `>`
  }];

  let builders = [
    TypeBuilderWithInferredContext<(ins
        "ArrayRef<int64_t>":$shape, "mlir::Type":$elementType,
        "ArrayRef<int64_t>":$iterTripCounts, "ArrayRef<int64_t>":$iterSteps,
        "mlir::AffineMap":$iterMap), [{
      return $_get(elementType.getContext(), shape, elementType, iterTripCounts,
                   iterSteps, iterMap);
    }]>
  ];

  let extraClassDeclaration = commonExtraClassDeclaration # [{
    /// Get the rank of the sliding window.
    int64_t getRank() const { return getShape().size(); }

    /// Return the dimension size of the sliding window.
    int64_t getDimSize(unsigned dim) const { return getShape()[dim]; }

    /// Return whether the iteration map is a projected permutation.
    bool isProjectedPermutation() const;

    /// Return whether the sliding window is non-overlapped and non-gapped.
    bool isRegular() const;

    /// Get the ranked tensor type of the sliding window.
    RankedTensorType getWindowType() const {
      return RankedTensorType::get(getShape(), getElementType());
    }

    /// Return whether this type can be converted to the "tensor" type.
    bool isConvertableWith(RankedTensorType tensor) const;
  }];
}

//===----------------------------------------------------------------------===//
// StreamType
//===----------------------------------------------------------------------===//

def StreamType : IterativeType<"Stream"> {
  let summary = "An HLS stream type";
  let description = [{
    Represents a stream of any data type. A stream is a sequence of elements
    that are accessed in a streaming manner. The iteration space is represented
    by the iteration trip counts, iteration steps, and the iteration map. The
    iteration map is an affine map that maps the iteration space to the full
    tensor space.

    For example, a stream with type `stream<f32, tripcounts [2, 4, 8, 8], steps
    [8, 8, 1, 1], (d0, d1, d2, d3) -> (d1 + d2, d0 + d3)>` represents a stream
    of a 32x16 full tensor. The iteration space is a 2x4x8x8 grid, and the
    iteration map maps the iteration space to the full tensor space.
  }];
  let mnemonic = "stream";

  let parameters = (ins
      "mlir::Type":$elementType, ArrayRefParameter<"int64_t">:$iterTripCounts,
      ArrayRefParameter<"int64_t">:$iterSteps, "mlir::AffineMap":$iterMap,
      DefaultValuedParameter<"int64_t", "1">:$depth);
  let assemblyFormat = [{
    `<` qualified($elementType) `,` `tripcounts` `[` $iterTripCounts `]` `,`
    `steps` `[` $iterSteps `]` `,` $iterMap `,` $depth `>`
  }];

  let builders = [
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$iterTripCounts,
        "ArrayRef<int64_t>":$iterSteps, "mlir::AffineMap":$iterMap,
        CArg<"int64_t", "1">:$depth), [{
      return $_get(elementType.getContext(), elementType, iterTripCounts,
                   iterSteps, iterMap, depth);
    }]>
  ];

  let extraClassDeclaration = commonExtraClassDeclaration # [{
    /// Return whether this type can be converted to the "stensor" type.
    bool isConvertableWith(SlidingTensorType stensor) const {
      return getElementType() == stensor.getElementType() &&
             getFullShape() == stensor.getFullShape();
    }
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
