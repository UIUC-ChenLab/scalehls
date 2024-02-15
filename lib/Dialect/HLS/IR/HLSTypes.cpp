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

/// Infer and return the integral shape of the full tensor this stream type
/// represents.
SmallVector<int64_t> hls::StreamType::getShape() const {
  SmallVector<AffineExpr> iterSizes;
  for (auto [tripCount, step] : llvm::zip(getIterTripCounts(), getIterSteps()))
    iterSizes.push_back(
        getAffineConstantExpr((tripCount - 1) * step, getContext()));
  auto iterSizeMap = getIterMap().replaceDimsAndSymbols(iterSizes, {}, 0, 0);

  SmallVector<int64_t> integralShape;
  for (auto [index, iterSize] : llvm::enumerate(iterSizeMap.getResults())) {
    auto constIterSize = llvm::dyn_cast<AffineConstantExpr>(iterSize);
    assert(constIterSize && "non-constant size in the iteration map");
    integralShape.push_back(constIterSize.getValue() +
                            getElementDimSize(index));
  }
  return integralShape;
}

/// Return whether this stream type represents an overlapped stream pattern.
bool hls::StreamType::isOverlapped() const {
  SmallVector<AffineExpr> iterShape;
  for (auto step : getIterSteps())
    iterShape.push_back(getAffineConstantExpr(step, getContext()));
  auto iterShapeMap = getIterMap().replaceDimsAndSymbols(iterShape, {}, 0, 0);

  for (auto [index, iterDimSize] : llvm::enumerate(iterShapeMap.getResults())) {
    auto constIterDimSize = llvm::dyn_cast<AffineConstantExpr>(iterDimSize);
    assert(constIterDimSize && "non-constant size in the iteration map");
    if (constIterDimSize.getValue() != getElementDimSize(index) &&
        constIterDimSize.getValue() != 0)
      return true;
  }
  return false;
}

/// Return whether the "other" stream type is castable with this type.
bool hls::StreamType::isCastableWith(StreamType other) const {
  if (getDataType() != other.getDataType())
    return false;
  if (getShape() != other.getShape())
    return false;
  return true;
}

/// Return whether this stream type can be converted to the "tensor" type.
bool hls::StreamType::isConvertableWith(RankedTensorType tensor) const {
  if (!tensor.hasStaticShape())
    return false;
  if (getDataType() != tensor.getElementType())
    return false;
  if (getShape() != SmallVector<int64_t>(tensor.getShape()))
    return false;
  return true;
}
