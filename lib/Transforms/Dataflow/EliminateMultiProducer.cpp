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
struct BufferMultiProducer : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    DominanceInfo DT(schedule);
    auto loc = rewriter.getUnknownLoc();
    bool hasChanged = false;

    SmallVector<Value> buffers;
    for (auto bufferOp : schedule.getOps<BufferOp>())
      buffers.push_back(bufferOp);

    for (auto buffer : buffers) {
      SmallVector<NodeOp, 4> producers(getProducers(buffer));
      if (producers.size() <= 1)
        continue;
      hasChanged = true;

      // Drop the dominating/leading producer, which doesn't need to be
      // transformed.
      llvm::sort(producers, [&](NodeOp a, NodeOp b) {
        return DT.properlyDominates(b, a);
      });
      producers.pop_back();

      for (auto node : producers) {
        auto newInputs = SmallVector<Value>(node.getInputs());
        SmallVector<unsigned> newInputTaps(node.getInputTapsAsInt());
        rewriter.setInsertionPoint(node);

        // Create a new buffer and write to them instead of the original buffer.
        // The original buffer will be passed into the new node as inputs.
        newInputs.push_back(buffer);
        newInputTaps.push_back(0);
        auto newBuffer = rewriter.create<BufferOp>(loc, buffer.getType());
        auto bufferIdx =
            llvm::find(node.getOperands(), buffer) - node.operand_begin();
        node.setOperand(bufferIdx, newBuffer);

        buffer.replaceUsesWithIf(newBuffer, [&](OpOperand &use) {
          if (auto user = dyn_cast<NodeOp>(use.getOwner()))
            return DT.properlyDominates(node, user);
          return false;
        });

        // Create a new node and erase the original one.
        auto newNode = rewriter.create<NodeOp>(
            node.getLoc(), newInputs, node.getOutputs(), node.getParams(),
            newInputTaps, node.getLevelAttr());
        rewriter.inlineRegionBefore(node.getBody(), newNode.getBody(),
                                    newNode.getBody().end());
        rewriter.eraseOp(node);

        // Insert new arguments and create explicit data copy from the original
        // buffer to new buffer.
        rewriter.setInsertionPointToStart(&newNode.getBody().front());
        auto newBufferArg = newNode.getBody().getArgument(bufferIdx);
        auto bufferArg = newNode.getBody().insertArgument(
            newNode.getNumInputs() - 1, newBufferArg.getType(),
            newBufferArg.getLoc());
        rewriter.create<memref::CopyOp>(loc, bufferArg, newBufferArg);
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct MergeMultiProducer : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    DominanceInfo DT(schedule);
    bool hasChanged = false;

    SmallVector<Value> externalBuffers;
    for (auto arg : schedule.getBody().getArguments())
      externalBuffers.push_back(arg);

    for (auto buffer : externalBuffers) {
      SmallVector<NodeOp> producers(getProducers(buffer));
      if (producers.size() <= 1)
        continue;

      llvm::sort(producers, [&](NodeOp a, NodeOp b) {
        return DT.properlyDominates(a, b);
      });

      auto allNodes = SmallVector<NodeOp>(schedule.getOps<NodeOp>().begin(),
                                          schedule.getOps<NodeOp>().end());
      auto ptr = llvm::find(allNodes, producers.front());
      if (llvm::any_of(llvm::enumerate(producers), [&](auto node) {
            return node.value() != *std::next(ptr, node.index());
          }))
        continue;

      fuseNodeOps(producers, rewriter);
      hasChanged = true;
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct EliminateMultiProducer
    : public EliminateMultiProducerBase<EliminateMultiProducer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<BufferMultiProducer>(context);
    patterns.add<MergeMultiProducer>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createEliminateMultiProducerPass() {
  return std::make_unique<EliminateMultiProducer>();
}
