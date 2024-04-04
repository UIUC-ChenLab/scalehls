//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_SINKSTREAM
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

static SmallVector<TaskOp> getSurroundingTasks(Operation *target) {
  SmallVector<TaskOp> reversedTasks;
  while (auto parent = target->getParentOp()) {
    if (auto task = dyn_cast<TaskOp>(parent))
      reversedTasks.push_back(task);
    target = parent;
  }
  return {reversedTasks.rbegin(), reversedTasks.rend()};
}

static TaskOp findNearestCommonParentTask(Operation *lhs, Operation *rhs) {
  auto lhsTasks = getSurroundingTasks(lhs);
  auto rhsTasks = getSurroundingTasks(rhs);
  TaskOp commonParentTask;
  for (auto lhsTask : lhsTasks) {
    auto rhsTaskIt = llvm::find(rhsTasks, lhsTask);
    if (rhsTaskIt != rhsTasks.end())
      commonParentTask = lhsTask;
  }
  return commonParentTask;
}

namespace {
struct SinkStreamOp : public OpRewritePattern<hls::StreamOp> {
  using OpRewritePattern<hls::StreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamOp stream,
                                PatternRewriter &rewriter) const override {
    auto writer = stream.getWriter();
    auto reader = stream.getReader();

    auto commonParentTask = findNearestCommonParentTask(writer, reader);
    if (!commonParentTask ||
        commonParentTask == stream->getParentOfType<TaskOp>())
      return failure();

    rewriter.setInsertionPointToStart(&commonParentTask.getBody().front());
    auto newStream = rewriter.clone(*stream);
    stream.replaceAllUsesWith(newStream);
    return success();
  }
};
} // namespace

namespace {
struct SinkStream : public hls::impl::SinkStreamBase<SinkStream> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<SinkStreamOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
