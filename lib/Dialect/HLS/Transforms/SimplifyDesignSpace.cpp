//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ConstantizeParamOpPattern : public OpRewritePattern<ParamOp> {
  using OpRewritePattern<ParamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ParamOp op,
                                PatternRewriter &rewriter) const override {
    Attribute constValue;
    if (op.isCandidateConstrained()) {
      if (op.getCandidates().value().size() == 1)
        constValue = op.getCandidates().value()[0];

    } else if (op.isRangeConstrained())
      if (auto constLb = op.getLowerBound().dyn_cast<AffineConstantExpr>()) {
        auto ub = op.getUpperBound();
        auto diff = simplifyAffineExpr(ub - constLb, 0, op.getNumOperands());
        if (auto constDiff = diff.dyn_cast<AffineConstantExpr>())
          if (constDiff.getValue() <= op.getStepAttr().getInt())
            constValue =
                Builder(op.getContext()).getIndexAttr(constLb.getValue());
      }

    if (constValue)
      return constantizeParamOp(op, rewriter, constValue), success();
    return failure();
  }
};
} // namespace

namespace {
struct SimplifyDesignSpace
    : public SimplifyDesignSpaceBase<SimplifyDesignSpace> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    // Get or create the global design space.
    auto space = getOrCreateGlobalSpaceOp(module);
    if (!space)
      return module.emitOpError("failed to get space op"), signalPassFailure();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConstantizeParamOpPattern>(context);
    (void)applyPatternsAndFoldGreedily(space, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createSimplifyDesignSpacePass() {
  return std::make_unique<SimplifyDesignSpace>();
}
