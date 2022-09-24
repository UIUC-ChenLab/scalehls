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
template <typename InterfaceType>
struct OutlineRootInterface : public OpInterfaceRewritePattern<InterfaceType> {
  using OpInterfaceRewritePattern<InterfaceType>::OpInterfaceRewritePattern;

  LogicalResult matchAndRewrite(InterfaceType op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<TaskOp>())
      return failure();
    fuseOpsIntoTask({op}, rewriter);
    return success();
  }
};
} // namespace

namespace {
/// This pattern will outline ops with the specified type.
template <typename OpType>
struct OutlineRootOp : public OpRewritePattern<OpType> {
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
struct ForwardFuseOp : public OpRewritePattern<OpType> {
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
    fuseOpsIntoTask({op, taskUsers.front()}, rewriter, /*insertToLastOp=*/true);
    return success();
  }
};
} // namespace

namespace {
/// This pattern will backward fuse ops with the specified type.
template <typename OpType>
struct BackwardFuseOp : public OpRewritePattern<OpType> {
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
struct CreateDataflowFromLinalg
    : public CreateDataflowFromLinalgBase<CreateDataflowFromLinalg> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    dispatchBlock(&func.front());

    mlir::RewritePatternSet patterns(context);
    patterns.add<OutlineRootInterface<linalg::ConvolutionOpInterface>>(context);
    patterns.add<OutlineRootInterface<linalg::ContractionOpInterface>>(context);
    patterns.add<OutlineRootOp<linalg::GenericOp>>(context);

    // patterns.add<BackwardFuseOp<>>(context);
    patterns.add<ForwardFuseOp<linalg::FillOp>>(context);
    patterns.add<ForwardFuseOp<linalg::InitTensorOp>>(context);
    patterns.add<ForwardFuseOp<tensor::PadOp>>(context);
    patterns.add<ForwardFuseOp<tensor::CollapseShapeOp>>(context);
    patterns.add<ForwardFuseOp<tensor::ExpandShapeOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromLinalgPass() {
  return std::make_unique<CreateDataflowFromLinalg>();
}
