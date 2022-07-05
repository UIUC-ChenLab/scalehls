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
struct MultiProducerRemovePattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp node,
                                PatternRewriter &rewriter) const override {
    auto loc = rewriter.getUnknownLoc();

    // The rationale here is if a memref is an output value of the current node
    // while defined by another node in the same block, which means the memref
    // is updated by both dataflow nodes, then we must create an explicit memref
    // copy to avoid the multi-producer violation.
    bool hasChanged = false;
    for (auto outputValue : node.getOutputValues()) {
      auto memrefType = outputValue.getType().dyn_cast<MemRefType>();
      auto defNode = outputValue.getDefiningOp<DataflowNodeOp>();

      if (memrefType && defNode && defNode->getBlock() == node->getBlock()) {
        rewriter.setInsertionPointToStart(node.getBody());
        auto buffer = rewriter.create<memref::AllocOp>(loc, memrefType);
        outputValue.replaceUsesWithIf(buffer, [&](OpOperand &use) {
          return node->isProperAncestor(use.getOwner());
        });

        rewriter.create<memref::CopyOp>(loc, outputValue, buffer);
        hasChanged = true;
      }
    }
    return success(hasChanged);
  }
};
} // namespace

/// Get the dataflow level of an operation.
static Optional<unsigned> getDataflowLevel(Operation *op) {
  if (op == op->getBlock()->getTerminator())
    return (unsigned)0;
  if (auto node = dyn_cast<DataflowNodeOp>(op))
    return node.level();
  if (auto buffer = dyn_cast<DataflowBufferOp>(op))
    return buffer.level();
  if (auto node = op->getParentOfType<DataflowNodeOp>())
    return node.level();
  return llvm::None;
}

/// Schedule the dataflow level of the given operation. Supports DataflowNodeOp
/// and DataflowBufferOp.
template <typename OpType>
static LogicalResult scheduleDataflowOp(OpType op, PatternRewriter &rewriter) {
  unsigned level = 0;
  for (auto user : op->getUsers()) {
    auto userLevel = getDataflowLevel(user);
    if (!userLevel.hasValue())
      return failure();
    level = std::max(level, userLevel.getValue() + 1);
  }
  op->setAttr(op.levelAttrName(), rewriter.getI32IntegerAttr(level));
  return success();
}

namespace {
struct NodeSchedulePattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp node,
                                PatternRewriter &rewriter) const override {
    if (node.level().hasValue())
      return failure();
    return scheduleDataflowOp(node, rewriter);
  }
};
} // namespace

namespace {
struct BufferInsertPattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp node,
                                PatternRewriter &rewriter) const override {
    if (!node.level().hasValue())
      return failure();
    auto loc = rewriter.getUnknownLoc();

    bool hasChanged = false;
    for (auto use : node.getDataflowUses()) {
      auto userLevel = getDataflowLevel(use.second);
      if (!userLevel.hasValue())
        continue;

      auto levelDiff = node.level().getValue() - userLevel.getValue();
      if (levelDiff > 1) {
        rewriter.setInsertionPointAfter(node);
        auto buffer = rewriter.create<DataflowBufferOp>(
            loc, use.first.getType(), use.first, levelDiff - 1);
        use.first.replaceUsesWithIf(buffer.output(), [&](OpOperand &operand) {
          return use.second->isAncestor(operand.getOwner());
        });
        hasChanged = true;
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct BufferSplitPattern : public OpRewritePattern<DataflowBufferOp> {
  using OpRewritePattern<DataflowBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowBufferOp buffer,
                                PatternRewriter &rewriter) const override {
    // Single-element and external buffer don't need to split.
    if (buffer.depth() == 1 || buffer.isExternal())
      return failure();

    Value currentValue = buffer.input();
    DataflowBufferOp currentBuffer;
    for (unsigned i = 0; i < buffer.depth(); ++i) {
      rewriter.setInsertionPoint(buffer);
      currentBuffer = rewriter.create<DataflowBufferOp>(
          buffer.getLoc(), buffer.getType(), currentValue, /*depth=*/1);
      currentValue = currentBuffer.output();
    }
    rewriter.replaceOp(buffer, currentValue);
    return success();
  }
};
} // namespace

namespace {
struct BufferSchedulePattern : public OpRewritePattern<DataflowBufferOp> {
  using OpRewritePattern<DataflowBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowBufferOp buffer,
                                PatternRewriter &rewriter) const override {
    // Multi-elements and external buffer should not be scheduled.
    if (buffer.level().hasValue() || buffer.depth() != 1 || buffer.isExternal())
      return failure();
    return scheduleDataflowOp(buffer, rewriter);
  }
};
} // namespace

namespace {
template <typename OpType>
struct DataflowMergePattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType target,
                                PatternRewriter &rewriter) const override {
    llvm::SmallDenseMap<unsigned, SmallVector<Operation *>> dataflowOpsList;
    for (auto &op : target.getOps())
      if (isa<DataflowNodeOp, DataflowBufferOp>(op)) {
        // Multi-elements and external buffer should not be merged.
        if (auto buffer = dyn_cast<DataflowBufferOp>(op))
          if (buffer.depth() != 1 || buffer.isExternal())
            continue;

        if (auto level = getDataflowLevel(&op))
          dataflowOpsList[level.getValue()].push_back(&op);
        else
          return op.emitOpError("is not scheduled");
      }

    bool hasChanged = false;
    for (const auto &p : dataflowOpsList) {
      auto node = fuseOpsIntoNewNode(p.second, rewriter);
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
    patterns.add<NodeSchedulePattern>(context);
    patterns.add<BufferInsertPattern>(context);
    patterns.add<BufferSplitPattern>(context);
    patterns.add<BufferSchedulePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    // Legalize function dataflow.
    patterns.clear();
    patterns.add<DataflowMergePattern<func::FuncOp>>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));
    if (!func.getOps<DataflowNodeOp>().empty())
      setFuncDirective(func, false, 1, true);

    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);

    // Legalize loop dataflow to each innermost loop.
    patterns.clear();
    patterns.add<DataflowMergePattern<mlir::AffineForOp>>(context);
    FrozenRewritePatternSet frozenPatterns(std::move(patterns));
    for (auto &band : targetBands) {
      (void)applyOpPatternsAndFold(band.back(), frozenPatterns);
      if (!band.back().getOps<DataflowNodeOp>().empty())
        setLoopDirective(band.back(), false, 1, true, false);
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
