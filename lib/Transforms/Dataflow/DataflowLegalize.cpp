//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Dataflower.h"
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
  if (auto node = op->getParentOfType<DataflowNodeOp>())
    return node.level();
  return llvm::None;
}

namespace {
struct DataflowSchedulePattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp node,
                                PatternRewriter &rewriter) const override {
    if (node.level().hasValue())
      return failure();

    unsigned level = 0;
    for (auto user : node->getUsers()) {
      auto userLevel = getDataflowLevel(user);
      if (!userLevel.hasValue())
        return failure();
      level = std::max(level, userLevel.getValue() + 1);
    }

    node->setAttr(node.levelAttrName(), rewriter.getI32IntegerAttr(level));
    return success();
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

    bool hasChanged = false;
    for (auto use : node.getDataflowUses()) {
      auto userLevel = getDataflowLevel(use.second);
      if (!userLevel.hasValue())
        continue;

      auto levelDiff = node.level().getValue() - userLevel.getValue();
      if (levelDiff > 1) {
        rewriter.setInsertionPointAfter(node);
        auto buffer = rewriter.create<DataflowBufferOp>(
            rewriter.getUnknownLoc(), use.first.getType(), use.first,
            levelDiff - 1);
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
struct DataflowLegalize : public DataflowLegalizeBase<DataflowLegalize> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<MultiProducerRemovePattern>(context);
    patterns.add<DataflowSchedulePattern>(context);
    patterns.add<BufferInsertPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createDataflowLegalizePass() {
  return std::make_unique<DataflowLegalize>();
}
