//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/TransformOps/HLSTransformOps.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/ViewLikeInterfaceUtils.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/SCF/Transforms/TileUsingInterface.h"
#include "mlir/Dialect/SCF/Utils/Utils.h"
#include "mlir/Dialect/Transform/IR/TransformDialect.h"
#include "mlir/Dialect/Transform/IR/TransformInterfaces.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;
using namespace affine;

//===----------------------------------------------------------------------===//
// HLSConvertExtractSliceToTensorInitOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::HLSConvertExtractSliceToTensorInitOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp extractSlice,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  auto untiledOperand = getUntiledOperand(&extractSlice.getSourceMutable());
  auto tensorInit = untiledOperand->get().getDefiningOp<hls::TensorInitOp>();
  if (!tensorInit)
    return emitDefaultSilenceableFailure(extractSlice)
           << "untiled operand must be defined by a tensor.init op";

  rewriter.setInsertionPoint(extractSlice);
  auto localTensorInit = rewriter.replaceOpWithNewOp<hls::TensorInitOp>(
      extractSlice, extractSlice.getType(), tensorInit.getInitValue());
  results.push_back(localTensorInit);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertFillToTensorInitOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::HLSConvertFillToTensorInitOp::applyToOne(
    transform::TransformRewriter &rewriter, linalg::FillOp fill,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  auto tensorInit = rewriter.replaceOpWithNewOp<hls::TensorInitOp>(
      fill, fill.result().getType(), fill.value());
  results.push_back(tensorInit);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSMergeConsecutiveExtractSliceOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::HLSMergeConsecutiveExtractSliceOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp extractSlice,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  auto prevExtractSlice =
      extractSlice.getSource().getDefiningOp<tensor::ExtractSliceOp>();
  SmallVector<OpFoldResult> newOffsets, newSizes, newStrides;
  if (!prevExtractSlice ||
      failed(affine::mergeOffsetsSizesAndStrides(
          rewriter, extractSlice.getLoc(), prevExtractSlice, extractSlice,
          prevExtractSlice.getDroppedDims(), newOffsets, newSizes,
          newStrides))) {
    results.push_back(extractSlice);
    return DiagnosedSilenceableFailure::success();
  }

  auto newExtractSlice = rewriter.replaceOpWithNewOp<tensor::ExtractSliceOp>(
      extractSlice, extractSlice.getType(), prevExtractSlice.getSource(),
      newOffsets, newSizes, newStrides);
  results.push_back(newExtractSlice);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertInsertSliceToITensorWriteOp
//===----------------------------------------------------------------------===//

static scf::ForOp getAssociatedLoop(Value value) {
  if (auto arg = dyn_cast<BlockArgument>(value))
    if (auto loop = dyn_cast<scf::ForOp>(arg.getOwner()->getParentOp()))
      if (value == loop.getInductionVar())
        return loop;
  return nullptr;
}

static std::optional<size_t>
getLoopIndex(Value value, const SmallVectorImpl<scf::ForOp> &loops) {
  if (auto loop = getAssociatedLoop(value)) {
    size_t loopIndex = std::distance(loops.begin(), llvm::find(loops, loop));
    if (loopIndex != loops.size())
      return loopIndex;
  }
  return std::nullopt;
}

template <typename OpTy>
static std::optional<AffineMap>
getIterationAffineMap(OpTy target, const SmallVector<scf::ForOp> &loops) {
  SmallVector<AffineExpr> exprs;
  for (auto offset : target.getMixedOffsets()) {
    if (auto offsetValue = offset.template dyn_cast<Value>()) {
      if (auto apply = offsetValue.template getDefiningOp<AffineApplyOp>()) {
        // Here, we need to handle the case where the offset is defined by an
        // affine.apply op.
        SmallVector<AffineExpr> repDims;
        for (auto operand : apply.getOperands()) {
          auto loopIndex = getLoopIndex(operand, loops);
          if (!loopIndex)
            return std::nullopt;
          repDims.push_back(getAffineDimExpr(*loopIndex, target.getContext()));
        }
        exprs.push_back(apply.getAffineMap().getResult(0).replaceDims(repDims));
      } else {
        auto loopIndex = getLoopIndex(offsetValue, loops);
        if (!loopIndex)
          return std::nullopt;
        exprs.push_back(getAffineDimExpr(*loopIndex, target.getContext()));
      }
    } else {
      // If the offset is a constant, it means we don't need to iterate over the
      // dimension when iterating.
      exprs.push_back(getAffineConstantExpr(0, target.getContext()));
    }
  }
  return AffineMap::get(loops.size(), 0, exprs, target.getContext());
}

DiagnosedSilenceableFailure
transform::HLSConvertInsertSliceToITensorWriteOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::InsertSliceOp insertSlice,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // Check if the destination tensor of the insert_slice op has only one use,
  // which means no other operations have effect on the tensor.
  if (!insertSlice.getDest().hasOneUse())
    return emitDefaultSilenceableFailure(insertSlice)
           << "destination tensor must have only one use";

  // Collect the untiled operand and surrounding loops of the insert_slice op.
  auto untiledOperand = getUntiledOperand(&insertSlice.getDestMutable());
  auto loops =
      getSurroundingLoops(insertSlice, untiledOperand->get().getParentBlock());
  if (loops.empty())
    return emitDefaultSilenceableFailure(insertSlice)
           << "no surrounding loops found";

  // The untiled operand must be defined by a tensor.init op.
  auto tensorInit = untiledOperand->get().getDefiningOp<hls::TensorInitOp>();
  if (!tensorInit)
    return emitDefaultSilenceableFailure(insertSlice)
           << "untiled operand must be defined by a tensor.init op";

  // Collect the iteration shape and affine map of the iterative tensor.
  auto iterTripCounts = getLoopTripCounts(loops);
  auto iterSteps = getLoopSteps(loops);
  auto iterMap = getIterationAffineMap(insertSlice, loops);
  if (!iterTripCounts || !iterSteps || !iterMap)
    return emitDefaultSilenceableFailure(insertSlice)
           << "trip counts, steps, or iteration map can be determined";

  auto iTensorType = hls::ITensorType::get(
      insertSlice.getSourceType(), *iterTripCounts, *iterSteps, *iterMap,
      insertSlice.getDestType().getNumElements());

  // Create the iterative tensor.
  auto loc = insertSlice.getLoc();
  rewriter.setInsertionPoint(loops.front());
  auto sourceITensor = rewriter.create<hls::ITensorInitOp>(loc, iTensorType);
  rewriter.replaceUsesWithIf(
      tensorInit.getResult(), sourceITensor.getResult(),
      [&](OpOperand &operand) { return operand.getOwner() == loops.front(); });

  // Create the itensor_to_tensor op.
  rewriter.setInsertionPointAfter(loops.front());
  auto resultTensor = loops.front().getTiedLoopResult(untiledOperand);
  auto iTensorToTensor = rewriter.create<hls::ITensorReadFullTensorOp>(
      loc, resultTensor.getType(), resultTensor, tensorInit);
  rewriter.replaceAllUsesExcept(resultTensor, iTensorToTensor, iTensorToTensor);

  // Update the iteration argument of the loops.
  auto iterIdx = untiledOperand->getOperandNumber();
  for (auto loop : loops) {
    auto &iterOperand = loop->getOpOperand(iterIdx);
    auto iterType = iterOperand.get().getType();
    rewriter.updateRootInPlace(loop, [&]() {
      loop.getTiedLoopRegionIterArg(&iterOperand).setType(iterType);
      loop.getTiedLoopResult(&iterOperand).setType(iterType);
    });
  }

  // Replace the insert_slice op with itensor_write op.
  rewriter.setInsertionPoint(insertSlice);
  auto writeInit = loops.back().getTiedLoopRegionIterArg(
      &loops.back()->getOpOperand(iterIdx));
  auto iTensorWrite = rewriter.create<hls::ITensorWriteOp>(
      loc, iTensorType, insertSlice.getSource(), writeInit);
  rewriter.replaceAllUsesWith(
      loops.back().getTiedLoopYieldedValue(writeInit)->get(),
      iTensorWrite.getResult());
  rewriter.eraseOp(insertSlice);

  results.push_back(sourceITensor);
  results.push_back(iTensorWrite);
  results.push_back(iTensorToTensor);
  return DiagnosedSilenceableFailure::success();
}
// xixi
// haha
// S2

