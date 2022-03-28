//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
/// This pattern will outline ops with the specified type.
template <typename OpType>
struct OutliningPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<DataflowNodeOp>())
      return success();
    fuseOpsIntoNewNode({op}, rewriter);
    return success();
  }
};
} // namespace

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
      fuseOpsIntoNewNode({op, targetNode}, rewriter);
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
      fuseOpsIntoNewNode({targetNode, op}, rewriter);
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
