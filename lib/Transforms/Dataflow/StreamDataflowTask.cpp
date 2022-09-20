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
struct StreamTaskIOs : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp op,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;

    for (auto result : op->getResults()) {
      auto type = result.getType();
      if (type.isa<MemRefType, StreamType>())
        continue;

      // Convert result type to stream.
      hasChanged = true;
      auto streamType = StreamType::get(result.getContext(), type, /*depth=*/1);
      result.setType(streamType);

      // Create to_stream op before yield op.
      auto loc = rewriter.getUnknownLoc();
      rewriter.setInsertionPoint(op.getYieldOp());
      auto &output = op.getYieldOp()->getOpOperand(result.getResultNumber());
      auto stream = rewriter.create<ToStreamOp>(loc, streamType, output.get());
      output.set(stream);

      // Create to_value op at the begining of every task user.
      llvm::SmallDenseSet<TaskOp, 4> taskUsers;
      for (auto user : result.getUsers())
        if (auto taskUser = user->getParentOfType<TaskOp>())
          if (taskUser->getBlock() == op->getBlock())
            taskUsers.insert(taskUser);

      for (auto taskUser : taskUsers) {
        rewriter.setInsertionPointToStart(&taskUser.getBody().front());
        auto value = rewriter.create<ToValueOp>(loc, type, result);
        result.replaceUsesWithIf(value, [&](OpOperand &use) {
          return taskUser->isAncestor(use.getOwner()) &&
                 use.getOwner() != value;
        });
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct ConvertToStreamWrite : public OpRewritePattern<ToStreamOp> {
  using OpRewritePattern<ToStreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ToStreamOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPointAfter(op);
    rewriter.create<StreamWriteOp>(op.getLoc(), op.getStream(), op.getValue());
    rewriter.setInsertionPoint(op);
    rewriter.replaceOpWithNewOp<StreamOp>(
        op, op.getType(), op.getType().cast<StreamType>().getDepth());
    return success();
  }
};
} // namespace

namespace {
struct ConvertToStreamRead : public OpRewritePattern<ToValueOp> {
  using OpRewritePattern<ToValueOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ToValueOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<StreamReadOp>(op, op.getType(), op.getStream());
    return success();
  }
};
} // namespace

namespace {
template <typename OpType>
struct HoistStream : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    for (auto &result : op.getYieldOp()->getOpOperands())
      if (auto stream = result.get().template getDefiningOp<StreamOp>())
        if (op == stream->getParentOp()) {
          stream->moveBefore(op);
          op.getResult(result.getOperandNumber()).replaceAllUsesWith(stream);
          return success();
        }
    return failure();
  }
};
} // namespace

namespace {
struct StreamDataflowTask : public StreamDataflowTaskBase<StreamDataflowTask> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<StreamTaskIOs>(context);
    patterns.add<ConvertToStreamWrite>(context);
    patterns.add<ConvertToStreamRead>(context);
    patterns.add<HoistStream<DispatchOp>>(context);
    patterns.add<HoistStream<TaskOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createStreamDataflowTaskPass() {
  return std::make_unique<StreamDataflowTask>();
}