//===----------------------------------------------------------------------===//
// HLSConvertExtractSliceToITensorReadOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::HLSConvertExtractSliceToITensorReadOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp extractSlice,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // Collect the surrounding loops of the extract_slice op.
  auto loops = getSurroundingLoops(extractSlice,
                                   extractSlice.getSource().getParentBlock());
  if (loops.empty())
    return emitDefaultSilenceableFailure(extractSlice)
           << "no surrounding loops found";

  // Collect the iteration shape and affine map of the iterative tensor.
  auto iterTripCounts = getLoopTripCounts(loops);
  auto iterSteps = getLoopSteps(loops);
  auto iterMap = getIterationAffineMap(extractSlice, loops);
  if (!iterTripCounts || !iterSteps || !iterMap)
    return emitDefaultSilenceableFailure(extractSlice)
           << "trip counts, steps, or iteration map can be determined";

  auto iTensorType = hls::ITensorType::get(
      extractSlice.getResultType(), *iterTripCounts, *iterSteps, *iterMap,
      extractSlice.getSourceType().getNumElements());

  // Create the tensor_to_itensor op.
  auto loc = extractSlice.getLoc();
  rewriter.setInsertionPoint(loops.front());
  auto iTensorInit = rewriter.create<hls::ITensorInitOp>(loc, iTensorType);
  auto tensorToITensor = rewriter.create<hls::ITensorWriteFullTensorOp>(
      loc, iTensorType, extractSlice.getSource(), iTensorInit);

  // Create the itensor_read op.
  rewriter.setInsertionPoint(extractSlice);
  auto sliceInit =
      rewriter.create<hls::TensorInitOp>(loc, extractSlice.getResultType());
  auto iTensorRead = rewriter.create<hls::ITensorReadOp>(
      loc, extractSlice.getResultType(), tensorToITensor.getResult(),
      sliceInit);
  rewriter.replaceOp(extractSlice, iTensorRead.getResult());

  results.push_back(tensorToITensor);
  results.push_back(iTensorRead);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertExpandShapeToITensorReassociateOp
