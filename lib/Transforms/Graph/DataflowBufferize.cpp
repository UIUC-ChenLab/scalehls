//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
/// This pattern will outline ops with the specified type.
template <typename DataflowNodeOp>
struct DataflowBufferizePattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp op,
                                PatternRewriter &rewriter) const override {}
};
} // namespace

namespace {
struct DataflowBufferize : public DataflowBufferizeBase<DataflowBufferize> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    localizeConstants(module.body().front());
    auto DT = DominanceInfo(module);

    mlir::RewritePatternSet patterns(context);
    // patterns.add<DataflowBufferizePattern<tosa::Conv2DOp>>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createDataflowBufferizePass() {
  return std::make_unique<DataflowBufferize>();
}
