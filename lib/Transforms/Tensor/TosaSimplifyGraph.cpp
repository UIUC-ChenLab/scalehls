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
struct FoldTranspose : public OpRewritePattern<tosa::TransposeOp> {
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
template <typename OpType>
struct RewriteElmwUnary : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType elmw,
                                PatternRewriter &rewriter) const override {
    auto transpose =
        elmw->getOperand(0).template getDefiningOp<tosa::TransposeOp>();
    if (!transpose)
      return failure();

    elmw->getOpOperand(0).set(transpose.getInput1());
    elmw.getOutput().setType(cast<TensorType>(transpose.getInput1().getType()));

    rewriter.setInsertionPointAfter(elmw);
    auto cloneTranspose = cast<tosa::TransposeOp>(rewriter.clone(*transpose));

    elmw.getOutput().replaceAllUsesWith(cloneTranspose.getOutput());
    cloneTranspose.getInput1Mutable().assign(elmw.getOutput());
    return success();
  }
};
} // namespace

namespace {
template <typename OpType>
struct RewriteElmwBinary : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType elmw,
                                PatternRewriter &rewriter) const override {
    auto input1Transpose =
        elmw->getOperand(0).template getDefiningOp<tosa::TransposeOp>();
    auto input2Transpose =
        elmw->getOperand(1).template getDefiningOp<tosa::TransposeOp>();
    if (!input1Transpose || !input2Transpose)
      return failure();

    if (getPermValues(input1Transpose.getPerms()) !=
        getPermValues(input2Transpose.getPerms()))
      return failure();

    elmw->getOpOperand(0).set(input1Transpose.getInput1());
    elmw->getOpOperand(1).set(input2Transpose.getInput1());
    elmw.getOutput().setType(
        cast<TensorType>(input1Transpose.getInput1().getType()));

    rewriter.setInsertionPointAfter(elmw);
    auto cloneTranspose =
        cast<tosa::TransposeOp>(rewriter.clone(*input1Transpose));

    elmw.getOutput().replaceAllUsesWith(cloneTranspose.getOutput());
    cloneTranspose.getInput1Mutable().assign(elmw.getOutput());
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
    patterns.add<FoldTranspose>(context);
    patterns.add<RewriteElmwUnary<tosa::ClampOp>>(context);
    patterns.add<RewriteElmwUnary<tosa::RsqrtOp>>(context);
    patterns.add<RewriteElmwBinary<tosa::AddOp>>(context);
    patterns.add<RewriteElmwBinary<tosa::SubOp>>(context);
    patterns.add<RewriteElmwBinary<tosa::MulOp>>(context);
    patterns.add<RewriteElmwBinary<tosa::DivOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createTosaSimplifyGraphPass() {
  return std::make_unique<TosaSimplifyGraph>();
}
