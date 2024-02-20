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

static OpOperand *
getUntiledOperandAndSurroundingLoops(OpOperand *source,
                                     SmallVector<scf::ForOp> *loops = nullptr) {
  SmallVector<scf::ForOp> reverseLoops;
  while (auto arg = dyn_cast<BlockArgument>(source->get())) {
    if (auto loop = dyn_cast<scf::ForOp>(arg.getOwner()->getParentOp())) {
      source = loop.getTiedLoopInit(arg);
      reverseLoops.push_back(loop);
    } else
      break;
  }
  if (loops)
    *loops = {reverseLoops.rbegin(), reverseLoops.rend()};
  return source;
}

DiagnosedSilenceableFailure
transform::HLSConvertExtractSliceToTensorInitOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp extractSlice,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  auto untiledUse =
      getUntiledOperandAndSurroundingLoops(&extractSlice.getSourceMutable());
  auto tensorInit = untiledUse->get().getDefiningOp<hls::TensorInitOp>();
  if (!tensorInit)
    return emitDefaultSilenceableFailure(extractSlice);

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
    return emitDefaultSilenceableFailure(insertSlice);

  // Collect the surrounding loops of the insert_slice op.
  SmallVector<scf::ForOp> loops;
  auto untiledUse = getUntiledOperandAndSurroundingLoops(
      &insertSlice.getDestMutable(), &loops);
  if (untiledUse == &insertSlice.getDestMutable())
    return emitDefaultSilenceableFailure(insertSlice);

  // Collect the iteration shape and affine map of the streaming channel.
  auto iterTripCounts = getLoopTripCounts(loops);
  auto iterSteps = getLoopSteps(loops);
  auto iterMap = getIterationAffineMap(insertSlice, loops);
  if (!iterTripCounts || !iterSteps || !iterMap)
    return emitDefaultSilenceableFailure(insertSlice);

  // Create the streaming channel.
  rewriter.setInsertionPoint(loops.front());
  auto channelType = hls::StreamType::get(
      insertSlice.getSourceType(), *iterTripCounts, *iterSteps, *iterMap,
      insertSlice.getDestType().getNumElements());
  auto channel =
      rewriter.create<hls::StreamOp>(rewriter.getUnknownLoc(), channelType);

  // Create the stream_write op.
  rewriter.setInsertionPoint(insertSlice);
  auto channelWrite = rewriter.create<hls::StreamWriteOp>(
      rewriter.getUnknownLoc(), channel, insertSlice.getSource());

  // Create the stream_to_tensor op.
  rewriter.setInsertionPointAfter(loops.front());
  auto tensorToReplace = loops.front().getTiedLoopResult(untiledUse);
  auto channelTensor = rewriter.create<hls::StreamToTensorOp>(
      rewriter.getUnknownLoc(), tensorToReplace.getType(), channel);

  rewriter.replaceAllUsesWith(tensorToReplace, channelTensor);
  rewriter.replaceOp(insertSlice, insertSlice.getDest());
  results.push_back(channel);
  results.push_back(channelWrite);
  results.push_back(channelTensor);
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
  // Collect the surrounding loops of the extract_slice op.
  auto loops = getSurroundingLoops(extractSlice,
                                   extractSlice.getSource().getParentBlock());

  // Collect the iteration shape and affine map of the streaming channel.
  auto iterTripCounts = getLoopTripCounts(loops);
  auto iterSteps = getLoopSteps(loops);
  auto iterMap = getIterationAffineMap(extractSlice, loops);
  if (!iterTripCounts || !iterSteps || !iterMap)
    return emitDefaultSilenceableFailure(extractSlice);

  // Create the tensor_to_stream op.
  rewriter.setInsertionPointAfterValue(extractSlice.getSource());
  auto channelType = hls::StreamType::get(
      extractSlice.getResultType(), *iterTripCounts, *iterSteps, *iterMap,
      extractSlice.getSourceType().getNumElements());
  auto channel = rewriter.create<hls::TensorToStreamOp>(
      rewriter.getUnknownLoc(), channelType, extractSlice.getSource());

  // Create the stream_read op.
  rewriter.setInsertionPoint(extractSlice);
  auto channelRead = rewriter.create<hls::StreamReadOp>(
      rewriter.getUnknownLoc(), extractSlice.getResultType(), channel);

  // Create the stream_to_tensor op.
  rewriter.replaceAllUsesWith(extractSlice.getResult(),
                              channelRead.getResult());
  results.push_back(channel);
  results.push_back(channelRead);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertExpandShapeToStreamOp
//===----------------------------------------------------------------------===//

LogicalResult transform::HLSConvertExpandShapeToStreamOp::verify() {
  return success();
}

