//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tensor/Transforms/Transforms.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct StreamerizeInsertSlicePattern
    : public OpRewritePattern<tensor::InsertSliceOp> {
  using OpRewritePattern<tensor::InsertSliceOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tensor::InsertSliceOp insertSlice,
                                PatternRewriter &rewriter) const override {
    auto untiledProducer = getUntiledProducer(insertSlice.getSource())
                               .getDefiningOp<hls::TensorInitOp>();
    if (!untiledProducer || !untiledProducer->hasOneUse() ||
        !insertSlice.getSource().hasOneUse())
      return failure();

    auto loops = getSurroundingLoops(insertSlice.getSource());
  }
};
} // namespace

namespace {
struct ConvertTensorToStream
    : public ConvertTensorToStreamBase<ConvertTensorToStream> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<StreamerizeInsertSlicePattern>(context);
    // tensor::populateMergeConsecutiveInsertExtractSlicePatterns(patterns);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createConvertTensorToStreamPass() {
  return std::make_unique<ConvertTensorToStream>();
}