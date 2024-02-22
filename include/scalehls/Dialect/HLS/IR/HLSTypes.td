//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSTYPES_TD
#define SCALEHLS_DIALECT_HLS_HLSTYPES_TD

include "scalehls/Dialect/HLS/IR/HLSInterfaces.td"
include "scalehls/Dialect/HLS/IR/HLSAttributes.td"
include "mlir/IR/BuiltinTypeInterfaces.td"

class HLSType<string name, list<Trait> traits = [],
              string baseCppClass = "::mlir::Type">
    : TypeDef<HLSDialect, name, traits, baseCppClass> {
  let mnemonic = ?;
}

//===----------------------------------------------------------------------===//
// SlidingType
//===----------------------------------------------------------------------===//

class SlidingType<string name, list<Trait> traits = []>
    : HLSType<name, !listconcat(traits, [
        DeclareTypeInterfaceMethods<SlidingTypeInterface>]), "::mlir::Type"> {

  let parameters = (ins "mlir::Type":$elementType,
      ArrayRefParameter<"int64_t">:$shape,
      ArrayRefParameter<"int64_t">:$iterTripCounts,
      ArrayRefParameter<"int64_t">:$iterSteps, "mlir::AffineMap":$iterMap);
  let assemblyFormat = [{
    `<` qualified($elementType) `[` $shape `]` `,` `tripcounts`
    `[` $iterTripCounts `]` `,` `steps` `[` $iterSteps `]` `,` $iterMap `>`
  }];

  let builders = [
    TypeBuilderWithInferredContext<(ins "ArrayRef<int64_t>":$shape,
        "mlir::Type":$elementType, "ArrayRef<int64_t>":$iterTripCounts,
        "ArrayRef<int64_t>":$iterSteps, "mlir::AffineMap":$iterMap), [{
      return $_get(elementType.getContext(), elementType, shape, iterTripCounts,
                   iterSteps, iterMap);
    }]>
  ];

  let skipDefaultBuilders = 1;
  let genVerifyDecl = 1;
}

//===----------------------------------------------------------------------===//
// SlidingTensor/MemrefType
//===----------------------------------------------------------------------===//

def SlidingTensorType : SlidingType<"SlidingTensor"> {
  let summary = "A sliding tensor type";
  let mnemonic = "stensor";

  let extraClassDeclaration = [{
    /// Get the ranked tensor type of the window.
    RankedTensorType getWindowType() const {
      return RankedTensorType::get(getShape(), getElementType());
    }

    /// Return whether this type can be converted to the "tensor" type.
    bool isConvertableWith(RankedTensorType tensor) const {
      return tensor.hasStaticShape() &&
             getElementType() == tensor.getElementType() &&
             ArrayRef<int64_t>(getFullShape()) == tensor.getShape();
    }

    /// Return whether this type can be casted to the "other" type.
    bool isCastableWith(SlidingTensorType other) const {
      return getElementType() == other.getElementType() &&
             getFullShape() == other.getFullShape();
    }
  }];
}

def SlidingMemrefType : SlidingType<"SlidingMemref"> {
  let summary = "A sliding memref type";
  let mnemonic = "smemref";

  let extraClassDeclaration = [{
    /// Get the memref type of the window.
    MemRefType getWindowType() const {
      return MemRefType::get(getShape(), getElementType());
    }

    /// Return whether this type can be converted to the "stensor" type.
    bool isConvertableWith(SlidingTensorType stensor) const {
      return getElementType() == stensor.getElementType() &&
             getFullShape() == stensor.getFullShape();
    }
  
    /// Return whether this type can be casted to the "other" type.
    bool isCastableWith(SlidingMemrefType other) const {
      return getElementType() == other.getElementType() &&
             getFullShape() == other.getFullShape();
    }
  }];
}

//===----------------------------------------------------------------------===//
// StreamType
//===----------------------------------------------------------------------===//

def StreamType : HLSType<"Stream"> {
  let summary = "An HLS stream type";
  let description = [{
    Represents a stream of any data type. Stream is corresponding to the FIFO
    channel in the hardware. The depth of the stream is the number of elements
    that can be stored in the FIFO channel.
  }];
  let mnemonic = "stream";

  let parameters = (ins "mlir::Type":$elementType, 
      DefaultValuedParameter<"int64_t", "1">:$depth);
  let assemblyFormat = "`<` qualified($elementType) `,` $depth `>`";

  let builders = [
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType, CArg<"int64_t", "1">:$depth), [{
      return $_get(elementType.getContext(), elementType, depth);
    }]>
  ];
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
