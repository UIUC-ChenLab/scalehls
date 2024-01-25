//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tensor/Transforms/Transforms.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ApplyTransformPattern
    : public ApplyTransformPatternBase<ApplyTransformPattern> {
  void runOnOperation() override {
    auto op = getOperation();
    auto context = op->getContext();

    // Lower copy operation.
    mlir::RewritePatternSet patterns(context);
    tensor::populateMergeConsecutiveInsertExtractSlicePatterns(patterns);
    (void)applyPatternsAndFoldGreedily(op, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createApplyTransformPatternPass() {
  return std::make_unique<ApplyTransformPattern>();
}