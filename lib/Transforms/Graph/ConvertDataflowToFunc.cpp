//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ConvertDataflowToFuncPattern : public OpRewritePattern<DataflowNodeOp> {
  ConvertDataflowToFuncPattern(MLIRContext *context, StringRef prefix)
      : OpRewritePattern<DataflowNodeOp>(context), prefix(prefix) {}

  LogicalResult matchAndRewrite(DataflowNodeOp op,
                                PatternRewriter &rewriter) const override {
    return success();
  }

private:
  StringRef prefix;
};
} // namespace

namespace {
struct ConvertDataflowToFunc
    : public ConvertDataflowToFuncBase<ConvertDataflowToFunc> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    localizeConstants(module.body().front());

    mlir::RewritePatternSet patterns(context);
    // patterns.add<ConvertDataflowToFuncPattern>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertDataflowToFuncPass() {
  return std::make_unique<ConvertDataflowToFunc>();
}
