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
struct ALAPScheduleNode : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    if (node.getLevel())
      return failure();

    unsigned level = 0;
    for (auto output : node.getOutputs()) {
      if (output.isa<BlockArgument>() &&
          node.getScheduleOp().isDependenceFree())
        continue;

      // Stop to schedule the node if an internal buffer has multi-producer or
      // multi-consumer violation.
      if (!isExternalBuffer(output) || !output.getDefiningOp<BufferOp>())
        if (getConsumersExcept(output, node).size() > 1 ||
            getProducers(output).size() > 1)
          return failure();

      for (auto consumer : getConsumersExcept(output, node)) {
        if (!consumer.getLevel())
          return failure();
        level = std::max(level, consumer.getLevel().value() + 1);
      }
    }
    node.setLevelAttr(rewriter.getI32IntegerAttr(level));
    return success();
  }
};
} // namespace

namespace {
struct ScheduleDataflowNode
    : public ScheduleDataflowNodeBase<ScheduleDataflowNode> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ALAPScheduleNode>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    func.walk([&](ScheduleOp schedule) {
      if (llvm::all_of(schedule.getOps<NodeOp>(),
                       [](NodeOp node) { return node.getLevel(); }))
        schedule.setIsLegalAttr(UnitAttr::get(context));
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createScheduleDataflowNodePass() {
  return std::make_unique<ScheduleDataflowNode>();
}
