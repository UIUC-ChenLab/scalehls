//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// SlidingTypeInterface
//===----------------------------------------------------------------------===//

/// Return the iteration bounds.
SmallVector<int64_t> SlidingTypeInterface::getIterBounds() const {
  SmallVector<int64_t> iterBounds;
  for (auto [tripCount, step] : llvm::zip(getIterTripCounts(), getIterSteps()))
    iterBounds.push_back(tripCount * step);
  return iterBounds;
}

/// Infer and return the shape of the full tensor.
SmallVector<int64_t> SlidingTypeInterface::getFullShape() const {
  SmallVector<AffineExpr> iterSizes;
  for (auto [tripCount, step] : llvm::zip(getIterTripCounts(), getIterSteps()))
    iterSizes.push_back(
        getAffineConstantExpr((tripCount - 1) * step, getContext()));
  auto iterSizeMap = getIterMap().replaceDimsAndSymbols(iterSizes, {}, 0, 0);

  SmallVector<int64_t> fullShape;
  for (auto [index, iterSize] : llvm::enumerate(iterSizeMap.getResults())) {
    auto constIterSize = llvm::cast<AffineConstantExpr>(iterSize);
    fullShape.push_back(constIterSize.getValue() + getDimSize(index));
  }
  return fullShape;
}

/// Return whether the iteration map is a projected permutation.
bool SlidingTypeInterface::isProjectedPermutation() const {
  if (getIterMap().getNumSymbols() > 0)
    return false;

  SmallVector<bool, 8> seen(getIterMap().getNumInputs(), false);
  // A projected permutation can have, at most, only one instance of each input
  // dimension in the result expressions.
  for (auto expr : getIterMap().getResults()) {
    if (auto dim = llvm::dyn_cast<AffineDimExpr>(expr)) {
      if (seen[dim.getPosition()])
        return false;
      seen[dim.getPosition()] = true;
    } else {
      auto constExpr = llvm::dyn_cast<AffineConstantExpr>(expr);
      if (!constExpr || constExpr.getValue() != 0)
        return false;
    }
  }
  return true;
}

/// Return whether the window is non-overlapped and non-gapped.
bool SlidingTypeInterface::isRegular() const {
  if (!isProjectedPermutation())
    return false;

  SmallVector<AffineExpr> iterShape;
  for (auto step : getIterSteps())
    iterShape.push_back(getAffineConstantExpr(step, getContext()));
  auto iterShapeMap = getIterMap().replaceDimsAndSymbols(iterShape, {}, 0, 0);

  for (auto [index, iterDimSize] : llvm::enumerate(iterShapeMap.getResults())) {
    auto constIterDimSize = llvm::dyn_cast<AffineConstantExpr>(iterDimSize);
    assert(constIterDimSize && "non-constant size in the iteration map");
    if (constIterDimSize.getValue() != getDimSize(index) &&
        constIterDimSize.getValue() != 0)
      return false;
  }
  return true;
}

//===----------------------------------------------------------------------===//
// SlidingTensorType
//===----------------------------------------------------------------------===//

LogicalResult
hls::SlidingTensorType::verify(function_ref<InFlightDiagnostic()> emitError,
                               Type elementType, ArrayRef<int64_t> shape,
                               ArrayRef<int64_t> iterTripCounts,
                               ArrayRef<int64_t> iterSteps, AffineMap iterMap) {
  if (iterMap.getNumSymbols())
    return emitError() << "iteration map cannot have symbols";
  if (iterTripCounts.size() != iterMap.getNumDims())
    return emitError() << "iteration space trip counts and map mismatch";
  if (iterTripCounts.size() != iterSteps.size())
    return emitError() << "iteration space trip counts and steps mismatch";
  if (iterMap.getNumResults() != shape.size())
    return emitError() << "iteration map and sliding window rank mismatch";
  return success();
}

//===----------------------------------------------------------------------===//
// SlidingMemrefType
//===----------------------------------------------------------------------===//

LogicalResult
hls::SlidingMemrefType::verify(function_ref<InFlightDiagnostic()> emitError,
                               Type elementType, ArrayRef<int64_t> shape,
                               ArrayRef<int64_t> iterTripCounts,
                               ArrayRef<int64_t> iterSteps, AffineMap iterMap) {
  if (iterMap.getNumSymbols())
    return emitError() << "iteration map cannot have symbols";
  if (iterTripCounts.size() != iterMap.getNumDims())
    return emitError() << "iteration space trip counts and map mismatch";
  if (iterTripCounts.size() != iterSteps.size())
    return emitError() << "iteration space trip counts and steps mismatch";
  if (iterMap.getNumResults() != shape.size())
    return emitError() << "iteration map and sliding window rank mismatch";
  return success();
}
