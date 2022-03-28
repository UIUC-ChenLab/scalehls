//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLSCpp/HLSCpp.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
/// This pattern will outline ops with the specified type.
template <typename OpType>
struct OutliningPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<DataflowNodeOp>())
      return success();

    // Create a new stream node.
    rewriter.setInsertionPoint(op);
    auto node = rewriter.template create<DataflowNodeOp>(op->getLoc(),
                                                         op->getResultTypes());
    op.replaceAllUsesWith(node);

    // Create the output op of the node.
    auto nodeBlock = rewriter.createBlock(&node.body());
    rewriter.setInsertionPointToEnd(nodeBlock);
    auto output =
        rewriter.create<DataflowOutputOp>(op->getLoc(), op->getResults());

    // Move the target operation into the node.
    op->moveBefore(output);

    return success();
  }
};
} // namespace

/// Fuse the given operation into the given stream node and return the fused
/// stream node.
static DataflowNodeOp fuseOpIntoNode(Operation *op, DataflowNodeOp node,
                                     DominanceInfo &DT,
                                     PatternRewriter &rewriter) {
  assert(op != node && op->getBlock() == node->getBlock() &&
         "must be different ops in the same block");

  // Move the target op into the node.
  auto nodeBlock = &node.body().front();
  if (DT.dominates(op, node))
    op->moveBefore(&nodeBlock->front());
  else
    op->moveBefore(&nodeBlock->back());

  auto output = nodeBlock->getTerminator();
  SmallVector<Value, 4> outputValues;
  SmallVector<Value, 4> resultsToReplace;

  // Collect output results from the target op.
  for (auto result : op->getResults())
    if (result.isUsedOutsideOfBlock(nodeBlock)) {
      outputValues.push_back(result);
      resultsToReplace.push_back(result);
    }

  // Collect output results from the original node.
  for (auto t : llvm::zip(output->getOperands(), node->getResults())) {
    auto value = std::get<0>(t);
    auto result = std::get<1>(t);

    // Update the operand of the target op.
    for (auto &use : llvm::make_early_inc_range(result.getUses()))
      if (use.getOwner() == op)
        use.set(value);

    if (result.isUsedOutsideOfBlock(nodeBlock)) {
      outputValues.push_back(value);
      resultsToReplace.push_back(result);
    }
  }

  SmallVector<Type, 4> outputTypes;
  for (auto value : outputValues)
    outputTypes.push_back(value.getType());

  // Create new stream node and replace all uses.
  rewriter.setInsertionPoint(node);
  auto newNode = rewriter.create<DataflowNodeOp>(node.getLoc(), outputTypes);
  for (auto t : llvm::zip(resultsToReplace, newNode.getResults()))
    std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
      return !newNode->isProperAncestor(use.getOwner());
    });
  rewriter.inlineRegionBefore(node.body(), newNode.body(),
                              newNode.body().end());
  rewriter.eraseOp(node);

  // Create new stream output.
  rewriter.setInsertionPoint(output);
  rewriter.replaceOpWithNewOp<DataflowOutputOp>(output, outputValues);
  return newNode;
}

namespace {
/// This pattern will forward fuse ops with the specified type.
template <typename OpType>
struct ForwardFusingPattern : public OpRewritePattern<OpType> {
  ForwardFusingPattern(MLIRContext *context, DominanceInfo &DT)
      : OpRewritePattern<OpType>(context), DT(DT) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<DataflowNodeOp>())
      return success();

    // We always select the dominating node as the target node to fuse.
    DataflowNodeOp targetNode;
    for (auto user : op->getUsers()) {
      auto node = user->template getParentOfType<DataflowNodeOp>();
      if (!targetNode || (targetNode && node && DT.dominates(node, targetNode)))
        targetNode = node;
    }

    if (targetNode) {
      fuseOpIntoNode(op, targetNode, DT, rewriter);
      return success();
    }
    return failure();
  }

private:
  DominanceInfo &DT;
};
} // namespace

namespace {
/// This pattern will backward fuse ops with the specified type.
template <typename OpType>
struct BackwardFusingPattern : public OpRewritePattern<OpType> {
  BackwardFusingPattern(MLIRContext *context, DominanceInfo &DT)
      : OpRewritePattern<OpType>(context), DT(DT) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<DataflowNodeOp>())
      return success();

    // We always select the dominated node as the target node to fuse.
    DataflowNodeOp targetNode;
    for (auto operand : op->getOperands()) {
      auto node = operand.template getDefiningOp<DataflowNodeOp>();
      if (!targetNode || (targetNode && node && DT.dominates(targetNode, node)))
        targetNode = node;
    }

    if (targetNode) {
      fuseOpIntoNode(op, targetNode, DT, rewriter);
      return success();
    }
    return failure();
  }

private:
  DominanceInfo &DT;
};
} // namespace

namespace {
struct TosaNodeFusion : public TosaNodeFusionBase<TosaNodeFusion> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    localizeConstants(module.body().front());
    auto DT = DominanceInfo(module);

    mlir::RewritePatternSet patterns(context);
    patterns.add<OutliningPattern<tosa::Conv2DOp>>(context);
    patterns.add<OutliningPattern<tosa::AvgPool2dOp>>(context);
    patterns.add<OutliningPattern<tosa::MaxPool2dOp>>(context);
    patterns.add<OutliningPattern<tosa::MatMulOp>>(context);
    patterns.add<OutliningPattern<tosa::AddOp>>(context);
    patterns.add<BackwardFusingPattern<tosa::ClampOp>>(context, DT);
    patterns.add<ForwardFusingPattern<tosa::ReshapeOp>>(context, DT);
    patterns.add<ForwardFusingPattern<tosa::TransposeOp>>(context, DT);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createTosaNodeFusionPass() {
  return std::make_unique<TosaNodeFusion>();
}
