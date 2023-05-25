//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
/// This pattern will convert a tensor.empty op to an fdf.alloc_tensor op.
struct ConvertTensorEmptyOp : public OpRewritePattern<tensor::EmptyOp> {
  using OpRewritePattern<tensor::EmptyOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(tensor::EmptyOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<hls::AllocTensorOp>(op, op.getType());
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
    rewriter.replaceOpWithNewOp<hls::AllocTensorOp>(op, op.getType(0),
                                                    op.value());
    return success();
  }
};
} // namespace

namespace {
// TODO: For now, we also dispatch most tensor ops into separate tasks. We
// should come up with a better way to handle them.
struct DispatchFuncOp : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    auto dispatch = dispatchBlock(&func.front(), rewriter);
    if (!dispatch)
      return failure();

    for (auto &op : llvm::make_early_inc_range(dispatch.getOps())) {
      if (auto linalgOp = dyn_cast<linalg::LinalgOp>(op)) {
        if (linalgOp.hasDynamicShape())
          return linalgOp.emitOpError("cannot handle dynamic shape yet");
        fuseOpsIntoTask({linalgOp}, rewriter);
      } else if (isa<tensor::TensorDialect>(op.getDialect()))
        fuseOpsIntoTask({&op}, rewriter);
    }
    return success();
  }
};
} // namespace

namespace {
struct ConvertLinalgToDataflow
    : public ConvertLinalgToDataflowBase<ConvertLinalgToDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    // Convert linalg ops to FDF ops.
    ConversionTarget target(*context);
    target.addIllegalOp<tensor::EmptyOp, tensor::DimOp, tensor::RankOp,
                        linalg::FillOp>();
    target.addLegalOp<hls::AllocTensorOp>();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertLinalgFillOp>(context);
    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();

    // Dispatch the current function to create the dataflow hierarchy.
    patterns.clear();
    patterns.add<DispatchFuncOp>(context);
    (void)applyOpPatternsAndFold({func}, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertLinalgToDataflowPass() {
  return std::make_unique<ConvertLinalgToDataflow>();
}
