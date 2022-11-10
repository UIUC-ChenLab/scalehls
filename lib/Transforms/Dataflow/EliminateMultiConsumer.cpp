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
struct InsertForkNode : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    auto loc = rewriter.getUnknownLoc();

    auto hasChanged = false;
    for (auto output : node.getOutputs()) {
      // DRAM buffer allocated in the current schedule doesn't need to follow
      // single-consumer single-producer rule.
      if (isExternalBuffer(output) && output.getDefiningOp<BufferOp>())
        continue;

      auto consumers = getConsumersExcept(output, node);
      if (consumers.size() < 2)
        continue;

      hasChanged = true;
      rewriter.setInsertionPointAfter(node);
      SmallVector<Value> buffers;
      SmallVector<Location> bufferLocs;

      // Insert a buffer for each consumer.
      for (auto consumer : consumers) {
        auto buffer = rewriter.create<BufferOp>(loc, output.getType());
        output.replaceUsesWithIf(
            buffer, [&](OpOperand &use) { return use.getOwner() == consumer; });
        buffers.push_back(buffer);
        bufferLocs.push_back(loc);
      }

      // Create a new fork node.
      auto fork = rewriter.create<NodeOp>(loc, output, buffers);
      auto block = rewriter.createBlock(&fork.getBody());
      auto outputArg = block->addArgument(output.getType(), output.getLoc());
      auto bufferArgs = block->addArguments(ValueRange(buffers), bufferLocs);

      // Create explicit copy from the original output to the buffers.
      rewriter.setInsertionPointToStart(block);
      for (auto bufferArg : bufferArgs)
        rewriter.create<memref::CopyOp>(loc, outputArg, bufferArg);
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct EliminateMultiConsumer
    : public EliminateMultiConsumerBase<EliminateMultiConsumer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<InsertForkNode>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createEliminateMultiConsumerPass() {
  return std::make_unique<EliminateMultiConsumer>();
}
