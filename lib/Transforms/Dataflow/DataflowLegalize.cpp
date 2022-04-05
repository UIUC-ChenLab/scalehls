//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/MemRef/IR/MemRef.h"
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
    auto output = node.getOutputOp();

    bool hasChanged = false;
    for (auto operand : output.getOperands())
      if (auto memrefType = operand.getType().dyn_cast<MemRefType>()) {
        if (!operand.getDefiningOp<DataflowNodeOp>())
          continue;

        rewriter.setInsertionPointToStart(node.getBody());
        auto buffer = rewriter.create<memref::AllocOp>(loc, memrefType);
        operand.replaceUsesWithIf(buffer, [&](OpOperand &use) {
          return node->isProperAncestor(use.getOwner());
        });

        rewriter.create<memref::CopyOp>(loc, operand, buffer);
        hasChanged = true;
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

/// Schedule the dataflow level of the given operation.
static Optional<unsigned> scheduleDataflowOp(Operation *op) {
  assert(isa<DataflowNodeOp>(op) || isa<DataflowBufferOp>(op));
  unsigned level = 0;
  for (auto user : op->getUsers()) {
    auto userLevel = getDataflowLevel(user);
    if (!userLevel.hasValue())
      return llvm::None;
    level = std::max(level, userLevel.getValue() + 1);
  }
  return level;
}

namespace {
struct NodeSchedulePattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp node,
                                PatternRewriter &rewriter) const override {
    if (!node.level().hasValue())
      if (auto level = scheduleDataflowOp(node)) {
        node->setAttr(node.levelAttrName(),
                      rewriter.getI32IntegerAttr(level.getValue()));
        return success();
      }
    return failure();
  }
};
} // namespace

namespace {
struct BufferSchedulePattern : public OpRewritePattern<DataflowBufferOp> {
  using OpRewritePattern<DataflowBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowBufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (buffer.level().hasValue() || buffer.depth() == 1)
      if (auto level = scheduleDataflowOp(buffer)) {
        buffer->setAttr(buffer.levelAttrName(),
                        rewriter.getI32IntegerAttr(level.getValue()));
        return success();
      }
    return failure();
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
    auto type = buffer.getType().dyn_cast<MemRefType>();
    if (buffer.depth() == 1 || !type ||
        type.getMemorySpaceAsInt() == (unsigned)MemoryKind::DRAM)
      return failure();

    // auto type = buffer.getType();
    // if (buffer.depth() == 1)
    //   return failure();

    Value currentValue = buffer.input();
    DataflowBufferOp currentBuffer;
    for (unsigned i = 0; i < buffer.depth(); ++i) {
      rewriter.setInsertionPoint(buffer);
      currentBuffer = rewriter.create<DataflowBufferOp>(
          buffer.getLoc(), type, currentValue, /*depth=*/1);
      currentValue = currentBuffer.output();
    }
    rewriter.replaceOp(buffer, currentValue);
    return success();
  }
};
} // namespace

namespace {
struct DataflowMergePattern : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    llvm::SmallDenseMap<unsigned, SmallVector<Operation *>> dataflowOpsList;
    for (auto &op : func.getOps())
      if (isa<DataflowNodeOp, DataflowBufferOp>(op)) {
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
struct DataflowLegalize : public DataflowLegalizeBase<DataflowLegalize> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    /// TODO: Support conservative dataflow merging, which doesn't require to
    /// split buffers.
    mlir::RewritePatternSet patterns(context);
    patterns.add<MultiProducerRemovePattern>(context);
    patterns.add<NodeSchedulePattern>(context);
    patterns.add<BufferInsertPattern>(context);
    patterns.add<BufferSplitPattern>(context);
    patterns.add<BufferSchedulePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    patterns.clear();
    patterns.add<DataflowMergePattern>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createDataflowLegalizePass() {
  return std::make_unique<DataflowLegalize>();
}
