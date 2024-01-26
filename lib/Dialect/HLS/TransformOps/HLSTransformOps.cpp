//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/TransformOps/HLSTransformOps.h"
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
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp target,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  auto untiledUse =
      getUntiledOperandAndSurroundingLoops(&target.getSourceMutable());
  auto tensorInit = untiledUse->get().getDefiningOp<hls::TensorInitOp>();
  if (!tensorInit)
    return emitDefaultSilenceableFailure(target);

  rewriter.setInsertionPoint(target);
  auto localTensorInit = rewriter.replaceOpWithNewOp<hls::TensorInitOp>(
      target, target.getType(), tensorInit.getInitValue());
  results.push_back(localTensorInit);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSDemoteExtractSliceOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure transform::HLSDemoteExtractSliceOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp target,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // We first check whether the extract_slice op's source is an iter_args.
  auto sourceArg = dyn_cast<BlockArgument>(target.getSource());
  if (sourceArg && isa<scf::ForOp>(sourceArg.getOwner()->getParentOp()))
    return emitDefaultSilenceableFailure(target);

  // We then check if all offsets are loop induction variables, and collect
  // them into a set.
  llvm::SmallDenseSet<Value> offsets;
  for (auto offset : target.getMixedOffsets())
    if (auto offsetValue = offset.dyn_cast<Value>()) {
      auto offsetArg = dyn_cast<BlockArgument>(offsetValue);
      if (!offsetArg || !isa<scf::ForOp>(offsetArg.getOwner()->getParentOp()))
        return emitDefaultSilenceableFailure(target);
      offsets.insert(offsetValue);
    }

  // Then, we find the outermost loop that does not contain any of the offsets.
  Operation *insertBefore = target;
  while (auto loop = insertBefore->getParentOfType<scf::ForOp>()) {
    if (!offsets.count(loop.getInductionVar()))
      insertBefore = loop;
    else
      break;
  }

  // Finally, we move the extract_slice op before the outermost loop.
  if (insertBefore != target)
    target->moveBefore(insertBefore);
  results.push_back(target);
  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertInsertSliceToStreamOp
//===----------------------------------------------------------------------===//

static std::optional<SmallVector<int64_t>>
getTripCounts(const SmallVector<scf::ForOp> &loops) {
  SmallVector<int64_t> tripCounts;
  for (auto loop : loops) {
    // All the loops must have static bounds and step.
    auto lbCstOp = getConstantIntValue(loop.getLowerBound());
    auto ubCstOp = getConstantIntValue(loop.getUpperBound());
    auto stepCstOp = getConstantIntValue(loop.getStep());
    if (!lbCstOp || !ubCstOp || !stepCstOp)
      return std::nullopt;

    // Calculate the trip count of the loop.
    int64_t lbCst = lbCstOp.value();
    int64_t ubCst = ubCstOp.value();
    int64_t stepCst = stepCstOp.value();
    assert(lbCst >= 0 && ubCst >= 0 && stepCst >= 0 &&
           "expected positive loop bounds and step");
    int64_t tripCount = mlir::ceilDiv(ubCst - lbCst, stepCst);
    tripCounts.push_back(tripCount);
  }
  return tripCounts;
}

template <typename OpTy>
static std::optional<AffineMap>
getIterationAffineMap(OpTy target, const SmallVector<scf::ForOp> &loops) {
  SmallVector<AffineExpr> exprs;
  for (auto offset : target.getMixedOffsets()) {
    if (auto offsetValue = offset.template dyn_cast<Value>()) {
      // All the offsets must be block arguments.
      auto offsetArg = dyn_cast<BlockArgument>(offsetValue);
      if (!offsetArg)
        return std::nullopt;

      // All the offsets must be loop induction variables.
      auto loop = dyn_cast<scf::ForOp>(offsetArg.getOwner()->getParentOp());
      if (!loop || loop.getInductionVar() != offsetArg)
        return std::nullopt;

      // Find the index of the offset-associated loop.
      auto loopIndex = std::distance(loops.begin(), llvm::find(loops, loop));
      if (loopIndex == (int64_t)loops.size())
        return std::nullopt;

      exprs.push_back(getAffineDimExpr(loopIndex, target.getContext()));
    } else
      exprs.push_back(getAffineConstantExpr(0, target.getContext()));
  }
  return AffineMap::get(loops.size(), 0, exprs, target.getContext());
}

DiagnosedSilenceableFailure
transform::HLSConvertInsertSliceToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::InsertSliceOp target,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // Check if the destination tensor of the insert_slice op has only one use,
  // which means no other operations have effect on the tensor.
  if (!target.getDest().hasOneUse())
    return emitDefaultSilenceableFailure(target);

  // Collect the surrounding loops of the insert_slice op.
  SmallVector<scf::ForOp> loops;
  auto untiledUse =
      getUntiledOperandAndSurroundingLoops(&target.getDestMutable(), &loops);
  if (untiledUse == &target.getDestMutable())
    return emitDefaultSilenceableFailure(target);

  // Collect the iteration shape and affine map of the streaming channel.
  auto iterShape = getTripCounts(loops);
  auto iterMap = getIterationAffineMap(target, loops);
  if (!iterShape || !iterMap)
    return emitDefaultSilenceableFailure(target);

  // Create the streaming channel.
  rewriter.setInsertionPoint(loops.front());
  auto channelType = hls::StreamType::get(
      target.getSourceType(), *iterShape, AffineMapAttr::get(*iterMap),
      target.getDestType().getNumElements());
  auto channel =
      rewriter.create<hls::StreamOp>(rewriter.getUnknownLoc(), channelType);

  // Create the stream_write op.
  rewriter.setInsertionPoint(target);
  auto channelWrite = rewriter.create<hls::StreamWriteOp>(
      rewriter.getUnknownLoc(), channel, target.getSource());

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
                                                   Operation *source) {
  SmallVector<scf::ForOp> reversedLoops;
  while (auto loop = target->getParentOfType<scf::ForOp>()) {
    reversedLoops.push_back(loop);
    target = loop;
    if (source->getBlock() == loop->getBlock())
      break;
  }
  return {reversedLoops.rbegin(), reversedLoops.rend()};
}

DiagnosedSilenceableFailure
transform::HLSConvertExtractSliceToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp target,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  // Check if the source tensor is defined by an operation.
  auto sourceOp = target.getSource().getDefiningOp();
  if (!sourceOp)
    return emitDefaultSilenceableFailure(target);

  // Collect the surrounding loops of the extract_slice op.
  auto loops = getSurroundingLoops(target, sourceOp);

  // Collect the iteration shape and affine map of the streaming channel.
  auto iterShape = getTripCounts(loops);
  auto iterMap = getIterationAffineMap(target, loops);
  if (!iterShape || !iterMap)
    return emitDefaultSilenceableFailure(target);

  // Create the tensor_to_stream op.
  rewriter.setInsertionPointAfter(sourceOp);
  auto channelType = hls::StreamType::get(
      target.getResultType(), *iterShape, AffineMapAttr::get(*iterMap),
      target.getSourceType().getNumElements());
  auto channel = rewriter.create<hls::TensorToStreamOp>(
      rewriter.getUnknownLoc(), channelType, target.getSource());

  // Create the stream_read op.
  rewriter.setInsertionPoint(target);
  auto channelRead = rewriter.create<hls::StreamReadOp>(
      rewriter.getUnknownLoc(), target.getResultType(), channel);

  // Create the stream_to_tensor op.
  rewriter.replaceAllUsesWith(target.getResult(), channelRead.getResult());
  results.push_back(channel);
  results.push_back(channelRead);
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
