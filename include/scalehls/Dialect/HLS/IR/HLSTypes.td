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

//===----------------------------------------------------------------------===//
// StreamType
//===----------------------------------------------------------------------===//

def StreamType : HLSType<"Stream", []> {
  let summary = "An HLS stream type";
  let description = [{
    Represents a stream of any type that can be transfered between HLS modules.
  }];
  let mnemonic = "stream";

  let parameters = (ins
      "mlir::Type":$elementType,
      ArrayRefParameter<"int64_t">:$iterTripCounts,
      ArrayRefParameter<"int64_t">:$iterSteps,
      "mlir::AffineMap":$iterMap,
      DefaultValuedParameter<"int64_t", "1">:$depth);
  let assemblyFormat = [{
    `<` qualified($elementType) `,` `[` $iterTripCounts `]` `,`
    `[` $iterSteps `]` `,` $iterMap `,` $depth `>`
  }];

  let builders = [
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$iterTripCounts,
        "ArrayRef<int64_t>":$iterSteps, "mlir::AffineMap":$iterMap,
        CArg<"int64_t", "1">:$depth), [{
      return $_get(elementType.getContext(), elementType, iterTripCounts,
                   iterSteps, iterMap, depth);
    }]>,
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$iterTripCounts,
        "ArrayRef<int64_t>":$iterSteps, CArg<"int64_t", "1">:$depth), [{
      auto identityMap = AffineMap::getMultiDimIdentityMap(
          iterTripCounts.size(), elementType.getContext());
      return get(elementType, iterTripCounts, iterSteps, identityMap, depth);
    }]>,
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$iterTripCounts,
        "mlir::AffineMap":$iterMap, CArg<"int64_t", "1">:$depth), [{
      return get(elementType, iterTripCounts,
          SmallVector<int64_t>(iterTripCounts.size(), 1), iterMap, depth);
    }]>,
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$iterTripCounts,
        CArg<"int64_t", "1">:$depth), [{
      return get(elementType, iterTripCounts,
          SmallVector<int64_t>(iterTripCounts.size(), 1), depth);
    }]>
  ];

  let skipDefaultBuilders = 1;
  let genVerifyDecl = 1;

  let extraClassDeclaration = [{
    /// Return the iteration bounds.
    SmallVector<int64_t> getIterBounds() const {
      return llvm::map_to_vector(llvm::zip(getIterTripCounts(), getIterSteps()),
          [](std::tuple<int64_t, int64_t> tripCountStep) {
              return std::get<0>(tripCountStep) * std::get<1>(tripCountStep);
          });
    }

    /// Return the data type of this stream type.
    Type getDataType() const {
      if (auto shapedType = getShapedElementType())
        return shapedType.getElementType();
      return getElementType();
    }

    /// Return the integral rank of the full tensor this stream type represents.
    int64_t getRank() const { return getIterMap().getNumResults(); }

    /// Infer and return the integral shape of the full tensor this stream type
    /// represents.
    SmallVector<int64_t> getShape() const;

    /// Get the shaped element type if applicable. Return nullptr if the element
    /// type is not a shaped type.
    ShapedType getShapedElementType() const {
      return getElementType().dyn_cast<ShapedType>();
    }

    /// Get the rank of the element type. Return 0 if the element type is not a
    /// shaped type.
    int64_t getElementRank() const {
      if (auto shapedType = getShapedElementType())
        return shapedType.getRank();
      return 0;
    }

    /// Return the dimension size of the element type. Return 1 if the element
    /// type is not a shaped type.
    int64_t getElementDimSize(unsigned dim) const {
      if (auto shapedType = getShapedElementType())
        return shapedType.getDimSize(dim);
      return 1;
    }

    /// Return the shape of the element type. Return an all-1 array if the 
    /// element type is not a shaped type.
    SmallVector<int64_t> getElementShape() const {
      if (auto shapedType = getShapedElementType())
        return SmallVector<int64_t>(shapedType.getShape());
      return SmallVector<int64_t>(getIterMap().getNumResults(), 1);
    }

    /// Return whether this stream type represents an overlapped stream pattern.
    bool isOverlapped() const;

    /// Return whether the "other" stream type is castable with this type.
    bool isCastableWith(StreamType other) const;

    /// Return whether this stream type can be converted to the "tensor" type.
    bool isConvertableWith(RankedTensorType tensor) const;
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
