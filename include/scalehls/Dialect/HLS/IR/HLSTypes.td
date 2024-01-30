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
      ArrayRefParameter<"int64_t">:$shape,
      "mlir::MemRefLayoutAttrInterface":$iterLayout,
      "int64_t":$depth);
  let assemblyFormat = [{
    `<` qualified($elementType) `,` `[` $shape `]` `,` $iterLayout `,`
    $depth `>`
  }];

  let builders = [
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$shape,
        "mlir::MemRefLayoutAttrInterface":$iterLayout,
        CArg<"int64_t", "1">:$depth), [{
      return $_get(elementType.getContext(), elementType, shape, iterLayout,
                   depth);
    }]>,
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$shape,
        "mlir::AffineMap":$iterMap,
        CArg<"int64_t", "1">:$depth), [{
      return $_get(elementType.getContext(), elementType, shape,
                   AffineMapAttr::get(iterMap), depth);
    }]>,
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$shape,
        CArg<"int64_t", "1">:$depth), [{
      auto identityMap = AffineMapAttr::get(AffineMap::getMultiDimIdentityMap(
          shape.size(), elementType.getContext()));
      return $_get(elementType.getContext(), elementType, shape, identityMap,
                   depth);
    }]>
  ];

  let extraClassDeclaration = [{
    /// Returns if this type is ranked.
    bool hasRank() const { return true; }

    /// Clone this type with the given shape and element type. If the provided
    /// shape is `std::nullopt`, the current shape of the type is used.
    StreamType cloneWith(std::optional<ArrayRef<int64_t>> shape,
                         Type elementType) const;

    using ShapedType::Trait<StreamType>::getElementTypeBitWidth;
    using ShapedType::Trait<StreamType>::getRank;
    using ShapedType::Trait<StreamType>::getNumElements;
    using ShapedType::Trait<StreamType>::getDimSize;

    /// Return whether the "other" stream type is compatible with this stream
    /// type. By being compatible, it means that the two stream types have the
    /// element type and iteration order, but not necessarily the same iteration
    /// shape and layout. Compatible stream types can be casted to each other.
    bool isCompatibleWith(StreamType other);
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
