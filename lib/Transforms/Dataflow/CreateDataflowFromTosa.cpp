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
struct OutlineRoot : public OpRewritePattern<OpType> {
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
struct ForwardFuse : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<TaskOp>())
      return failure();
    auto DT = DominanceInfo();

    // Find all task users.
    SmallVector<TaskOp, 4> taskUsers;
    for (auto user : op->getUsers())
      if (auto task = dyn_cast<TaskOp>(user->getParentOp()))
        taskUsers.push_back(task);
    if (taskUsers.empty())
      return failure();

    // We always select the dominating task as the target to fuse.
    llvm::sort(taskUsers, [&](auto a, auto b) { return DT.dominates(a, b); });
    fuseOpsIntoTask({op, taskUsers.front()}, rewriter);
    return success();
  }
};
} // namespace

namespace {
/// This pattern will backward fuse ops with the specified type.
template <typename OpType>
struct BackwardFuse : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<TaskOp>())
      return failure();
    auto DT = DominanceInfo();

    // Find all task defining ops.
    SmallVector<TaskOp, 4> taskDefOps;
    for (auto operand : op->getOperands())
      if (auto task = operand.template getDefiningOp<TaskOp>())
        taskDefOps.push_back(task);
    if (taskDefOps.empty())
      return failure();

    // We always select the dominated task as the target to fuse.
    llvm::sort(taskDefOps, [&](auto a, auto b) { return DT.dominates(a, b); });
    fuseOpsIntoTask({taskDefOps.back(), op}, rewriter);
    return success();
  }
};
} // namespace

namespace {
/// This pattern will fuse constant ops with the specified type.
struct FuseConstant : public OpRewritePattern<tosa::ConstOp> {
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

    dispatchBlock(&func.front());

    mlir::RewritePatternSet patterns(context);
    patterns.add<OutlineRoot<tosa::Conv2DOp>>(context);
    patterns.add<OutlineRoot<tosa::AvgPool2dOp>>(context);
    patterns.add<OutlineRoot<tosa::MaxPool2dOp>>(context);
    patterns.add<OutlineRoot<tosa::MatMulOp>>(context);
    patterns.add<OutlineRoot<tosa::MulOp>>(context);
    patterns.add<OutlineRoot<tosa::AddOp>>(context);
    patterns.add<OutlineRoot<tosa::SubOp>>(context);
    patterns.add<OutlineRoot<tosa::RsqrtOp>>(context);
    patterns.add<BackwardFuse<tosa::ClampOp>>(context);
    patterns.add<BackwardFuse<tosa::TransposeOp>>(context);
    patterns.add<ForwardFuse<tosa::ReshapeOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    patterns.clear();
    patterns.add<OutlineRoot<tosa::TransposeOp>>(context);
    // patterns.add<FuseConstant>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromTosaPass() {
  return std::make_unique<CreateDataflowFromTosa>();
}
