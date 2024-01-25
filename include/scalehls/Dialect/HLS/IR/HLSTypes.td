//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSTYPES_TD
#define SCALEHLS_DIALECT_HLS_HLSTYPES_TD

include "scalehls/Dialect/HLS/IR/HLSAttributes.td"

class HLSType<string name, list<Trait> traits = [],
              string baseCppClass = "::mlir::Type">
    : TypeDef<HLSDialect, name, traits, baseCppClass> {
  let mnemonic = ?;
}

def StreamType : HLSType<"Stream"> {
  let summary = "An HLS stream type";
  let description = [{
    Represents a stream of any type that can be transfered between HLS modules.
  }];
  let mnemonic = "stream";

  let parameters = (ins
      "mlir::Type":$elementType,
      ArrayRefParameter<"int64_t">:$iterShape,
      "mlir::MemRefLayoutAttrInterface":$iterLayout,
      "int64_t":$depth);
  let assemblyFormat = [{
    `<` qualified($elementType) `,` $iterShape `,` $iterLayout `,` $depth `>`
  }];

  let builders = [
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType,
        "ArrayRef<int64_t>":$iterShape,
        "mlir::MemRefLayoutAttrInterface":$iterLayout,
        CArg<"int64_t", "1">:$depth), [{
      return $_get(elementType.getContext(), elementType, iterShape, iterLayout,
                   depth);
    }]>,
    TypeBuilderWithInferredContext<(ins
        "mlir::Type":$elementType,
        "ArrayRef<int64_t>":$iterShape,
        CArg<"int64_t", "1">:$depth), [{
      auto identityMap = AffineMapAttr::get(AffineMap::getMultiDimIdentityMap(
          iterShape.size(), elementType.getContext()));
      return $_get(elementType.getContext(), elementType, iterShape,
                   identityMap, depth);
    }]>
  ];
}

#endif // SCALEHLS_DIALECT_HLS_HLSTYPES_TD
