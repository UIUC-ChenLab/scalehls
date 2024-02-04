//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Support/MathExtras.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

LogicalResult
hls::StreamType::verify(function_ref<InFlightDiagnostic()> emitError,
                        Type elementType, ArrayRef<int64_t> iterTripCounts,
                        ArrayRef<int64_t> iterSteps, AffineMapAttr iterMap,
                        int64_t depth) {
  if (iterMap.getAffineMap().getNumSymbols())
    return emitError() << "iteration map cannot have symbols";
  if (iterTripCounts.size() != iterMap.getAffineMap().getNumDims())
    return emitError() << "iteration space trip counts and map mismatch";
  if (iterTripCounts.size() != iterSteps.size())
    return emitError() << "iteration space trip counts and steps mismatch";

  if (auto shapedElementType = llvm::dyn_cast<ShapedType>(elementType)) {
    if (!shapedElementType.hasStaticShape())
      return emitError() << "element type must have static shape";
    if (iterMap.getAffineMap().getNumResults() != shapedElementType.getRank())
      return emitError() << "iteration map and element type rank mismatch";
  }
  return success();
}

/// Clone this type with the given shape and element type. If the provided
/// shape is `std::nullopt`, the current shape of the type is used.
StreamType hls::StreamType::cloneWith(std::optional<ArrayRef<int64_t>> shape,
                                      Type elementType) const {
  return StreamType::get(getContext(), elementType, shape ? *shape : getShape(),
                         getIterSteps(), getIterMap(), getDepth());
}

/// Return the iteration trip counts of this stream type.
SmallVector<int64_t> hls::StreamType::getIterBounds() const {
  // Note that the verifier has ensured that the iteration bounds are
  // divisible by the iteration steps.
  SmallVector<int64_t> iterBounds;
  for (auto [tripCount, step] : llvm::zip(getIterTripCounts(), getIterSteps()))
    iterBounds.push_back(tripCount * step);
  return iterBounds;
}

/// Infer and return the integral shape this stream type represents.
SmallVector<int64_t> hls::StreamType::getIntegralShape() const {
  SmallVector<AffineExpr> iterSizes;
  for (auto [tripCount, step] : llvm::zip(getIterTripCounts(), getIterSteps()))
    iterSizes.push_back(
        getAffineConstantExpr((tripCount - 1) * step, getContext()));
  auto iterSizeMap =
      getIterMap().getAffineMap().replaceDimsAndSymbols(iterSizes, {}, 0, 0);
  auto shapedElementType = llvm::dyn_cast<ShapedType>(getElementType());

  SmallVector<int64_t> integralShape;
  for (auto [index, iterSize] : llvm::enumerate(iterSizeMap.getResults())) {
    auto constIterSize = llvm::dyn_cast<AffineConstantExpr>(iterSize);
    assert(constIterSize && "non-constant size in the iteration layout");

    if (!shapedElementType)
      integralShape.push_back(constIterSize.getValue());
    else
      integralShape.push_back(constIterSize.getValue() +
                              shapedElementType.getDimSize(index));
  }
  return integralShape;
}

/// Return whether the "other" stream type is compatible with this stream
/// type. By being compatible, it means that the two stream types have the
/// element type and iteration order, but not necessarily the same iteration
/// shape and layout.
bool hls::StreamType::isCompatibleWith(StreamType other) const {
  if (*this == other)
    return true;
  return false;
}

/// Return whether this stream type can be converted to the "tensor" type.
bool hls::StreamType::isConvertableWith(RankedTensorType tensor) const {
  if (!tensor.hasStaticShape())
    return false;

  if (auto shapedElementType = llvm::dyn_cast<ShapedType>(getElementType())) {
    if (tensor.getElementType() != shapedElementType.getElementType())
      return false;
    if (tensor.getRank() != shapedElementType.getRank())
      return false;
  } else if (tensor.getElementType() != getElementType()) {
    return false;
  }

  if (tensor.getShape() != ArrayRef<int64_t>(getIntegralShape()))
    return false;
  return true;
}
