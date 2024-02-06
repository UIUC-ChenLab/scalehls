//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Support/MathExtras.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static bool isProjectedPermutation(AffineMap map) {
  if (map.getNumSymbols() > 0)
    return false;

  SmallVector<bool, 8> seen(map.getNumInputs(), false);
  // A projected permutation can have, at most, only one instance of each input
  // dimension in the result expressions.
  for (auto expr : map.getResults()) {
    if (auto dim = dyn_cast<AffineDimExpr>(expr)) {
      if (seen[dim.getPosition()])
        return false;
      seen[dim.getPosition()] = true;
    } else {
      auto constExpr = dyn_cast<AffineConstantExpr>(expr);
      if (!constExpr || constExpr.getValue() != 0)
        return false;
    }
  }
  // Results are either dims or zeros and zeros can be mapped to input dims.
  return true;
}

LogicalResult
hls::StreamType::verify(function_ref<InFlightDiagnostic()> emitError,
                        Type elementType, ArrayRef<int64_t> iterTripCounts,
                        ArrayRef<int64_t> iterSteps, AffineMap iterMap,
                        int64_t depth) {
  if (iterMap.getNumSymbols())
    return emitError() << "iteration map cannot have symbols";
  if (iterTripCounts.size() != iterMap.getNumDims())
    return emitError() << "iteration space trip counts and map mismatch";
  if (iterTripCounts.size() != iterSteps.size())
    return emitError() << "iteration space trip counts and steps mismatch";

  if (auto shapedElementType = llvm::dyn_cast<ShapedType>(elementType)) {
    if (!shapedElementType.hasStaticShape())
      return emitError() << "element type must have static shape";
    if (iterMap.getNumResults() != shapedElementType.getRank())
      return emitError() << "iteration map and element type rank mismatch";
  }

  // For now, we ONLY allow the iteration map to be a projected permutation.
  // This means any complicated memory access patterns are not supported yet.
  if (!isProjectedPermutation(iterMap))
    return emitError() << "iteration map must be a projected permutation";
  return success();
}

/// Clone this type with the given shape and element type. If the provided
/// shape is `std::nullopt`, the current shape of the type is used.
StreamType hls::StreamType::cloneWith(std::optional<ArrayRef<int64_t>> shape,
                                      Type elementType) const {
  return StreamType::get(elementType, shape ? *shape : getShape(),
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
  auto iterSizeMap = getIterMap().replaceDimsAndSymbols(iterSizes, {}, 0, 0);
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

/// Return whether this stream type represents a projected stream pattern.
/// For example, for an array of:
///   [[1, 2],
///    [3, 4]]
/// A traversing of [1, 3, 2, 4] is non-projected, while a traversing of
/// [1, 3, 1, 3, 2, 4, 2, 4] is projected.
bool hls::StreamType::isProjected() const {
  // As long as every input dimension is appeared in the iteration map, the
  // stream is non-projected. Otherwise, it means the some input dimension is
  // the projected.
  return llvm::any_of(llvm::seq(getIterMap().getNumDims()),
                      [&](int i) { return !getIterMap().isFunctionOfDim(i); });
}

/// Return whether this stream type represents a permuted stream pattern.
/// For example, for an array of:
///   [[1, 2],
///    [3, 4]]
/// A traversing of [1, 2, 1, 2, 3, 4, 3, 4] is non-permuted, while a traversing
/// of [1, 3, 1, 3, 2, 4, 2, 4] is permuted.
bool hls::StreamType::isPermuted() const {
  SmallVector<unsigned> positions;
  for (auto expr : getIterMap().getResults())
    if (auto dim = llvm::dyn_cast<AffineDimExpr>(expr))
      positions.push_back(dim.getPosition());
  return !llvm::is_sorted(positions);
}

/// Return whether this stream type represents an overlapped stream pattern.
bool hls::StreamType::isOverlapped() const {
  SmallVector<AffineExpr> iterShape;
  for (auto step : getIterSteps())
    iterShape.push_back(getAffineConstantExpr(step, getContext()));
  auto iterShapeMap = getIterMap().replaceDimsAndSymbols(iterShape, {}, 0, 0);
  auto shapedElementType = llvm::dyn_cast<ShapedType>(getElementType());

  for (auto [index, iterDimSize] : llvm::enumerate(iterShapeMap.getResults())) {
    auto constIterDimSize = llvm::dyn_cast<AffineConstantExpr>(iterDimSize);
    assert(constIterDimSize && "non-constant size in the iteration layout");
    auto elementDimSize =
        shapedElementType ? shapedElementType.getDimSize(index) : 1;
    if (constIterDimSize.getValue() != elementDimSize)
      return true;
  }
  return false;
}

/// Return whether the "other" stream type is castable with this stream type. By
/// being castable, it means that the two stream types have the element type and
/// iteration order, but not necessarily the same iteration shape and layout.
bool hls::StreamType::isCastableWith(StreamType other) const {
  if (*this == other)
    return true;
  if (getElementType() == other.getElementType() &&
      getIntegralShape() == other.getIntegralShape())
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
