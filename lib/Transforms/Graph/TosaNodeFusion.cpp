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

/// Fuse the given operations into a new graph node. The fused node will be
/// created before the first operation and each operation will be inserted in
/// order. This method always succeeds.
static GraphNodeOp fuseTosaOps(ArrayRef<Operation *> ops,
                               PatternRewriter &rewriter) {
  assert(!ops.empty() && "must fuse at least one op");

  // Collect output values.
  SmallVector<Value, 8> outputValues;
  for (auto op : ops)
    outputValues.append(op->result_begin(), op->result_end());

  // Create new graph node with all outputs.
  auto loc = rewriter.getUnknownLoc();
  rewriter.setInsertionPoint(ops.front());
  auto node = rewriter.create<GraphNodeOp>(loc, ValueRange(outputValues));

  // Move each targeted op into the new graph node.
  rewriter.setInsertionPointToEnd(rewriter.createBlock(&node.body()));
  auto output = rewriter.create<GraphOutputOp>(loc, outputValues);
  for (auto op : ops)
    op->moveBefore(output);

  // Replace external uses with the node results if the user is dominated.
  DominanceInfo DT;
  for (auto t : llvm::zip(outputValues, node.getResults()))
    std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
      return !node->isProperAncestor(use.getOwner()) &&
             DT.properlyDominates(node, use.getOwner());
    });
  return node;
}

namespace {
/// This pattern will outline ops with the specified type.
template <typename OpType>
struct OutlinePattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<GraphNodeOp>())
      return success();
    fuseTosaOps({op}, rewriter);
    return success();
  }
};
} // namespace

namespace {
/// This pattern will forward fuse ops with the specified type.
template <typename OpType>
struct ForwardFusePattern : public OpRewritePattern<OpType> {
  ForwardFusePattern(MLIRContext *context, DominanceInfo &DT)
      : OpRewritePattern<OpType>(context), DT(DT) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<GraphNodeOp>())
      return success();

    // We always select the dominating node as the target node to fuse.
    GraphNodeOp targetNode;
    for (auto user : op->getUsers()) {
      auto node = user->template getParentOfType<GraphNodeOp>();
      if (!targetNode || (targetNode && node && DT.dominates(node, targetNode)))
        targetNode = node;
    }

    if (targetNode) {
      fuseTosaOps({op, targetNode}, rewriter);
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
struct BackwardFusePattern : public OpRewritePattern<OpType> {
  BackwardFusePattern(MLIRContext *context, DominanceInfo &DT)
      : OpRewritePattern<OpType>(context), DT(DT) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<GraphNodeOp>())
      return success();

    // We always select the dominated node as the target node to fuse.
    GraphNodeOp targetNode;
    for (auto operand : op->getOperands()) {
      auto node = operand.template getDefiningOp<GraphNodeOp>();
      if (!targetNode || (targetNode && node && DT.dominates(targetNode, node)))
        targetNode = node;
    }

    if (targetNode) {
      fuseTosaOps({targetNode, op}, rewriter);
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
    auto func = getOperation();
    auto context = func.getContext();
    auto DT = DominanceInfo(func);

    mlir::RewritePatternSet patterns(context);
    patterns.add<OutlinePattern<tosa::Conv2DOp>>(context);
    patterns.add<OutlinePattern<tosa::AvgPool2dOp>>(context);
    patterns.add<OutlinePattern<tosa::MaxPool2dOp>>(context);
    patterns.add<OutlinePattern<tosa::MatMulOp>>(context);
    patterns.add<OutlinePattern<tosa::AddOp>>(context);
    patterns.add<OutlinePattern<tosa::MulOp>>(context);
    patterns.add<BackwardFusePattern<tosa::ClampOp>>(context, DT);
    patterns.add<BackwardFusePattern<tosa::TransposeOp>>(context, DT);
    patterns.add<ForwardFusePattern<tosa::ReshapeOp>>(context, DT);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createTosaNodeFusionPass() {
  return std::make_unique<TosaNodeFusion>();
}
