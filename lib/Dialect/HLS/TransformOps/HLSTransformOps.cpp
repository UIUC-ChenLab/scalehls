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

using namespace mlir;
using namespace scalehls;

//===----------------------------------------------------------------------===//
// HLSLinalgTileOp
//===----------------------------------------------------------------------===//

void transform::HLSLinalgTileOp::build(OpBuilder &builder,
                                       OperationState &result, Value target,
                                       ArrayRef<int64_t> staticTileSizes) {
  // Call the default builder.
  // This is future-proof re mixed static-dynamic and setting up the proper
  // operands segment sizes attributes for multiple variadic operands.
  // In the absence of this, horrible bugs ensue.
  // TODO: support mixed static-dynamic (see TileUsingForallOp).
  MLIRContext *ctx = builder.getContext();
  auto opTy = transform::AnyOpType::get(ctx);
  auto staticTileSizesAttr = builder.getDenseI64ArrayAttr(staticTileSizes);
  build(builder, result,
        /*resultTypes=*/TypeRange{opTy, opTy, opTy, opTy},
        /*target=*/target,
        /*tile_sizes=*/staticTileSizesAttr);
}

DiagnosedSilenceableFailure transform::HLSLinalgTileOp::applyToOne(
    transform::TransformRewriter &rewriter, linalg::LinalgOp target,
    transform::ApplyToEachResultList &results,
    transform::TransformState &state) {
  rewriter.setInsertionPoint(target);
  FailureOr<scf::SCFReductionTilingResult> result = scf::tileReductionUsingScf(
      rewriter, cast<PartialReductionOpInterface>(target.getOperation()),
      getAsOpFoldResult(rewriter.getI64ArrayAttr(getTileSizes())));

  if (failed(result))
    return emitDefaultSilenceableFailure(target);
  results.push_back(result->initialOp);
  results.push_back(result->parallelTiledOp);
  results.push_back(result->mergeOp);
  results.push_back(result->loops.front());
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
