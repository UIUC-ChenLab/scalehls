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
struct BufferMultiProducer : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    auto schedule = node.getScheduleOp();
    DominanceInfo DT(schedule);
    bool hasChanged = false;

    // Get all argument buffers that need to be transformed.
    SmallVector<BlockArgument, 4> bufferArgs;
    SmallVector<BlockArgument, 4> externalBufferArgs;
    for (auto arg : node.getOutputArgs()) {
      auto buffer = node.getOperand(arg.getArgNumber());
      SmallVector<NodeOp, 4> producers(getProducers(buffer));
      llvm::sort(producers, [&](NodeOp a, NodeOp b) {
        return DT.properlyDominates(a, b);
      });

      // If the current node is the dominating node or there's no other
      // producers, we don't need to transform the buffer.
      if (node == producers.front())
        continue;

      // External and internal buffers will be traited differently.
      if (!buffer.isa<BlockArgument>())
        bufferArgs.push_back(arg);
      else
        externalBufferArgs.push_back(arg);
    }

    // Handle internal buffers.
    if (!bufferArgs.empty()) {
      auto loc = rewriter.getUnknownLoc();
      auto newInputs = SmallVector<Value>(node.getInputs());
      SmallVector<unsigned> newInputTaps(node.getInputTapsAsInt());
      rewriter.setInsertionPoint(node);

      // Create new buffers and write to them instead of the original buffers.
      // The original buffer will be passed into the new node as inputs.
      for (auto arg : bufferArgs) {
        auto buffer = node.getOperand(arg.getArgNumber());
        newInputs.push_back(buffer);
        newInputTaps.push_back(0);
        auto newBuffer = rewriter.create<BufferOp>(loc, arg.getType());
        node.setOperand(arg.getArgNumber(), newBuffer);

        buffer.replaceUsesWithIf(newBuffer, [&](OpOperand &use) {
          if (auto user = dyn_cast<NodeOp>(use.getOwner()))
            return DT.properlyDominates(node, user);
          return false;
        });
      }

      // Create a new node and erase the original one.
      auto newNode = rewriter.create<NodeOp>(
          node.getLoc(), newInputs, node.getOutputs(), node.getParams(),
          newInputTaps, node.getLevelAttr());
      rewriter.inlineRegionBefore(node.getBody(), newNode.getBody(),
                                  newNode.getBody().end());

      // Insert new arguments and create explicit data copy from the original
      // buffer to new buffer.
      rewriter.setInsertionPointToStart(&newNode.getBody().front());
      for (auto e : llvm::enumerate(bufferArgs)) {
        auto newBufferArg = e.value();
        auto bufferArg = newNode.getBody().insertArgument(
            node.getNumInputs() + e.index(), newBufferArg.getType(),
            newBufferArg.getLoc());
        rewriter.create<memref::CopyOp>(loc, bufferArg, newBufferArg);
      }

      rewriter.eraseOp(node);
      hasChanged = true;
    }

    // // TODO: Handle external buffers.
    // if (!externalBufferArgs.empty()) {
    // }
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
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createEliminateMultiProducerPass() {
  return std::make_unique<EliminateMultiProducer>();
}
