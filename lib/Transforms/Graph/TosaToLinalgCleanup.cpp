//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
/// The tosa reshape to tensor reshape conversion.
struct ReshapeOpRewritePattern : public OpRewritePattern<tosa::ReshapeOp> {
  using OpRewritePattern<tosa::ReshapeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::ReshapeOp reshape,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPoint(reshape);
    auto newShapeType = RankedTensorType::get(
        {(int64_t)reshape.new_shape().size()}, rewriter.getI32Type());
    auto newShapeArray = llvm::to_vector<8>(
        llvm::map_range(reshape.new_shape(), [&](Attribute attr) {
          return APInt(32, attr.cast<IntegerAttr>().getInt());
        }));
    auto newShapeAttr = DenseIntElementsAttr::get(newShapeType, newShapeArray);

    auto newShape =
        rewriter.create<arith::ConstantOp>(reshape.getLoc(), newShapeAttr);
    rewriter.replaceOpWithNewOp<tensor::ReshapeOp>(reshape, reshape.getType(),
                                                   reshape.input1(), newShape);
    return success();
  }
};
} // namespace

namespace {
struct TosaToLinalgCleanup
    : public TosaToLinalgCleanupBase<TosaToLinalgCleanup> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ReshapeOpRewritePattern>(context);
    patterns.add<linalg::PadOpTransformationPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createTosaToLinalgCleanupPass() {
  return std::make_unique<TosaToLinalgCleanup>();
}
