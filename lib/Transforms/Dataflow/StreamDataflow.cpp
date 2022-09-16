//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct TaskStreamingPattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp op,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;

    // Bufferize inputs of the node.
    for (auto &input : llvm::make_early_inc_range(op->getOpOperands())) {
      auto type = input.get().getType();
      if (type.isa<ShapedType, StreamType>())
        continue;

      // If the input is defined outside of the schedule, the input doesn't need
      // to be streamed.
      auto schedule = op->getParentOfType<ScheduleOp>();
      if (!schedule.body().isProperAncestor(input.get().getParentRegion()))
        continue;

      hasChanged = true;
      auto streamType =
          StreamType::get(input.get().getContext(), type, /*depth=*/1);

      auto loc = rewriter.getUnknownLoc();
      rewriter.setInsertionPoint(op);
      auto stream = rewriter.create<ToStreamOp>(loc, streamType, input.get());
      input.set(stream);

      auto arg = op.getBody()->getArgument(input.getOperandNumber());
      arg.setType(streamType);

      rewriter.setInsertionPointToStart(op.getBody());
      auto value = rewriter.create<ToValueOp>(loc, type, arg);
      arg.replaceAllUsesExcept(value, value);
    }

    // Bufferize outputs of the node.
    for (auto result : op->getResults()) {
      auto type = result.getType();
      if (type.isa<ShapedType, StreamType>())
        continue;

      hasChanged = true;
      auto streamType = StreamType::get(result.getContext(), type, /*depth=*/1);
      result.setType(streamType);

      auto loc = rewriter.getUnknownLoc();
      rewriter.setInsertionPointAfter(op);
      auto value = rewriter.create<ToValueOp>(loc, type, result);
      result.replaceAllUsesExcept(value, value);

      rewriter.setInsertionPoint(op.getYieldOp());
      auto output = op.getYieldOp().getOperand(result.getResultNumber());
      auto memref = rewriter.create<ToStreamOp>(loc, streamType, output);
      op.getYieldOp()->getOpOperand(result.getResultNumber()).set(memref);
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct ToStreamConversionPattern : public OpRewritePattern<ToStreamOp> {
  using OpRewritePattern<ToStreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ToStreamOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPointAfter(op);
    rewriter.create<StreamWriteOp>(op.getLoc(), op.stream(), op.value());
    rewriter.setInsertionPoint(op);
    rewriter.replaceOpWithNewOp<StreamOp>(
        op, op.getType(), op.getType().cast<StreamType>().getDepth());
    return success();
  }
};
} // namespace

namespace {
struct ToValueConversionPattern : public OpRewritePattern<ToValueOp> {
  using OpRewritePattern<ToValueOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ToValueOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<StreamReadOp>(op, op.getType(), op.stream());
    return success();
  }
};
} // namespace

namespace {
struct StreamDataflow : public StreamDataflowBase<StreamDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<TaskStreamingPattern>(context);
    patterns.add<ToStreamConversionPattern>(context);
    patterns.add<ToValueConversionPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createStreamDataflowPass() {
  return std::make_unique<StreamDataflow>();
}
