//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
template <typename OpType>
struct BufferConversionPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<BufferOp>(op, op.getType());
    return success();
  }
};
} // namespace

namespace {
struct PlaceBufferPattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;

    SmallVector<Value, 4> buffers;
    SmallVector<Location, 4> locs;
    for (auto buffer :
         llvm::make_early_inc_range(task.getOps<hls::BufferLikeInterface>())) {
      buffer->moveBefore(task);
      buffers.push_back(buffer.getMemref());
      locs.push_back(buffer.getLoc());
      hasChanged = true;
    }

    if (hasChanged) {
      auto args = task.getBody()->addArguments(ValueRange(buffers), locs);
      for (auto t : llvm::zip(buffers, args))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

      SmallVector<Value, 16> newInputs(task.inputs());
      newInputs.append(buffers.begin(), buffers.end());
      rewriter.setInsertionPoint(task);
      auto newTask = rewriter.create<TaskOp>(task.getLoc(),
                                             task.getResultTypes(), newInputs);
      rewriter.inlineRegionBefore(task.body(), newTask.body(),
                                  newTask.body().end());

      rewriter.replaceOp(task, newTask.getResults());
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct PlaceBuffer : public PlaceBufferBase<PlaceBuffer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<BufferConversionPattern<memref::AllocOp>>(context);
    patterns.add<BufferConversionPattern<memref::AllocaOp>>(context);
    patterns.add<PlaceBufferPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createPlaceBufferPass() {
  return std::make_unique<PlaceBuffer>();
}
