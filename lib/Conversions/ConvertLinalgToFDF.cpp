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
  OutlineLinalgInterface(MLIRContext *context, Block *spaceBlock,
                         StringRef spaceName, unsigned &taskIdx)
      : OpInterfaceRewritePattern<linalg::LinalgOp>(context),
        spaceBlock(spaceBlock), spaceName(spaceName), taskIdx(taskIdx) {}

  LogicalResult matchAndRewrite(linalg::LinalgOp op,
                                PatternRewriter &rewriter) const override {
    if (op->getParentOfType<TaskOp>())
      return failure();
    if (op.hasDynamicShape())
      return op.emitOpError("cannot handle dynamic shape yet");
    auto loc = rewriter.getUnknownLoc();

    // Generate tile and parallel factors of the task.
    auto paramPrefix = "task" + std::to_string(taskIdx++);
    SmallVector<Value, 8> tileFactors;
    SmallVector<Value, 8> parallelFactors;
    auto staticShape = op.getStaticShape();
    for (auto size : llvm::enumerate(op.computeStaticLoopSizes())) {
      rewriter.setInsertionPointToEnd(spaceBlock);

      auto tileName = paramPrefix + "_tile" + std::to_string(size.index());
      auto tileBounds = {rewriter.getAffineConstantExpr(0),
                         rewriter.getAffineConstantExpr(size.value())};
      auto tileParam = rewriter.create<ParamOp>(
          loc, rewriter.getIndexType(), ValueRange({}),
          AffineMap::get(0, 0, tileBounds, rewriter.getContext()),
          ParamKind::TILE_FACTOR, tileName);

      auto parallelName =
          paramPrefix + "_parallel" + std::to_string(size.index());
      auto parallelBounds = {rewriter.getAffineConstantExpr(0),
                             rewriter.getAffineDimExpr(0)};
      auto parallelParam = rewriter.create<ParamOp>(
          loc, rewriter.getIndexType(), tileParam.getResult(),
          AffineMap::get(1, 0, parallelBounds, rewriter.getContext()),
          ParamKind::PARALLEL_FACTOR, parallelName);

      rewriter.setInsertionPoint(op);
      tileFactors.push_back(rewriter.create<GetParamOp>(
          loc, tileParam.getType(), spaceName.str(), tileName));
      parallelFactors.push_back(rewriter.create<GetParamOp>(
          loc, parallelParam.getType(), spaceName.str(), parallelName));
    }
    fuseOpsIntoTask({op}, rewriter, op, tileFactors, parallelFactors);
    return success();
  }

private:
  Block *spaceBlock;
  StringRef spaceName;
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
    auto module = getOperation();
    auto context = module.getContext();

    // Convert temsor.empty and linalg.fill ops to fdf.alloc_tensor ops.
    mlir::RewritePatternSet patterns(context);
    patterns.add<ConvertTensorEmptyOp>(context);
    patterns.add<ConvertLinalgFillOp>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));

    // Get the design space for holding parameters.
    auto space = getOrCreateGlobalSpaceOp(module);
    if (!space.has_value()) {
      module.emitOpError("cannot find or create space op");
      return signalPassFailure();
    }

    unsigned taskIdx = 0;
    patterns.clear();
    patterns.add<OutlineLinalgInterface>(context, &space->getBody().front(),
                                         space->getSymName(), taskIdx);
    patterns.add<OutlineOp<tensor::ReshapeOp>>(context);
    patterns.add<OutlineOp<tensor::ExpandShapeOp>>(context);
    patterns.add<OutlineOp<tensor::CollapseShapeOp>>(context);
    patterns.add<OutlineOp<tensor::InsertSliceOp>>(context);
    patterns.add<OutlineOp<tensor::ExtractSliceOp>>(context);
    patterns.add<OutlineOp<tensor::PackOp>>(context);
    patterns.add<OutlineOp<tensor::UnPackOp>>(context);
    patterns.add<OutlineOp<tensor::PadOp>>(context);

    for (auto func : module.getOps<func::FuncOp>()) {
      dispatchBlock(&func.front());
      auto frozenPatterns = FrozenRewritePatternSet(std::move(patterns));
      (void)applyPatternsAndFoldGreedily(func, frozenPatterns);
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertLinalgToFDFPass() {
  return std::make_unique<ConvertLinalgToFDF>();
}
