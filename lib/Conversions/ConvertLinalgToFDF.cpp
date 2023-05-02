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
  OutlineLinalgInterface(MLIRContext *context, StringRef prefix,
                         unsigned &taskIdx)
      : OpInterfaceRewritePattern<linalg::LinalgOp>(context), prefix(prefix),
        taskIdx(taskIdx) {}

  LogicalResult matchAndRewrite(linalg::LinalgOp op,
                                PatternRewriter &rewriter) const override {
    if (op->getParentOfType<TaskOp>())
      return failure();
    if (op.hasDynamicShape())
      return op.emitOpError("cannot handle dynamic shape yet");

    // Generate tile and parallel factors of the task.
    rewriter.setInsertionPoint(op);
    auto paramName = prefix.str() + std::to_string(taskIdx++);

    SmallVector<Value, 8> tileFactors;
    SmallVector<Value, 8> parallelFactors;
    auto staticShape = op.getStaticShape();
    for (auto size : llvm::enumerate(op.computeStaticLoopSizes())) {
      auto tileBounds = {rewriter.getAffineConstantExpr(0),
                         rewriter.getAffineConstantExpr(size.value())};
      auto tileFactor = rewriter.create<ParamOp>(
          op.getLoc(), rewriter.getIndexType(), ValueRange({}),
          AffineMap::get(0, 0, tileBounds, rewriter.getContext()),
          ParamKind::TILE_FACTOR,
          paramName + "_tile" + std::to_string(size.index()));
      tileFactors.push_back(tileFactor);

      auto parallelBounds = {rewriter.getAffineConstantExpr(0),
                             rewriter.getAffineDimExpr(0)};
      auto parallelFactor = rewriter.create<ParamOp>(
          op.getLoc(), rewriter.getIndexType(), tileFactor.getResult(),
          AffineMap::get(1, 0, parallelBounds, rewriter.getContext()),
          ParamKind::PARALLEL_FACTOR,
          paramName + "_parallel" + std::to_string(size.index()));
      parallelFactors.push_back(parallelFactor);
    }

    fuseOpsIntoTask({op}, rewriter, op, tileFactors, parallelFactors);
    return success();
  }

private:
  StringRef prefix;
  unsigned &taskIdx;
};
} // namespace

namespace {
/// This pattern will outline ops into a separate task.
template <typename OpType> struct OutlineOp : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<TaskOp>())
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

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertLinalgFillOp>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    dispatchBlock(&func.front());

    unsigned taskIdx = 0;
    patterns.clear();
    patterns.add<OutlineLinalgInterface>(context, "task", taskIdx);
    patterns.add<OutlineOp<tensor::ReshapeOp>>(context);
    patterns.add<OutlineOp<tensor::ExpandShapeOp>>(context);
    patterns.add<OutlineOp<tensor::CollapseShapeOp>>(context);
    patterns.add<OutlineOp<tensor::InsertSliceOp>>(context);
    patterns.add<OutlineOp<tensor::ExtractSliceOp>>(context);
    patterns.add<OutlineOp<tensor::InsertOp>>(context);
    patterns.add<OutlineOp<tensor::ExtractOp>>(context);
    patterns.add<OutlineOp<tensor::PackOp>>(context);
    patterns.add<OutlineOp<tensor::UnPackOp>>(context);
    patterns.add<OutlineOp<tensor::PadOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertLinalgToFDFPass() {
  return std::make_unique<ConvertLinalgToFDF>();
}
