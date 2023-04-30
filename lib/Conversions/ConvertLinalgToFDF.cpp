//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Conversions/Passes.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
/// This pattern will convert a tensor.empty op to an fdf.alloc_tensor op.
struct ConvertTensorEmptyOp : public OpRewritePattern<tensor::EmptyOp> {
  using OpRewritePattern<tensor::EmptyOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(tensor::EmptyOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<AllocTensorOp>(op, op.getType());
    return success();
  }
};
} // namespace

namespace {
/// This pattern will convert a linalg.fill op to an fdf.alloc_tensor op with
/// initial value.
struct ConvertLinalgFillOp : public OpRewritePattern<linalg::FillOp> {
  using OpRewritePattern<linalg::FillOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::FillOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<AllocTensorOp>(op, op.getType(0), op.value());
    return success();
  }
};
} // namespace

namespace {
/// This pattern will outline ops into a separate task.
struct OutlineLinalgInterface
    : public OpInterfaceRewritePattern<linalg::LinalgOp> {
  using OpInterfaceRewritePattern<linalg::LinalgOp>::OpInterfaceRewritePattern;

  LogicalResult matchAndRewrite(linalg::LinalgOp op,
                                PatternRewriter &rewriter) const override {
    if (op->getParentOfType<TaskOp>())
      return failure();
    fuseOpsIntoTask({op}, rewriter);
    return success();
  }
};
} // namespace

namespace {
struct ConvertLinalgToFDF : public ConvertLinalgToFDFBase<ConvertLinalgToFDF> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto builder = OpBuilder(context);

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertLinalgFillOp>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    dispatchBlock(&func.front());

    patterns.clear();
    patterns.add<OutlineLinalgInterface>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertLinalgToFDFPass() {
  return std::make_unique<ConvertLinalgToFDF>();
}
