//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/TransformOps/HLSTransformOps.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
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
// HLSDemoteExtractSliceOp
//===----------------------------------------------------------------------===//

static scf::ForOp getAssociatedLoop(Value value) {
  if (auto arg = dyn_cast<BlockArgument>(value))
    if (auto loop = dyn_cast<scf::ForOp>(arg.getOwner()->getParentOp()))
      if (value == loop.getInductionVar())
        return loop;
  return nullptr;
}

DiagnosedSilenceableFailure transform::HLSDemoteExtractSliceOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp extractSlice,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // We first check whether the extract_slice op's source is an iter_args.
  auto sourceArg = dyn_cast<BlockArgument>(extractSlice.getSource());
  if (sourceArg && isa<scf::ForOp>(sourceArg.getOwner()->getParentOp()))
    return emitDefaultSilenceableFailure(extractSlice);
  results.push_back(extractSlice);

  // We then check if all offsets are loop induction variables, and collect
  // them into a set.
  llvm::SmallDenseSet<Value> offsets;
  for (auto offset : extractSlice.getMixedOffsets())
    if (auto offsetValue = offset.dyn_cast<Value>()) {
      // Here, we need to handle the case where the offset is defined by an
      // affine.apply op. Specifically, we need to check whether the operands
      // of the affine.apply op are loop induction variables.
      if (auto apply = offsetValue.getDefiningOp<affine::AffineApplyOp>()) {
        for (auto operand : apply.getOperands()) {
          if (!getAssociatedLoop(operand))
            return emitDefaultSilenceableFailure(extractSlice);
          offsets.insert(operand);
        }
      } else {
        if (!getAssociatedLoop(offsetValue))
          return emitDefaultSilenceableFailure(extractSlice);
        offsets.insert(offsetValue);
      }
    }

  // Then, we find the outermost loop that does not contain any of the offsets.
  Operation *insertBefore = extractSlice;
  while (auto loop = insertBefore->getParentOfType<scf::ForOp>()) {
    if (!offsets.count(loop.getInductionVar()))
      insertBefore = loop;
    else
      break;
  }

  // Finally, we move the extract_slice op before the outermost loop.
  if (insertBefore != extractSlice)
    extractSlice->moveBefore(insertBefore);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertInsertSliceToStreamOp
//===----------------------------------------------------------------------===//

static std::optional<SmallVector<int64_t>>
getLoopSteps(const SmallVector<scf::ForOp> &loops) {
  SmallVector<int64_t> steps;
  for (auto loop : loops) {
    auto stepCstOp = getConstantIntValue(loop.getStep());
    if (!stepCstOp)
      return std::nullopt;

    int64_t stepCst = stepCstOp.value();
    assert(stepCst >= 0 && "expected positive loop step");
    steps.push_back(stepCst);
  }
  return steps;
}

static std::optional<SmallVector<int64_t>>
getLoopTripCounts(const SmallVector<scf::ForOp> &loops) {
  SmallVector<int64_t> tripCounts;
  for (auto loop : loops) {
    auto lbCstOp = getConstantIntValue(loop.getLowerBound());
    auto ubCstOp = getConstantIntValue(loop.getUpperBound());
    auto stepCstOp = getConstantIntValue(loop.getStep());
    if (!lbCstOp || !ubCstOp || !stepCstOp)
      return std::nullopt;

    int64_t lbCst = lbCstOp.value();
    int64_t ubCst = ubCstOp.value();
    int64_t stepCst = stepCstOp.value();
    assert(lbCst >= 0 && ubCst >= 0 && stepCst >= 0 &&
           "expected positive loop bounds and step");
    if ((ubCst - lbCst) % stepCst != 0)
      return std::nullopt;
    tripCounts.push_back((ubCst - lbCst) / stepCst);
  }
  return tripCounts;
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
  results.push_back(channel);
  results.push_back(channelWrite);
  results.push_back(channelTensor);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertExtractSliceToStreamOp
//===----------------------------------------------------------------------===//

static SmallVector<scf::ForOp> getSurroundingLoops(Operation *target,
                                                   Block *sourceBlock) {
  SmallVector<scf::ForOp> reversedLoops;
  while (auto loop = target->getParentOfType<scf::ForOp>()) {
    reversedLoops.push_back(loop);
    target = loop;
    if (sourceBlock == loop->getBlock())
      break;
  }
  return {reversedLoops.rbegin(), reversedLoops.rend()};
}

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
// HLSLowerTensorToStreamOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::HLSLowerTensorToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter,
    hls::TensorToStreamOp tensorToStream,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {

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
