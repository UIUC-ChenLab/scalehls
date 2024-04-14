//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/FlatLinearValueConstraints.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

LogicalResult
hls::ITensorType::verify(function_ref<InFlightDiagnostic()> emitError,
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
  return success();
}

/// Infer and return the integral shape of the full tensor this stream type
/// represents.
SmallVector<int64_t> hls::ITensorType::getShape() const {
  FlatLinearConstraints cstr;
  SmallVector<AffineExpr> iterSizeExprs;
  for (auto [tripCount, step] :
       llvm::zip(getIterTripCounts(), getIterSteps())) {
    auto pos = cstr.appendDimVar();
    cstr.addBound(presburger::BoundType::LB, pos, 0);
    cstr.addBound(presburger::BoundType::UB, pos, tripCount - 1);
    iterSizeExprs.push_back(getAffineDimExpr(pos, getContext()) * step);
  }

  auto dimSizeMap =
      getIterMap().replaceDimsAndSymbols(iterSizeExprs, {}, getIterRank(), 0);

  SmallVector<int64_t> shape;
  for (auto [dimSizeExpr, elementDimSize] :
       llvm::zip(dimSizeMap.getResults(), getElementShape())) {
    auto dimSizePos = cstr.appendDimVar();
    auto result =
        cstr.addBound(presburger::BoundType::EQ, dimSizePos,
                      AffineMap::get(getIterRank() + 1, 0, dimSizeExpr));
    assert(succeeded(result) && "failed to add dim size equality constraint");

    auto maybeLb =
        cstr.getConstantBound64(presburger::BoundType::LB, dimSizePos);
    auto maybeUb =
        cstr.getConstantBound64(presburger::BoundType::UB, dimSizePos);
    assert(maybeLb.has_value() && maybeUb.has_value() && maybeLb.value() == 0 &&
           "failed to infer dim size lower and/or upper bounds");
    shape.push_back(maybeUb.value() + elementDimSize);
    cstr.removeVar(dimSizePos);
  }
  return shape;
}

/// Return whether this stream type represents a projected permutation
/// iteration pattern.
bool hls::ITensorType::iterationIsProjectedPermutation() const {
  auto map = getIterMap();
  if (map.getNumSymbols() > 0)
    return false;

  SmallVector<bool, 8> seen(map.getNumInputs(), false);
  // A projected permutation can have, at most, only one instance of each input
  // dimension in the result expressions.
  for (auto expr : map.getResults()) {
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
  // Results are either dims or zeros and zeros can be mapped to input dims.
  return true;
}

/// Return whether this stream type represents a non-overlapped and non-gapped
/// tiling pattern.
bool hls::ITensorType::tileIsRegular() const {
  if (!iterationIsProjectedPermutation())
    return false;

  SmallVector<AffineExpr> iterShape;
  for (auto step : getIterSteps())
    iterShape.push_back(getAffineConstantExpr(step, getContext()));
  auto iterShapeMap = getIterMap().replaceDimsAndSymbols(iterShape, {}, 0, 0);

  for (auto [index, iterDimSize] : llvm::enumerate(iterShapeMap.getResults())) {
    auto constIterDimSize = llvm::cast<AffineConstantExpr>(iterDimSize);
    if (constIterDimSize.getValue() != getElementDimSize(index) &&
        constIterDimSize.getValue() != 0)
      return false;
  }
  return true;
}

/// Return whether the "other" stream type is castable with this type.
bool hls::ITensorType::isCastableWith(ITensorType other) const {
  if (getDataType() != other.getDataType())
    return false;
  if (getShape() != other.getShape())
    return false;
  return true;
}

/// Return whether this stream type can be converted to the "tensor" type.
bool hls::ITensorType::isConvertableWith(RankedTensorType tensor,
                                         bool packing) const {
  if (!tensor.hasStaticShape())
    return false;
  if (getDataType() != tensor.getElementType())
    return false;

  SmallVector<int64_t> tensorShape(tensor.getShape());
  if (packing) {
    auto unpackedType = getUnpackedType(tensor, getElementShape());
    tensorShape = SmallVector<int64_t>(unpackedType.getRank(), 1);
    tensorShape.append(unpackedType.getShape().begin(),
                       unpackedType.getShape().end());
  }
  if (getShape() != tensorShape)
    return false;
  return true;
}

LogicalResult
hls::StreamType::verify(function_ref<InFlightDiagnostic()> emitError,
                        Type elementType, int64_t depth) {
  if (llvm::isa<ShapedType>(elementType))
    return emitError() << "element type must be a scalar";
  if (depth <= 0)
    return emitError() << "depth must be positive";
  return success();
}
