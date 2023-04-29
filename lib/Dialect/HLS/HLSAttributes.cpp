//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Utils.h"

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
  SmallVector<int64_t, 4> actualFactors;
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
  SmallVector<int64_t, 4> factors;
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

//===----------------------------------------------------------------------===//
// Tile layout attribute utils.
//===----------------------------------------------------------------------===//

TileLayoutAttr hls::getTileLayout(Operation *op) {
  return op->getAttrOfType<TileLayoutAttr>("tile_layout");
}
void hls::setTileLayout(Operation *op, TileLayoutAttr tileLayout) {
  op->setAttr("tile_layout", tileLayout);
}
void hls::setTileLayout(Operation *op, ArrayRef<int64_t> tileShape,
                        ArrayRef<int64_t> vectorShape) {
  auto tileLayout =
      TileLayoutAttr::get(op->getContext(), tileShape, vectorShape);
  setTileLayout(op, tileLayout);
}
void hls::setTileLayout(Operation *op, ArrayRef<int64_t> tileShape) {
  auto tileLayout = TileLayoutAttr::get(op->getContext(), tileShape);
  setTileLayout(op, tileLayout);
}

TileLayoutAttr hls::getTileLayout(Value memref) {
  if (auto buffer = findBuffer(memref)) {
    if (auto bufferArg = buffer.dyn_cast<BlockArgument>()) {
      if (auto func =
              dyn_cast<func::FuncOp>(bufferArg.getOwner()->getParentOp()))
        return func.getArgAttrOfType<TileLayoutAttr>(bufferArg.getArgNumber(),
                                                     "hls.tile_layout");
    } else if (auto bufferOp = buffer.getDefiningOp<hls::BufferLikeInterface>())
      return getTileLayout(bufferOp);
  }
  return TileLayoutAttr();
}
void hls::setTileLayout(Value memref, TileLayoutAttr tileLayout) {
  if (auto buffer = findBuffer(memref)) {
    if (auto bufferArg = buffer.dyn_cast<BlockArgument>()) {
      if (auto func =
              dyn_cast<func::FuncOp>(bufferArg.getOwner()->getParentOp()))
        func.setArgAttr(bufferArg.getArgNumber(), "hls.tile_layout",
                        tileLayout);
    } else if (auto bufferOp = buffer.getDefiningOp<hls::BufferLikeInterface>())
      setTileLayout(bufferOp, tileLayout);
  }
}
void hls::setTileLayout(Value memref, ArrayRef<int64_t> tileShape,
                        ArrayRef<int64_t> vectorShape) {
  auto tileLayout =
      TileLayoutAttr::get(memref.getContext(), tileShape, vectorShape);
  setTileLayout(memref, tileLayout);
}
void hls::setTileLayout(Value memref, ArrayRef<int64_t> tileShape) {
  auto tileLayout = TileLayoutAttr::get(memref.getContext(), tileShape);
  setTileLayout(memref, tileLayout);
}

//===----------------------------------------------------------------------===//
// HLS resource and timing attributes
//===----------------------------------------------------------------------===//

/// Timing attribute utils.
TimingAttr hls::getTiming(Operation *op) {
  return op->getAttrOfType<TimingAttr>("timing");
}
void hls::setTiming(Operation *op, TimingAttr timing) {
  assert(timing.getBegin() <= timing.getEnd() && "invalid timing attribute");
  op->setAttr("timing", timing);
}
void hls::setTiming(Operation *op, int64_t begin, int64_t end, int64_t latency,
                    int64_t minII) {
  auto timing = TimingAttr::get(op->getContext(), begin, end, latency, minII);
  setTiming(op, timing);
}

/// Resource attribute utils.
ResourceAttr hls::getResource(Operation *op) {
  return op->getAttrOfType<ResourceAttr>("resource");
}
void hls::setResource(Operation *op, ResourceAttr resource) {
  op->setAttr("resource", resource);
}
void hls::setResource(Operation *op, int64_t lut, int64_t dsp, int64_t bram) {
  auto resource = ResourceAttr::get(op->getContext(), lut, dsp, bram);
  setResource(op, resource);
}

/// Loop information attribute utils.
LoopInfoAttr hls::getLoopInfo(Operation *op) {
  return op->getAttrOfType<LoopInfoAttr>("loop_info");
}
void hls::setLoopInfo(Operation *op, LoopInfoAttr loopInfo) {
  op->setAttr("loop_info", loopInfo);
}
void hls::setLoopInfo(Operation *op, int64_t flattenTripCount,
                      int64_t iterLatency, int64_t minII) {
  auto loopInfo =
      LoopInfoAttr::get(op->getContext(), flattenTripCount, iterLatency, minII);
  setLoopInfo(op, loopInfo);
}

//===----------------------------------------------------------------------===//
// HLS directive attributes
//===----------------------------------------------------------------------===//

/// Loop directives attribute utils.
LoopDirectiveAttr hls::getLoopDirective(Operation *op) {
  return op->getAttrOfType<LoopDirectiveAttr>("loop_directive");
}
void hls::setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective) {
  op->setAttr("loop_directive", loopDirective);
}
void hls::setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                           bool dataflow, bool flatten) {
  auto loopDirective = LoopDirectiveAttr::get(op->getContext(), pipeline,
                                              targetII, dataflow, flatten);
  setLoopDirective(op, loopDirective);
}

/// Parrallel and point loop attribute utils.
void hls::setParallelAttr(Operation *op) {
  op->setAttr("parallel", UnitAttr::get(op->getContext()));
}
bool hls::hasParallelAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("parallel");
}
void hls::setPointAttr(Operation *op) {
  op->setAttr("point", UnitAttr::get(op->getContext()));
}
bool hls::hasPointAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("point");
}

/// Function directives attribute utils.
FuncDirectiveAttr hls::getFuncDirective(Operation *op) {
  return op->getAttrOfType<FuncDirectiveAttr>("func_directive");
}
void hls::setFuncDirective(Operation *op, FuncDirectiveAttr funcDirective) {
  op->setAttr("func_directive", funcDirective);
}
void hls::setFuncDirective(Operation *op, bool pipeline, int64_t targetInterval,
                           bool dataflow) {
  auto funcDirective = FuncDirectiveAttr::get(op->getContext(), pipeline,
                                              targetInterval, dataflow);
  setFuncDirective(op, funcDirective);
}

/// Top and runtime function attribute utils.
void hls::setTopFuncAttr(Operation *op) {
  op->setAttr("top_func", UnitAttr::get(op->getContext()));
}
bool hls::hasTopFuncAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("top_func");
}
void hls::setRuntimeAttr(Operation *op) {
  op->setAttr("runtime", UnitAttr::get(op->getContext()));
}
bool hls::hasRuntimeAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("runtime");
}
