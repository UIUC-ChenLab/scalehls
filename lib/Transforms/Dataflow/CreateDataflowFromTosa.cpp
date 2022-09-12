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
/// This pattern will outline ops with the specified type.
template <typename OpType>
struct RootOutlinePattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<TaskOp>())
      return failure();
    fuseOpsIntoTask({op}, rewriter);
    return success();
  }
};
} // namespace

namespace {
/// This pattern will forward fuse ops with the specified type.
template <typename OpType>
struct ForwardFusePattern : public OpRewritePattern<OpType> {
  ForwardFusePattern(MLIRContext *context, DominanceInfo &DT,
                     PatternBenefit benefit = 1)
      : OpRewritePattern<OpType>(context, benefit), DT(DT) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<TaskOp>())
      return failure();

    // We always select the dominating node as the target node to fuse.
    TaskOp targetNode;
    for (auto user : op->getUsers())
      if (auto node = dyn_cast<TaskOp>(user))
        if (!targetNode || (targetNode && DT.dominates(node, targetNode)))
          targetNode = node;

    if (targetNode)
      fuseOpsIntoTask({op, targetNode}, rewriter);
    return success(targetNode);
  }

private:
  DominanceInfo &DT;
};
} // namespace

namespace {
/// This pattern will backward fuse ops with the specified type.
template <typename OpType>
struct BackwardFusePattern : public OpRewritePattern<OpType> {
  BackwardFusePattern(MLIRContext *context, DominanceInfo &DT,
                      PatternBenefit benefit = 1)
      : OpRewritePattern<OpType>(context, benefit), DT(DT) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<TaskOp>())
      return failure();

    // We always select the dominated node as the target node to fuse.
    TaskOp targetNode;
    for (auto operand : op->getOperands())
      if (auto node = operand.template getDefiningOp<TaskOp>())
        if (!targetNode || (targetNode && DT.dominates(targetNode, node)))
          targetNode = node;

    if (targetNode)
      fuseOpsIntoTask({targetNode, op}, rewriter);
    return success(targetNode);
  }

private:
  DominanceInfo &DT;
};
} // namespace

namespace {
/// This pattern will fuse constant ops with the specified type.
struct ConstFusePattern : public OpRewritePattern<tosa::ConstOp> {
  using OpRewritePattern<tosa::ConstOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::ConstOp op,
                                PatternRewriter &rewriter) const override {
    if (op->getParentOfType<TaskOp>())
      return failure();

    bool hasChanged = false;
    for (auto &use : llvm::make_early_inc_range(op->getUses()))
      if (auto node = dyn_cast<TaskOp>(use.getOwner())) {
        rewriter.setInsertionPoint(node);
        auto newOp = cast<tosa::ConstOp>(rewriter.clone(*op));
        use.set(newOp.getResult());
        fuseOpsIntoTask({newOp, node}, rewriter);
        hasChanged = true;
      }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct CreateDataflowFromTosa
    : public CreateDataflowFromTosaBase<CreateDataflowFromTosa> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto DT = DominanceInfo(func);

    wrapWithSchedule(&func.front());

    mlir::RewritePatternSet patterns(context);
    patterns.add<RootOutlinePattern<tosa::Conv2DOp>>(context);
    patterns.add<RootOutlinePattern<tosa::AvgPool2dOp>>(context);
    patterns.add<RootOutlinePattern<tosa::MaxPool2dOp>>(context);
    patterns.add<RootOutlinePattern<tosa::MatMulOp>>(context);
    patterns.add<RootOutlinePattern<tosa::MulOp>>(context);
    patterns.add<RootOutlinePattern<tosa::AddOp>>(context);
    patterns.add<RootOutlinePattern<tosa::SubOp>>(context);
    patterns.add<RootOutlinePattern<tosa::RsqrtOp>>(context);
    patterns.add<BackwardFusePattern<tosa::ClampOp>>(context, DT);
    patterns.add<BackwardFusePattern<tosa::TransposeOp>>(context, DT);
    patterns.add<ForwardFusePattern<tosa::ReshapeOp>>(context, DT);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    patterns.clear();
    patterns.add<RootOutlinePattern<tosa::TransposeOp>>(context);
    patterns.add<ConstFusePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromTosaPass() {
  return std::make_unique<CreateDataflowFromTosa>();
}
