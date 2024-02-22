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
  auto init = getUntiledSource(extractSlice.getSource())
                  .getDefiningOp<hls::TensorInitOp>();
  if (!init)
    return emitDefaultSilenceableFailure(extractSlice)
           << "extract_slice source is not initialized by a tensor_init op";

  rewriter.setInsertionPoint(extractSlice);
  auto localInit = rewriter.replaceOpWithNewOp<hls::TensorInitOp>(
      extractSlice, extractSlice.getType(), init.getInitValue());
  results.push_back(localInit);
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
// HLSConvertInsertSliceToStreamOp
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
      // dimension when streaming.
      exprs.push_back(getAffineConstantExpr(0, target.getContext()));
    }
  }
  return AffineMap::get(loops.size(), 0, exprs, target.getContext());
}

DiagnosedSilenceableFailure
transform::HLSConvertInsertSliceToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::InsertSliceOp insertSlice,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // Check if the destination tensor of the insert_slice op has only one use,
  // which means no other operations have effect on the tensor.
  if (!insertSlice.getDest().hasOneUse())
    return emitDefaultSilenceableFailure(insertSlice)
           << "dest tensor of insert_slice has more than one use";

  // Collect the surrounding loops of the insert_slice op.
  auto untiledDest = getUntiledSource(insertSlice.getDest());
  auto loops = getSurroundingLoops(insertSlice, untiledDest.getParentBlock());
  if (loops.empty())
    return emitDefaultSilenceableFailure(insertSlice)
           << "no surrounding loops found for insert_slice";

  // Find the tensor_init op that initializes the destination tensor.
  auto tensorInit = untiledDest.getDefiningOp<hls::TensorInitOp>();
  if (!tensorInit)
    return emitDefaultSilenceableFailure(insertSlice)
           << "dest tensor is not initialized by a tensor_init op";

  // Collect the iteration shape and affine map of the sliding tensor.
  auto iterTripCounts = getLoopTripCounts(loops);
  auto iterSteps = getLoopSteps(loops);
  auto iterMap = getIterationAffineMap(insertSlice, loops);
  if (!iterTripCounts || !iterSteps || !iterMap)
    return emitDefaultSilenceableFailure(insertSlice);

  // Construct the sliding tensor type.
  auto tensorType = tensorInit.getType();
  auto sTensorType = hls::SlidingTensorType::get(
      insertSlice.getResultType().getShape(), tensorType.getElementType(),
      *iterTripCounts, *iterSteps, *iterMap);

  // Create the sliding tensor.
  auto loc = insertSlice.getLoc();
  rewriter.setInsertionPoint(loops.front());
  auto sTensorInit =
      rewriter.create<hls::SlidingTensorInitOp>(loc, sTensorType);

  // Update the loop iteration arguments.
  auto index = cast<BlockArgument>(insertSlice.getDest()).getArgNumber();
  loops.front().setOperand(index, sTensorInit.getResult());
  for (auto loop : loops) {
    loop.getRegionIterArg(index).setType(sTensorType);
    loop.getResult(index).setType(sTensorType);
  }

  // Create the stensor_push op.
  rewriter.setInsertionPoint(insertSlice);
  auto sTensorPush = rewriter.create<hls::SlidingTensorPushOp>(
      loc, sTensorType, insertSlice.getDest(), insertSlice.getSource());
  rewriter.replaceOp(insertSlice, sTensorPush.getResult());

  // Create the stream_to_tensor op.
  rewriter.setInsertionPointAfter(loops.front());
  auto sTensorResult = loops.front().getResult(index);
  auto tensorResult = rewriter.create<hls::SlidingTensorToTensorOp>(
      loc, tensorType, sTensorResult);
  rewriter.replaceUsesWithIf(
      sTensorResult, tensorResult.getTensor(),
      [&](OpOperand &use) { return use.getOwner() != tensorResult; });

  rewriter.replaceOp(insertSlice, insertSlice.getDest());
  results.push_back(sTensorInit);
  results.push_back(sTensorPush);
  results.push_back(tensorResult);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertExtractSliceToStreamOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::HLSConvertExtractSliceToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp extractSlice,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // // Collect the surrounding loops of the extract_slice op.
  // auto loops = getSurroundingLoops(extractSlice,
  //                                  extractSlice.getSource().getParentBlock());

  // // Collect the iteration shape and affine map of the streaming channel.
  // auto iterTripCounts = getLoopTripCounts(loops);
  // auto iterSteps = getLoopSteps(loops);
  // auto iterMap = getIterationAffineMap(extractSlice, loops);
  // if (!iterTripCounts || !iterSteps || !iterMap)
  //   return emitDefaultSilenceableFailure(extractSlice);

  // // Create the tensor_to_stream op.
  // rewriter.setInsertionPointAfterValue(extractSlice.getSource());
  // auto channelType = hls::StreamType::get(
  //     extractSlice.getResultType(), *iterTripCounts, *iterSteps, *iterMap,
  //     extractSlice.getSourceType().getNumElements());
  // auto channel = rewriter.create<hls::TensorToStreamOp>(
  //     rewriter.getUnknownLoc(), channelType, extractSlice.getSource());

  // // Create the stream_read op.
  // rewriter.setInsertionPoint(extractSlice);
  // auto channelRead = rewriter.create<hls::StreamReadOp>(
  //     rewriter.getUnknownLoc(), extractSlice.getResultType(), channel);

  // // Create the stream_to_tensor op.
  // rewriter.replaceAllUsesWith(extractSlice.getResult(),
  //                             channelRead.getResult());
  // results.push_back(channel);
  // results.push_back(channelRead);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertExpandShapeToStreamOp
