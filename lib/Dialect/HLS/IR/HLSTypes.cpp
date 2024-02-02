//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

LogicalResult
hls::StreamType::verify(function_ref<InFlightDiagnostic()> emitError,
                        Type elementType, ArrayRef<int64_t> shape,
                        MemRefLayoutAttrInterface iterLayout, int64_t depth) {
  if (iterLayout.getAffineMap().getNumSymbols())
    return emitError() << "iteration layout cannot have symbols";
  if (shape.size() != iterLayout.getAffineMap().getNumDims())
    return emitError() << "shape size and iteration layout mismatch";
  if (auto shapedElementType = llvm::dyn_cast<ShapedType>(elementType)) {
    if (!shapedElementType.hasRank())
      return emitError() << "element type must be ranked";
    if (iterLayout.getAffineMap().getNumResults() !=
        shapedElementType.getRank())
      return emitError() << "iteration layout and element type rank mismatch";
  }
  return success();
}

/// Clone this type with the given shape and element type. If the provided
/// shape is `std::nullopt`, the current shape of the type is used.
StreamType hls::StreamType::cloneWith(std::optional<ArrayRef<int64_t>> shape,
                                      Type elementType) const {
  return StreamType::get(elementType, shape ? *shape : getShape(),
                         getIterLayout(), getDepth());
}

/// Infer the integral shape of the data this stream type represents.
SmallVector<int64_t> hls::StreamType::inferIntegralShape() const {
  SmallVector<AffineExpr> iterSizeInputs;
  for (auto iterSize : getShape())
    iterSizeInputs.push_back(getAffineConstantExpr(iterSize, getContext()));
  auto iterSizeMap = getIterLayout().getAffineMap().replaceDimsAndSymbols(
      iterSizeInputs, {}, 0, 0);
  auto shapedElementType = llvm::dyn_cast<ShapedType>(getElementType());

  SmallVector<int64_t> integralShape;
  for (auto [index, iterSize] : llvm::enumerate(iterSizeMap.getResults())) {
    auto constIterSize = llvm::dyn_cast<AffineConstantExpr>(iterSize);
    assert(constIterSize && "non-constant size in the iteration layout");

    if (!shapedElementType)
      integralShape.push_back(constIterSize.getValue());
    else
      integralShape.push_back(constIterSize.getValue() *
                              shapedElementType.getDimSize(index));
  }
  return integralShape;
}

/// Return whether the "other" stream type is compatible with this stream type.
/// By being compatible, it means that the two stream types have the element
/// type and iteration order, but not necessarily the same iteration shape and
/// layout.
bool hls::StreamType::isCompatibleWith(StreamType other) const {
  if (*this == other)
    return true;
  return false;
}

/// Return whether this stream type can be converted to the "tensor" type.
bool hls::StreamType::isConvertableWith(RankedTensorType tensor) const {
  if (tensor.getElementType() != getElementType())
    return false;
  if (tensor.getRank() != getRank())
    return false;
  if (llvm::any_of(llvm::zip(tensor.getShape(), getShape()), [](auto pair) {
        return std::get<0>(pair) != std::get<1>(pair);
      }))
    return false;
  return true;
}
