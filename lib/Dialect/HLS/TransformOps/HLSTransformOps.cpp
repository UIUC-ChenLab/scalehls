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

using namespace mlir;
using namespace scalehls;

//===----------------------------------------------------------------------===//
// HLSConvertExtractSliceToTensorInitOp
//===----------------------------------------------------------------------===//

static Value getUntiledProducer(Value source) {
  while (auto arg = dyn_cast<BlockArgument>(source)) {
    if (auto loop = dyn_cast<scf::ForOp>(arg.getOwner()->getParentOp()))
      source = loop.getTiedLoopInit(arg)->get();
    else
      break;
  }
  return source;
}

DiagnosedSilenceableFailure
transform::HLSConvertExtractSliceToTensorInitOp::applyToOne(
    transform::TransformRewriter &rewriter, tensor::ExtractSliceOp target,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  rewriter.setInsertionPoint(target);
  auto tensorInit =
      getUntiledProducer(target.getSource()).getDefiningOp<hls::TensorInitOp>();
  if (!tensorInit)
    return emitDefaultSilenceableFailure(target);
  auto localTensorInit = rewriter.replaceOpWithNewOp<hls::TensorInitOp>(
      target, target.getType(), tensorInit.getInitValue());
  results.push_back(localTensorInit);
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
