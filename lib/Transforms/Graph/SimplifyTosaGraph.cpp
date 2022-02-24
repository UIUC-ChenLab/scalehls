//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Matchers.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct ClampOpRewritePattern : public OpRewritePattern<tosa::ClampOp> {
  using OpRewritePattern<tosa::ClampOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::ClampOp clamp,
                                PatternRewriter &rewriter) const override {
    auto transpose = clamp.input().getDefiningOp<tosa::TransposeOp>();
    if (!transpose)
      return failure();

    clamp.inputMutable().assign(transpose.input1());
    clamp.output().setType(transpose.input1().getType());

    rewriter.setInsertionPointAfter(clamp);
    auto cloneTranspose = cast<tosa::TransposeOp>(rewriter.clone(*transpose));

    clamp.output().replaceAllUsesWith(cloneTranspose.output());
    cloneTranspose.input1Mutable().assign(clamp.output());
    return success();
  }
};
} // namespace

/// A helper to get permuatation vector from value.
static SmallVector<int64_t, 6> getPermValues(Value perm) {
  DenseIntElementsAttr permAttr;
  if (!matchPattern(perm, m_Constant(&permAttr)))
    return {};

  return llvm::to_vector<6>(
      llvm::map_range(permAttr.getValues<APInt>(),
                      [](const APInt &val) { return val.getSExtValue(); }));
}

namespace {
struct TransposeOpRewritePattern : public OpRewritePattern<tosa::TransposeOp> {
  using OpRewritePattern<tosa::TransposeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::TransposeOp transpose,
                                PatternRewriter &rewriter) const override {
    auto inputTranspose = transpose.input1().getDefiningOp<tosa::TransposeOp>();
    if (!inputTranspose)
      return failure();

    auto permValues = getPermValues(transpose.perms());
    auto inputPermValues = getPermValues(inputTranspose.perms());
    assert(permValues.size() == inputPermValues.size() &&
           "unexpected permutation values");

    for (unsigned i = 0, e = permValues.size(); i < e; ++i)
      if (inputPermValues[permValues[i]] != i)
        return failure();

    rewriter.replaceOp(transpose, inputTranspose.input1());
    return success();
  }
};
} // namespace

namespace {
/// TODO: Expand this to all binary elementwise operations.
struct AddOpRewritePattern : public OpRewritePattern<tosa::AddOp> {
  using OpRewritePattern<tosa::AddOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::AddOp add,
                                PatternRewriter &rewriter) const override {
    auto input1Transpose = add.input1().getDefiningOp<tosa::TransposeOp>();
    auto input2Transpose = add.input2().getDefiningOp<tosa::TransposeOp>();
    if (!input1Transpose || !input2Transpose)
      return failure();

    if (getPermValues(input1Transpose.perms()) !=
        getPermValues(input2Transpose.perms()))
      return failure();

    add.input1Mutable().assign(input1Transpose.input1());
    add.input2Mutable().assign(input2Transpose.input1());
    add.output().setType(input1Transpose.input1().getType());

    rewriter.setInsertionPointAfter(add);
    auto cloneTranspose =
        cast<tosa::TransposeOp>(rewriter.clone(*input1Transpose));

    add.output().replaceAllUsesWith(cloneTranspose.output());
    cloneTranspose.input1Mutable().assign(add.output());
    return success();
  }
};
} // namespace

namespace {
struct SimplifyTosaGraph : public SimplifyTosaGraphBase<SimplifyTosaGraph> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ClampOpRewritePattern>(context);
    patterns.add<TransposeOpRewritePattern>(context);
    patterns.add<AddOpRewritePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSimplifyTosaGraphPass() {
  return std::make_unique<SimplifyTosaGraph>();
}