//===----------------------------------------------------------------------===//

LogicalResult transform::HLSConvertExpandShapeToITensorReassociateOp::verify() {
  // TODO: Verify whether the input/output element shapes are valid.
  return success();
}

/// Given the low-ranked and high-ranked tensor types, and the resulting
/// low-ranked and high-ranked element shapes, this function constructs the
/// low-ranked and high-ranked iTensor types.
template <typename OpTy>
static std::optional<std::pair<hls::ITensorType, hls::ITensorType>>
getReassociateITensorTypes(OpTy reassociateOp, RankedTensorType lowType,
                           RankedTensorType highType,
                           ArrayRef<int64_t> lowElementShape,
                           ArrayRef<int64_t> highElementShape) {
  // The low and high types must have static shapes.
  if (!lowType.hasStaticShape() || !highType.hasStaticShape())
    return std::nullopt;

  SmallVector<int64_t> lowIterTripCounts, lowIterSteps;
  SmallVector<AffineExpr> lowIterExprs;
  SmallVector<int64_t> highIterTripCounts, highIterSteps;
  SmallVector<AffineExpr> highIterExprs;

  // Collect the iteration shape and affine map of the iterative tensor.
  for (auto [lowDim, highDims] :
       llvm::enumerate(reassociateOp.getReassociationIndices())) {
    auto lowDimSize = lowType.getDimSize(lowDim);
    auto lowElementDimSize = lowElementShape[lowDim];
    if (lowDimSize % lowElementDimSize != 0)
      return std::nullopt;

    lowIterTripCounts.push_back(lowDimSize / lowElementDimSize);
    lowIterSteps.push_back(lowElementDimSize);
    lowIterExprs.push_back(
        getAffineDimExpr(lowDim, reassociateOp.getContext()));

    for (auto [index, highDim] : llvm::enumerate(highDims)) {
      auto highDimSize = highType.getDimSize(highDim);
      auto highElementDimSize = highElementShape[highDim];
      if (highDimSize % highElementDimSize != 0)
        return std::nullopt;

      highIterTripCounts.push_back(highDimSize / highElementDimSize);
      highIterSteps.push_back(highElementDimSize);
      highIterExprs.push_back(
          getAffineDimExpr(highDim, reassociateOp.getContext()));
    }
  }

  // Construct the low iTensor type.
  auto lowIterMap = AffineMap::get(lowIterTripCounts.size(), 0, lowIterExprs,
                                   reassociateOp.getContext());
  auto lowElementType =
      RankedTensorType::get(lowElementShape, lowType.getElementType());
  auto lowITensorType =
      hls::ITensorType::get(lowElementType, lowIterTripCounts, lowIterSteps,
                            lowIterMap, lowType.getNumElements());

  // Construct the high iTensor type.
  auto highIterMap = AffineMap::get(highIterTripCounts.size(), 0, highIterExprs,
                                    reassociateOp.getContext());
  auto highElementType =
      RankedTensorType::get(highElementShape, highType.getElementType());
  auto highITensorType =
      hls::ITensorType::get(highElementType, highIterTripCounts, highIterSteps,
                            highIterMap, highType.getNumElements());

  return std::make_pair(lowITensorType, highITensorType);
}

