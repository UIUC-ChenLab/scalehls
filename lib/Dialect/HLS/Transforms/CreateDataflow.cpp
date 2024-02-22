//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct DispatchFuncOp : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    auto funcDispatch = dispatchBlock(func.getName(), &func.front(), rewriter);
    if (!funcDispatch)
      return failure();

    unsigned loopId;
    func.walk([&](affine::AffineForOp loop) {
      std::string name =
          func.getName().str() + "_loop" + std::to_string(loopId++);
      dispatchBlock(name, loop.getBody(), rewriter);
    });
    return success();
  }
};
} // namespace

namespace {
struct CreateDataflow : public CreateDataflowBase<CreateDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    // Dispatch the current function to create the dataflow hierarchy.
    mlir::RewritePatternSet patterns(context);
    patterns.add<DispatchFuncOp>(context);
    (void)applyOpPatternsAndFold({func}, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createCreateDataflowPass() {
  return std::make_unique<CreateDataflow>();
}
