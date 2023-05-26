//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// PartitionLayoutAttr
//===----------------------------------------------------------------------===//

AffineMap PartitionLayoutAttr::getAffineMap() const {
  auto b = Builder(getContext());
  assert(getKinds().size() == getFactors().size() &&
         "invalid partition layout");
  auto rank = getKinds().size();

  SmallVector<AffineExpr, 4> partitionIndices;
  SmallVector<AffineExpr, 4> addressIndices;

  // Compute the partition and address indices.
  for (unsigned dim = 0; dim < rank; ++dim) {
    auto kind = getKinds()[dim];
    auto factor = getFactors()[dim];

    if (kind == PartitionKind::NONE) {
      partitionIndices.push_back(b.getAffineConstantExpr(0));
      addressIndices.push_back(b.getAffineDimExpr(dim));

    } else if (kind == PartitionKind::CYCLIC) {
      partitionIndices.push_back(b.getAffineDimExpr(dim) % factor);
      addressIndices.push_back(b.getAffineDimExpr(dim).floorDiv(factor));

    } else if (kind == PartitionKind::BLOCK) {
      partitionIndices.push_back(b.getAffineDimExpr(dim).floorDiv(factor));
      addressIndices.push_back(b.getAffineDimExpr(dim) % factor);

    } else {
      partitionIndices.push_back(b.getAffineDimExpr(dim));
      addressIndices.push_back(b.getAffineConstantExpr(0));
    }
  }

  // Construct layout affine map.
  partitionIndices.append(addressIndices);
  return AffineMap::get(rank, 0, partitionIndices, getContext());
}

LogicalResult PartitionLayoutAttr::verifyLayout(
    ArrayRef<int64_t> shape,
    function_ref<InFlightDiagnostic()> emitError) const {
  if (shape.size() != getKinds().size() || shape.size() != getFactors().size())
    return emitError() << "number of memref dimensions must be equal to "
                          "number of partition kinds and factors";

  for (auto [size, kind, factor] : llvm::zip(shape, getKinds(), getFactors())) {
    if ((kind == PartitionKind::CYCLIC && size % factor != 0) ||
        (kind == PartitionKind::BLOCK && size % factor != 0))
      return emitError() << "cyclic or block partition factor must be a "
                            "divisor of memref dimension size";
    if (kind == PartitionKind::NONE && factor != 1)
      return emitError() << "none partition factor must be 1";
    if (kind == PartitionKind::COMPLETE && factor != size)
      return emitError() << "complete partition factor must be equal to "
                            "memref dimension size";
  }
  return success();
}

LogicalResult
PartitionLayoutAttr::verify(function_ref<InFlightDiagnostic()> emitError,
                            ArrayRef<PartitionKind> kinds,
                            ArrayRef<int64_t> factors) {
  if (kinds.size() != factors.size())
    return emitError() << "number of partition kinds and factors must be equal";
  if (llvm::any_of(factors, [](int64_t factor) { return factor <= 0; }))
    return emitError() << "partition factor must be positive";
  return success();
}

/// The affine map of "block" partition needs array shape to be inferenced. For
/// example, if the partition factor is [2] and the shape of the array is [16],
/// the affine map should be (d0) -> (d0 / 8, d0 % 8), where 8 is equal to 16
/// / 2. However, as the shape information is not known at the time of attribute
/// construction, we can only encode factor [8] in the attribute instead of the
/// actual factor [2]. This method returns the actual partition factor with the
/// given array shape.
SmallVector<int64_t>
PartitionLayoutAttr::getActualFactors(ArrayRef<int64_t> shape) {
  SmallVector<int64_t> actualFactors;
  for (auto [size, kind, factor] : llvm::zip(shape, getKinds(), getFactors())) {
    if (kind == PartitionKind::BLOCK)
      actualFactors.push_back((size + factor - 1) / factor);
    else
      actualFactors.push_back(factor);
  }
  return actualFactors;
}

/// This method construct a PartitionLayoutAttr with the given partition kinds,
/// actual partition factors, and array shape.
PartitionLayoutAttr PartitionLayoutAttr::getWithActualFactors(
    MLIRContext *context, ArrayRef<PartitionKind> kinds,
    ArrayRef<int64_t> actualFactors, ArrayRef<int64_t> shape) {
  SmallVector<int64_t> factors;
  for (auto [size, kind, factor] : llvm::zip(shape, kinds, actualFactors)) {
    if (kind == PartitionKind::BLOCK)
      factors.push_back((size + factor - 1) / factor);
    else
      factors.push_back(factor);
  }
  return get(context, kinds, actualFactors);
}

//===----------------------------------------------------------------------===//
// TileLayoutAttr
//===----------------------------------------------------------------------===//

AffineMap TileLayoutAttr::getAffineMap() const {
  auto b = Builder(getContext());

  SmallVector<AffineExpr> exprs;
  for (auto tileSize : llvm::enumerate(getTileShape()))
    exprs.push_back(
        b.getAffineDimExpr(tileSize.index()).floorDiv(tileSize.value()));

  for (auto [tileSize, vectorSize] :
       llvm::zip(llvm::enumerate(getTileShape()), getVectorShape()))
    exprs.push_back((b.getAffineDimExpr(tileSize.index()) % tileSize.value())
                        .floorDiv(vectorSize));

  for (auto vectorSize : llvm::enumerate(getVectorShape()))
    exprs.push_back(b.getAffineDimExpr(vectorSize.index()) %
                    vectorSize.value());

  // The verifier should have made sure that the number of memref dimensions is
  // equal to the number of tile shape dimensions.
  return AffineMap::get(getTileShape().size(), 0, exprs, getContext());
}

LogicalResult TileLayoutAttr::verifyLayout(
    ArrayRef<int64_t> shape,
    function_ref<InFlightDiagnostic()> emitError) const {
  if (shape.size() != getTileShape().size())
    return emitError() << "number of memref dimensions must be equal to number "
                          "of vector shape dimensions";
  for (auto [size, tileSize] : llvm::zip(shape, getTileShape()))
    if (size % tileSize != 0)
      return emitError() << "memref dimension size must be a multiple of "
                            "vector shape dimension size";
  return success();
}

LogicalResult
TileLayoutAttr::verify(function_ref<InFlightDiagnostic()> emitError,
                       ArrayRef<int64_t> tileShape,
                       ArrayRef<int64_t> vectorShape) {
  if (tileShape.size() != vectorShape.size())
    return emitError() << "number of dimensions in affine map must be equal to "
                          "number of vector shape dimensions";
  for (auto [tileSize, vectorSize] : llvm::zip(tileShape, vectorShape))
    if (tileSize % vectorSize != 0)
      return emitError() << "tile shape dimension size must be a multiple of "
                            "vector shape dimension size";
  return success();
}