DiagnosedSilenceableFailure
transform::HLSConvertExpandShapeToITensorReassociateOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExpandShapeOp expandShape,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // Construct the source and result iTensor types.
  auto iTensorTypes = getReassociateITensorTypes(
      expandShape, expandShape.getSrcType(), expandShape.getResultType(),
      getInputElementShape(), getOutputElementShape());
  if (!iTensorTypes)
    return emitDefaultSilenceableFailure(expandShape);

  // Convert the expand_shape op to iTensor ops and replace its uses.
  auto loc = expandShape.getLoc();
  rewriter.setInsertionPoint(expandShape);
  auto iTensorInit =
      rewriter.create<hls::ITensorInitOp>(loc, iTensorTypes->first);
  auto tensorToITensor = rewriter.create<hls::ITensorWriteFullTensorOp>(
      loc, iTensorTypes->first, expandShape.getSrc(), iTensorInit);
  auto iTensorReassociate = rewriter.create<hls::ITensorReassociateOp>(
      loc, iTensorTypes->second, tensorToITensor.getResult(),
      /*expandShape=*/true, expandShape.getReassociation(),
      /*expandIteration=*/true, expandShape.getReassociation());
  auto tensorInit =
      rewriter.create<hls::TensorInitOp>(loc, expandShape.getResultType());
  auto iTensorToTensor = rewriter.create<hls::ITensorReadFullTensorOp>(
      loc, expandShape.getResultType(), iTensorReassociate.getResult(),
      tensorInit);
  rewriter.replaceOp(expandShape, iTensorToTensor);

  results.push_back(tensorToITensor);
  results.push_back(iTensorReassociate);
  results.push_back(iTensorToTensor);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertCollapseShapeToITensorReassociateOp
//===----------------------------------------------------------------------===//

LogicalResult
transform::HLSConvertCollapseShapeToITensorReassociateOp::verify() {
  // TODO: Verify whether the input/output element shapes are valid.
  return success();
}

DiagnosedSilenceableFailure
transform::HLSConvertCollapseShapeToITensorReassociateOp::applyToOne(
    transform::TransformRewriter &rewriter,
    tensor::CollapseShapeOp collapseShape,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // Construct the source and result iTensor types.
  auto iTensorTypes = getReassociateITensorTypes(
      collapseShape, collapseShape.getResultType(), collapseShape.getSrcType(),
      getOutputElementShape(), getInputElementShape());
  if (!iTensorTypes)
    return emitDefaultSilenceableFailure(collapseShape);

  // Convert the expand_shape op to iTensor ops and replace its uses.
  auto loc = collapseShape.getLoc();
  rewriter.setInsertionPoint(collapseShape);
  auto iTensorInit =
      rewriter.create<hls::ITensorInitOp>(loc, iTensorTypes->second);
  auto tensorToITensor = rewriter.create<hls::ITensorWriteFullTensorOp>(
      loc, iTensorTypes->second, collapseShape.getSrc(), iTensorInit);
  auto iTensorReassociate = rewriter.create<hls::ITensorReassociateOp>(
      loc, iTensorTypes->first, tensorToITensor.getResult(),
      /*expandShape=*/false, collapseShape.getReassociation(),
      /*expandIteration=*/false, collapseShape.getReassociation());
  auto tensorInit =
      rewriter.create<hls::TensorInitOp>(loc, collapseShape.getResultType());
  auto iTensorToTensor = rewriter.create<hls::ITensorReadFullTensorOp>(
      loc, collapseShape.getResultType(), iTensorReassociate.getResult(),
      tensorInit);
  rewriter.replaceOp(collapseShape, iTensorToTensor);

  results.push_back(tensorToITensor);
  results.push_back(iTensorReassociate);
  results.push_back(iTensorToTensor);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// Transform op registration
//===----------------------------------------------------------------------===//

namespace {
class HLSTransformDialectExtension
    : public transform::TransformDialectExtension<
          HLSTransformDialectExtension> {
public:
  using Base::Base;

  void init() {
    declareGeneratedDialect<linalg::LinalgDialect>();
    declareGeneratedDialect<scf::SCFDialect>();
    declareGeneratedDialect<tensor::TensorDialect>();
    declareGeneratedDialect<hls::HLSDialect>();

    registerTransformOps<
#define GET_OP_LIST
#include "scalehls/Dialect/HLS/TransformOps/HLSTransformOps.cpp.inc"
        >();
  }
};
} // namespace

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/TransformOps/HLSTransformOps.cpp.inc"

void scalehls::hls::registerTransformDialectExtension(
    DialectRegistry &registry) {
  registry.addExtensions<HLSTransformDialectExtension>();
}
