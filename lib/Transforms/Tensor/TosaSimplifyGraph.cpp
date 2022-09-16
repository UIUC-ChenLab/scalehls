//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Matchers.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct ClampOpRewritePattern : public OpRewritePattern<tosa::ClampOp> {
  using OpRewritePattern<tosa::ClampOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::ClampOp clamp,
                                PatternRewriter &rewriter) const override {
    auto transpose = clamp.getInput().getDefiningOp<tosa::TransposeOp>();
    if (!transpose)
      return failure();

    clamp.getInputMutable().assign(transpose.getInput1());
    clamp.getOutput().setType(transpose.getInput1().getType());

    rewriter.setInsertionPointAfter(clamp);
    auto cloneTranspose = cast<tosa::TransposeOp>(rewriter.clone(*transpose));

    clamp.getOutput().replaceAllUsesWith(cloneTranspose.getOutput());
    cloneTranspose.getInput1Mutable().assign(clamp.getOutput());
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
    auto inputTranspose =
        transpose.getInput1().getDefiningOp<tosa::TransposeOp>();
    if (!inputTranspose)
      return failure();

    auto permValues = getPermValues(transpose.getPerms());
    auto inputPermValues = getPermValues(inputTranspose.getPerms());
    assert(permValues.size() == inputPermValues.size() &&
           "unexpected permutation values");

    for (unsigned i = 0, e = permValues.size(); i < e; ++i)
      if (inputPermValues[permValues[i]] != i)
        return failure();

    rewriter.replaceOp(transpose, inputTranspose.getInput1());
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
    auto input1Transpose = add.getInput1().getDefiningOp<tosa::TransposeOp>();
    auto input2Transpose = add.getInput2().getDefiningOp<tosa::TransposeOp>();
    if (!input1Transpose || !input2Transpose)
      return failure();

    if (getPermValues(input1Transpose.getPerms()) !=
        getPermValues(input2Transpose.getPerms()))
      return failure();

    add.getInput1Mutable().assign(input1Transpose.getInput1());
    add.getInput2Mutable().assign(input2Transpose.getInput1());
    add.getOutput().setType(input1Transpose.getInput1().getType());

    rewriter.setInsertionPointAfter(add);
    auto cloneTranspose =
        cast<tosa::TransposeOp>(rewriter.clone(*input1Transpose));

    add.getOutput().replaceAllUsesWith(cloneTranspose.getOutput());
    cloneTranspose.getInput1Mutable().assign(add.getOutput());
    return success();
  }
};
} // namespace

namespace {
struct TosaSimplifyGraph : public TosaSimplifyGraphBase<TosaSimplifyGraph> {
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

std::unique_ptr<Pass> scalehls::createTosaSimplifyGraphPass() {
  return std::make_unique<TosaSimplifyGraph>();
}
