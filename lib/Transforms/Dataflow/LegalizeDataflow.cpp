//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct MultiProducerRemovePattern : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (buffer.getProducers().empty() ||
        llvm::hasSingleElement(buffer.getProducers()))
      return failure();

    Value currentBuffer = buffer;
    for (auto user : llvm::drop_begin(buffer.getProducers())) {
      auto node = cast<NodeOp>(user);
      auto operandIdx = llvm::find(node.getOperands(), buffer.memref()) -
                        node.operand_begin();

      // Create a new buffer.
      rewriter.setInsertionPoint(node);
      auto newBuffer = cast<BufferOp>(rewriter.clone(*buffer));
      node.setOperand(operandIdx, newBuffer);

      // Create a new node that takes the current buffer as input.
      auto newInputs = SmallVector<Value>(node.inputs());
      newInputs.push_back(currentBuffer);
      auto newNode =
          rewriter.create<NodeOp>(node.getLoc(), newInputs, node.outputs());
      rewriter.inlineRegionBefore(node.body(), newNode.body(),
                                  newNode.body().end());

      // Create an explicit data copy from the current buffer to new buffer.
      auto currentArg = newNode.getBody()->insertArgument(
          node.getNumInputs(), buffer.getType(), buffer.getLoc());
      auto newArg = newNode.getBody()->getArgument(operandIdx + 1);
      rewriter.setInsertionPointToStart(newNode.getBody());
      rewriter.create<memref::CopyOp>(rewriter.getUnknownLoc(), currentArg,
                                      newArg);

      // Finally, we can safely remove the node and update the current
      rewriter.eraseOp(node);
      currentBuffer = newBuffer;
    }
    return success();
  }
};
} // namespace

namespace {
struct BypassPathRemovePattern : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    if (node.level().hasValue())
      return failure();

    unsigned level = 0;
    for (auto output : node.outputs()) {
      auto buffer = output.getDefiningOp<BufferOp>();
      if (!buffer)
        return node.emitOpError("has unexpected output");
      if (!buffer.getProducersExcept(node).empty())
        return failure();

      for (auto consumer : buffer.getConsumers()) {
        if (!consumer.level().hasValue())
          return failure();
        level = std::max(level, consumer.level().getValue() + 1);
      }
    }
    node.levelAttr(rewriter.getI32IntegerAttr(level));

    for (auto output : node.outputs()) {
      auto buffer = output.getDefiningOp<BufferOp>();
      SmallVector<std::pair<unsigned, NodeOp>, 4> worklist;
      for (auto consumer : buffer.getConsumers()) {
        auto diff = level - consumer.level().getValue();
        worklist.push_back({diff, consumer});
      }
      if (worklist.empty())
        continue;

      auto currentBuffer = buffer;
      auto currentNode = node;
      llvm::sort(worklist, [](auto a, auto b) { return a.first > b.first; });
      for (unsigned i = 2, e = worklist.front().first; i <= e; ++i) {
        // Create a new buffer.
        rewriter.setInsertionPoint(currentNode);
        auto newBuffer = cast<BufferOp>(rewriter.clone(*buffer));

        // Construct a new node for data copy.
        rewriter.setInsertionPointAfter(currentNode);
        auto newNode = rewriter.create<NodeOp>(
            rewriter.getUnknownLoc(), ValueRange(currentBuffer.memref()),
            ValueRange(newBuffer.memref()));
        auto block = rewriter.createBlock(&newNode.body());
        block->addArguments(
            TypeRange({currentBuffer.getType(), newBuffer.getType()}),
            {currentBuffer.getLoc(), newBuffer.getLoc()});

        // Create an explicit copy operation.
        rewriter.setInsertionPointToStart(block);
        rewriter.create<memref::CopyOp>(rewriter.getUnknownLoc(),
                                        block->getArgument(0),
                                        block->getArgument(1));

        // Replace all uses at the current level.
        llvm::SmallDenseSet<Operation *, 4> consumers;
        while (!worklist.empty() && (worklist.back().first == i))
          consumers.insert(worklist.pop_back_val().second);
        buffer.memref().replaceUsesWithIf(newBuffer, [&](OpOperand &use) {
          return consumers.count(use.getOwner());
        });

        // Finally, we can update current buffer and current node.
        currentBuffer = newBuffer;
        currentNode = newNode;
      }
    }
    return success();
  }
};
} // namespace

static NodeOp fuseNodeOps(ArrayRef<NodeOp> ops, PatternRewriter &rewriter) {
  assert(!ops.empty() && "must fuse at least one op");
  rewriter.setInsertionPointAfter(ops.back());
}

namespace {
template <typename OpType>
struct NodeMergePattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp target,
                                PatternRewriter &rewriter) const override {
    llvm::SmallDenseMap<unsigned, SmallVector<Operation *>> worklist;
    for (auto &op : target.getOps())
      if (auto node = dyn_cast<NodeOp>(op)) {
        if (auto level = node.level())
          worklist[level.getValue()].push_back(&op);
        else
          return op.emitOpError("node is not scheduled");
      }

    bool hasChanged = false;
    for (const auto &p : worklist) {
      auto node = fuseNodeOps(p.second, rewriter);
      node->setAttr(node.levelAttrName(), rewriter.getI32IntegerAttr(p.first));
      hasChanged = true;
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct LegalizeDataflow : public LegalizeDataflowBase<LegalizeDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<MultiProducerRemovePattern>(context);
    patterns.add<BypassPathRemovePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    // // Legalize function dataflow.
    // patterns.clear();
    // // patterns.add<NodeMergePattern<func::FuncOp>>(context);
    // (void)applyOpPatternsAndFold(func, std::move(patterns));
    // if (!func.getOps<DataflowNodeOp>().empty())
    //   setFuncDirective(func, false, 1, true);

    // // Collect all target loop bands.
    // AffineLoopBands targetBands;
    // getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);

    // // Legalize loop dataflow to each innermost loop.
    // patterns.clear();
    // // patterns.add<NodeMergePattern<mlir::AffineForOp>>(context);
    // FrozenRewritePatternSet frozenPatterns(std::move(patterns));
    // for (auto &band : targetBands) {
    //   (void)applyOpPatternsAndFold(band.back(), frozenPatterns);
    //   if (!band.back().getOps<DataflowNodeOp>().empty())
    //     setLoopDirective(band.back(), false, 1, true, false);
    // }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