//===----------------------------------------------------------------------===//

LogicalResult transform::HLSConvertExpandShapeToStreamOp::verify() {
  return success();
}

/// Given the low-ranked and high-ranked tensor types, and the resulting
/// low-ranked and high-ranked element shapes, this function constructs the
/// low-ranked and high-ranked stream types.
template <typename OpTy>
static std::optional<std::pair<hls::StreamType, hls::StreamType>>
getReassociateStreamTypes(OpTy reassociateOp, RankedTensorType lowType,
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

  // Collect the iteration shape and affine map of the streaming channel.
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

  // Construct the low stream type.
  auto lowIterMap = AffineMap::get(lowIterTripCounts.size(), 0, lowIterExprs,
                                   reassociateOp.getContext());
  auto lowElementType =
      RankedTensorType::get(lowElementShape, lowType.getElementType());
  auto lowStreamType =
      hls::StreamType::get(lowElementType, lowIterTripCounts, lowIterSteps,
                           lowIterMap, lowType.getNumElements());

  // Construct the high stream type.
  auto highIterMap = AffineMap::get(highIterTripCounts.size(), 0, highIterExprs,
                                    reassociateOp.getContext());
  auto highElementType =
      RankedTensorType::get(highElementShape, highType.getElementType());
  auto highStreamType =
      hls::StreamType::get(highElementType, highIterTripCounts, highIterSteps,
                           highIterMap, highType.getNumElements());

  return std::make_pair(lowStreamType, highStreamType);
}

DiagnosedSilenceableFailure
transform::HLSConvertExpandShapeToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExpandShapeOp expandShape,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // // Construct the source and result stream types.
  // auto streamTypes = getReassociateStreamTypes(
  //     expandShape, expandShape.getSrcType(), expandShape.getResultType(),
  //     getInputElementShape(), getOutputElementShape());
  // if (!streamTypes)
  //   return emitDefaultSilenceableFailure(expandShape);

  // // Convert the expand_shape op to stream ops and replace its uses.
  // auto loc = expandShape.getLoc();
  // rewriter.setInsertionPoint(expandShape);
  // auto sourceStream = rewriter.create<hls::TensorToStreamOp>(
  //     loc, streamTypes->first, expandShape.getSrc());
  // auto streamReassociate = rewriter.create<hls::StreamReassociateOp>(
  //     loc, streamTypes->second, sourceStream, /*expandShape=*/true,
  //     expandShape.getReassociation(), /*expandIteration=*/true,
  //     expandShape.getReassociation());
  // auto resultTensor = rewriter.create<hls::StreamToTensorOp>(
  //     loc, expandShape.getResultType(), streamReassociate);
  // rewriter.replaceAllUsesWith(expandShape, resultTensor);

  // results.push_back(sourceStream);
  // results.push_back(streamReassociate);
  // results.push_back(resultTensor);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertCollapseShapeToStreamOp
//===----------------------------------------------------------------------===//

LogicalResult transform::HLSConvertCollapseShapeToStreamOp::verify() {
  return success();
}

DiagnosedSilenceableFailure
transform::HLSConvertCollapseShapeToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter,
    tensor::CollapseShapeOp collapseShape,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // // Construct the source and result stream types.
  // auto streamTypes = getReassociateStreamTypes(
  //     collapseShape, collapseShape.getResultType(),
  //     collapseShape.getSrcType(), getOutputElementShape(),
  //     getInputElementShape());
  // if (!streamTypes)
  //   return emitDefaultSilenceableFailure(collapseShape);

  // // Convert the expand_shape op to stream ops and replace its uses.
  // auto loc = collapseShape.getLoc();
  // rewriter.setInsertionPoint(collapseShape);
  // auto sourceStream = rewriter.create<hls::TensorToStreamOp>(
  //     loc, streamTypes->second, collapseShape.getSrc());
  // auto streamReassociate = rewriter.create<hls::StreamReassociateOp>(
  //     loc, streamTypes->first, sourceStream, /*expandShape=*/false,
  //     collapseShape.getReassociation(), /*expandIteration=*/false,
  //     collapseShape.getReassociation());
  // auto resultTensor = rewriter.create<hls::StreamToTensorOp>(
  //     loc, collapseShape.getResultType(), streamReassociate);
  // rewriter.replaceAllUsesWith(collapseShape, resultTensor);

  // results.push_back(sourceStream);
  // results.push_back(streamReassociate);
  // results.push_back(resultTensor);
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