template <typename OpTy>
static std::optional<std::pair<hls::StreamType, hls::StreamType>>
getLowAndHighRankStreamTypes(OpTy reshapeOp, RankedTensorType lowType,
                             RankedTensorType highType,
                             ArrayRef<int64_t> lowElementShape,
                             ArrayRef<int64_t> highElementShape) {
  // The low and high types must have static shapes.
  if (!lowType.hasStaticShape() || !highType.hasStaticShape())
    return std::nullopt;

  SmallVector<int64_t> lowIterTripCounts;
  SmallVector<int64_t> lowIterSteps;
  SmallVector<AffineExpr> lowIterExprs;
  SmallVector<int64_t> highIterTripCounts;
  SmallVector<int64_t> highIterSteps;
  SmallVector<AffineExpr> highIterExprs;

  // Collect the iteration shape and affine map of the streaming channel.
  for (auto [lowDim, highDims] :
       llvm::enumerate(reshapeOp.getReassociationIndices())) {
    auto lowDimSize = lowType.getDimSize(lowDim);
    auto lowElementDimSize = lowElementShape[lowDim];
    if (lowDimSize % lowElementDimSize != 0)
      return std::nullopt;

    lowIterTripCounts.push_back(lowDimSize / lowElementDimSize);
    lowIterSteps.push_back(lowElementDimSize);
    lowIterExprs.push_back(getAffineDimExpr(lowDim, reshapeOp.getContext()));

    for (auto highDim : highDims) {
      auto highDimSize = highType.getDimSize(highDim);
      auto highElementDimSize = highElementShape[highDim];
      if (highDimSize % highElementDimSize != 0)
        return std::nullopt;

      highIterTripCounts.push_back(highDimSize / highElementDimSize);
      highIterSteps.push_back(highElementDimSize);
      highIterExprs.push_back(
          getAffineDimExpr(highDim, reshapeOp.getContext()));
    }
  }

  // Construct the low stream type.
  auto lowIterMap = AffineMap::get(lowIterTripCounts.size(), 0, lowIterExprs,
                                   reshapeOp.getContext());
  auto lowElementType =
      RankedTensorType::get(lowElementShape, lowType.getElementType());
  auto lowStreamType =
      hls::StreamType::get(lowElementType, lowIterTripCounts, lowIterSteps,
                           lowIterMap, lowType.getNumElements());

  // Construct the high stream type.
  auto highIterMap = AffineMap::get(highIterTripCounts.size(), 0, highIterExprs,
                                    reshapeOp.getContext());
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
  // Construct the source and result stream types.
  auto streamTypes = getLowAndHighRankStreamTypes(
      expandShape, expandShape.getSrcType(), expandShape.getResultType(),
      getSourceElementShape(), getResultElementShape());
  if (!streamTypes)
    return emitDefaultSilenceableFailure(expandShape);

  // Convert the expand_shape op to stream ops and replace its uses.
  rewriter.setInsertionPoint(expandShape);
  auto sourceStream = rewriter.create<hls::TensorToStreamOp>(
      rewriter.getUnknownLoc(), streamTypes->first, expandShape.getSrc());
  auto streamExpandShape = rewriter.create<hls::StreamExpandShapeOp>(
      rewriter.getUnknownLoc(), streamTypes->second, sourceStream,
      expandShape.getReassociation());
  auto resultTensor = rewriter.create<hls::StreamToTensorOp>(
      rewriter.getUnknownLoc(), expandShape.getResultType(), streamExpandShape);
  rewriter.replaceAllUsesWith(expandShape, resultTensor);

  results.push_back(sourceStream);
  results.push_back(streamExpandShape);
  results.push_back(resultTensor);
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
  // Construct the source and result stream types.
  auto streamTypes = getLowAndHighRankStreamTypes(
      collapseShape, collapseShape.getResultType(), collapseShape.getSrcType(),
      getResultElementShape(), getSourceElementShape());
  if (!streamTypes)
    return emitDefaultSilenceableFailure(collapseShape);

  // Convert the expand_shape op to stream ops and replace its uses.
  rewriter.setInsertionPoint(collapseShape);
  auto sourceStream = rewriter.create<hls::TensorToStreamOp>(
      rewriter.getUnknownLoc(), streamTypes->second, collapseShape.getSrc());
  auto streamCollapseShape = rewriter.create<hls::StreamCollapseShapeOp>(
      rewriter.getUnknownLoc(), streamTypes->first, sourceStream,
      collapseShape.getReassociation());
  auto resultTensor = rewriter.create<hls::StreamToTensorOp>(
      rewriter.getUnknownLoc(), collapseShape.getResultType(),
      streamCollapseShape);
  rewriter.replaceAllUsesWith(collapseShape, resultTensor);

  results.push_back(sourceStream);
  results.push_back(streamCollapseShape);
  results.push_back(resultTensor);
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
