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

def StreamType : HLSType<"Stream", [ShapedTypeInterface]> {
  let summary = "An HLS stream type";
  let description = [{
    Represents a stream of any type that can be transfered between HLS modules.
  }];
  let mnemonic = "stream";

  let parameters = (ins
      "mlir::Type":$elementType,
      ArrayRefParameter<"int64_t">:$iterTripCounts,
      ArrayRefParameter<"int64_t">:$iterSteps,
      "mlir::AffineMapAttr":$iterMap,
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
                   iterSteps, AffineMapAttr::get(iterMap), depth);
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

  let genVerifyDecl = 1;

  let extraClassDeclaration = [{
    /// Returns if this type is ranked.
    bool hasRank() const { return true; }

    /// Returns the shape of this type. For stream types, we consider the
    /// iteration trip counts as the shape.
    ArrayRef<int64_t> getShape() const { return getIterTripCounts(); }

    /// Clone this type with the given shape and element type. If the provided
    /// shape is `std::nullopt`, the current shape of the type is used.
    StreamType cloneWith(std::optional<ArrayRef<int64_t>> shape,
                         Type elementType) const;

    using ShapedType::Trait<StreamType>::getElementTypeBitWidth;
    using ShapedType::Trait<StreamType>::getRank;
    using ShapedType::Trait<StreamType>::getNumElements;
    using ShapedType::Trait<StreamType>::getDimSize;

    /// Return the iteration bounds of this stream type.
    SmallVector<int64_t> getIterBounds() const;

    /// Infer and return the integral shape this stream type represents.
    SmallVector<int64_t> getIntegralShape() const;

    /// Return whether the "other" stream type is compatible with this stream
    /// type. By being compatible, it means that the two stream types have the
    /// element type and iteration order, but not necessarily the same iteration
    /// shape and layout.
    bool isCompatibleWith(StreamType other) const;

    /// Return whether this stream type can be converted to the "tensor" type.
    bool isConvertableWith(RankedTensorType tensor) const;
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
