//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/TransformOps/HLSTransformOps.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/SCF/Transforms/TileUsingInterface.h"
#include "mlir/Dialect/Transform/IR/TransformDialect.h"
#include "mlir/Dialect/Transform/IR/TransformInterfaces.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;

template <typename OpTy>
static std::tuple<OpTy, OpOperand *> getUntiledProducer(OpOperand *source) {
  while (auto arg = dyn_cast<BlockArgument>(source->get())) {
    if (auto loop = dyn_cast<scf::ForOp>(arg.getOwner()->getParentOp()))
      source = loop.getTiedLoopInit(arg);
    else
      break;
  }
  return {source->get().getDefiningOp<OpTy>(), source};
}

//===----------------------------------------------------------------------===//
// HLSConvertExtractSliceToTensorInitOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::HLSConvertExtractSliceToTensorInitOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp target,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  auto [tensorInit, use] =
      getUntiledProducer<hls::TensorInitOp>(&target.getSourceMutable());
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

DiagnosedSilenceableFailure
transform::HLSConvertInsertSliceToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::InsertSliceOp target,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  auto [tensorInit, use] =
      getUntiledProducer<hls::TensorInitOp>(&target.getSourceMutable());
  if (!tensorInit || !target.getSource().hasOneUse())
    return emitDefaultSilenceableFailure(target);

  return DiagnosedSilenceableFailure::success();
}

//===----------------------------------------------------------------------===//
// HLSConvertExtractSliceToStreamOp
//===----------------------------------------------------------------------===//

DiagnosedSilenceableFailure
transform::HLSConvertExtractSliceToStreamOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp target,
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
