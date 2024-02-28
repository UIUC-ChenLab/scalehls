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
           << "destination tensor must have only one use";

  // Collect the surrounding loops of the insert_slice op.
  SmallVector<scf::ForOp> loops;
  auto untiledUse = getUntiledOperandAndSurroundingLoops(
      &insertSlice.getDestMutable(), &loops);
  if (untiledUse == &insertSlice.getDestMutable())
    return emitDefaultSilenceableFailure(insertSlice)
           << "untiled operand must be defined by a tensor.init op";

  // Collect the iteration shape and affine map of the streaming channel.
  auto iterTripCounts = getLoopTripCounts(loops);
  auto iterSteps = getLoopSteps(loops);
  auto iterMap = getIterationAffineMap(insertSlice, loops);
  if (!iterTripCounts || !iterSteps || !iterMap)
    return emitDefaultSilenceableFailure(insertSlice)
           << "trip counts, steps, or iteration map can be determined";

  // Create the streaming channel.
  auto loc = insertSlice.getLoc();
  rewriter.setInsertionPoint(loops.front());
  auto streamType = hls::StreamType::get(
      insertSlice.getSourceType(), *iterTripCounts, *iterSteps, *iterMap,
      insertSlice.getDestType().getNumElements());
  auto sourceStream = rewriter.create<hls::StreamOp>(loc, streamType);

  // Create the stream_write op.
  rewriter.setInsertionPoint(insertSlice);
  auto streamWrite = rewriter.create<hls::StreamWriteOp>(
      loc, insertSlice.getSource(), sourceStream.getStream());

  // Create the stream_to_tensor op.
  rewriter.setInsertionPointAfter(loops.front());
  auto resultTensor = loops.front().getTiedLoopResult(untiledUse);
  auto streamToTensor = rewriter.create<hls::StreamToTensorOp>(
      loc, resultTensor.getType(), sourceStream);
  rewriter.replaceAllUsesWith(resultTensor, streamToTensor);
  rewriter.replaceOp(insertSlice, insertSlice.getDest());

  results.push_back(sourceStream);
  results.push_back(streamWrite);
  results.push_back(streamToTensor);
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
    return emitDefaultSilenceableFailure(extractSlice)
           << "trip counts, steps, or iteration map can be determined";

  // Create the tensor_to_stream op.
  auto loc = extractSlice.getLoc();
  rewriter.setInsertionPointAfterValue(extractSlice.getSource());
  auto streamType = hls::StreamType::get(
      extractSlice.getResultType(), *iterTripCounts, *iterSteps, *iterMap,
      extractSlice.getSourceType().getNumElements());
  auto destStream = rewriter.create<hls::StreamOp>(loc, streamType);
  auto tensorToStream = rewriter.create<hls::TensorToStreamOp>(
      loc, extractSlice.getSource(), destStream.getStream());

  // Create the stream_read op.
  rewriter.setInsertionPoint(extractSlice);
  auto streamRead = rewriter.create<hls::StreamReadOp>(
      loc, extractSlice.getResultType(), destStream);
  rewriter.replaceOp(extractSlice, streamRead.getResult());

  results.push_back(destStream);
  results.push_back(tensorToStream);
  results.push_back(streamRead);
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
  // Construct the source and result stream types.
  auto streamTypes = getReassociateStreamTypes(
      expandShape, expandShape.getSrcType(), expandShape.getResultType(),
      getInputElementShape(), getOutputElementShape());
  if (!streamTypes)
    return emitDefaultSilenceableFailure(expandShape);

  // Convert the expand_shape op to stream ops and replace its uses.
  auto loc = expandShape.getLoc();
  rewriter.setInsertionPoint(expandShape);
  auto destStream = rewriter.create<hls::StreamOp>(loc, streamTypes->first);
  auto tensorToStream = rewriter.create<hls::TensorToStreamOp>(
      loc, expandShape.getSrc(), destStream.getStream());
  auto streamReassociate = rewriter.create<hls::StreamReassociateOp>(
      loc, streamTypes->second, destStream, /*expandShape=*/true,
      expandShape.getReassociation(), /*expandIteration=*/true,
      expandShape.getReassociation());
  auto streamToTensor = rewriter.create<hls::StreamToTensorOp>(
      loc, expandShape.getResultType(), streamReassociate.getResult());
  rewriter.replaceOp(expandShape, streamToTensor);

  results.push_back(destStream);
  results.push_back(tensorToStream);
  results.push_back(streamReassociate);
  results.push_back(streamToTensor);
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
  auto streamTypes = getReassociateStreamTypes(
      collapseShape, collapseShape.getResultType(), collapseShape.getSrcType(),
      getOutputElementShape(), getInputElementShape());
  if (!streamTypes)
    return emitDefaultSilenceableFailure(collapseShape);

  // Convert the expand_shape op to stream ops and replace its uses.
  auto loc = collapseShape.getLoc();
  rewriter.setInsertionPoint(collapseShape);
  auto destStream = rewriter.create<hls::StreamOp>(loc, streamTypes->second);
  auto tensorToStream = rewriter.create<hls::TensorToStreamOp>(
      loc, collapseShape.getSrc(), destStream.getStream());
  auto streamReassociate = rewriter.create<hls::StreamReassociateOp>(
      loc, streamTypes->first, destStream, /*expandShape=*/false,
      collapseShape.getReassociation(), /*expandIteration=*/false,
      collapseShape.getReassociation());
  auto streamToTensor = rewriter.create<hls::StreamToTensorOp>(
      loc, collapseShape.getResultType(), streamReassociate.getResult());
  rewriter.replaceOp(collapseShape, streamToTensor);

  results.push_back(destStream);
  results.push_back(tensorToStream);
  results.push_back(streamReassociate);
  results.push_back(streamToTensor);
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
