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
struct OutlineYieldOp : public OpRewritePattern<YieldOp> {
  using OpRewritePattern<YieldOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(YieldOp op,
                                PatternRewriter &rewriter) const override {
    if (op->template getParentOfType<TaskOp>())
      return failure();
    if (llvm::all_of(op->getOperands(), [](auto operand) {
          return operand.template getDefiningOp<TaskOp>();
        }))
      return failure();

    rewriter.setInsertionPoint(op);
    auto task = rewriter.create<TaskOp>(op->getLoc(), op->getOperandTypes());
    auto taskBlock = rewriter.createBlock(&task.getBody());
    rewriter.setInsertionPointToStart(taskBlock);
    rewriter.clone(*op);

    for (auto [operand, result] :
         llvm::zip(op->getOpOperands(), task.getResults()))
      operand.set(result);
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
    SmallVector<Operation *, 4> taskUsers;
    for (auto user : op->getUsers())
      if (auto task = dyn_cast<TaskOp>(user->getParentOp()))
        taskUsers.push_back(task);
      else
        taskUsers.push_back(user);
    if (taskUsers.empty())
      return failure();

    // We always select the dominating task as the target to fuse.
    llvm::sort(taskUsers, [&](auto a, auto b) { return DT.dominates(a, b); });
    if (!isa<TaskOp>(taskUsers.front()))
      return failure();

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
    SmallVector<Operation *, 4> taskDefOps;
    for (auto operand : op->getOperands())
      if (auto task = operand.template getDefiningOp<TaskOp>())
        taskDefOps.push_back(task);
    if (taskDefOps.empty())
      return failure();

    // We always select the dominated task as the target to fuse.
    llvm::sort(taskDefOps, [&](auto a, auto b) { return DT.dominates(a, b); });
    auto targetTask = taskDefOps.back();

    // We need the current op to be the first user of the targeted task.
    SmallVector<Operation *, 4> targetTaskUsers(targetTask->user_begin(),
                                                targetTask->user_end());
    llvm::sort(targetTaskUsers,
               [&](auto a, auto b) { return crossRegionDominates(a, b); });
    if (targetTaskUsers.front() != op)
      return failure();

    fuseOpsIntoTask({targetTask, op}, rewriter, /*insertToLastOp=*/true);
    return success();
  }
};
} // namespace

namespace {
/// Forward fuse generic tensor copies.
struct ForwardFuseGenericOp : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::GenericOp op,
                                PatternRewriter &rewriter) const override {
    bool matched = false;
    auto body = op.getBody();

    if (op.getNumOutputs() == 1 &&
        llvm::hasSingleElement(body->getOperations())) {
      auto output = body->getTerminator()->getOperand(0);

      // Copy from input to output.
      if (op.getNumInputs() == 1 && output == body->getArgument(0))
        matched = true;

      // Copy from constant to output.
      if (output.getDefiningOp<tosa::ConstOp>() ||
          output.getDefiningOp<arith::ConstantOp>())
        matched = true;
    }

    if (matched) {
      auto pattern = ForwardFuseOp<linalg::GenericOp>(getContext());
      return pattern.matchAndRewrite(op, rewriter);
    }
    return failure();
  }
};
} // namespace

namespace {
/// Backward fuse generic tensor elementwise ops.
struct BackwardFuseGenericOp : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::GenericOp op,
                                PatternRewriter &rewriter) const override {
    if (isElementwiseGenericOp(op)) {
      auto pattern = BackwardFuseOp<linalg::GenericOp>(getContext());
      return pattern.matchAndRewrite(op, rewriter);
    }
    return failure();
  }
};
} // namespace

static void
populateForwardBackwardFusePatterns(mlir::RewritePatternSet &patterns) {
  auto context = patterns.getContext();
  patterns.add<BackwardFuseGenericOp>(context);
  patterns.add<ForwardFuseGenericOp>(context);
  patterns.add<ForwardFuseOp<linalg::FillOp>>(context);
  patterns.add<ForwardFuseOp<tensor::EmptyOp>>(context);
  patterns.add<ForwardFuseOp<tensor::PadOp>>(context);
  patterns.add<ForwardFuseOp<tensor::CollapseShapeOp>>(context);
  patterns.add<ForwardFuseOp<tensor::ExpandShapeOp>>(context);
  patterns.add<ForwardFuseOp<tensor::InsertSliceOp>>(context);
  patterns.add<ForwardFuseOp<tensor::ExtractSliceOp>>(context);
}

namespace {
struct CreateDataflowFromLinalg
    : public CreateDataflowFromLinalgBase<CreateDataflowFromLinalg> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto builder = OpBuilder(context);

    dispatchBlock(&func.front());

    // Collect all empty tensors in the function and localize them to uses.
    SmallVector<Operation *, 16> empties;
    func.walk([&](tensor::EmptyOp op) { empties.push_back(op); });
    for (auto empty : empties) {
      for (auto &use : llvm::make_early_inc_range(empty->getUses())) {
        builder.setInsertionPoint(use.getOwner());
        auto cloneEmpty = cast<tensor::EmptyOp>(builder.clone(*empty));
        use.set(cloneEmpty.getResult());
      }
      empty->erase();
    }

    mlir::RewritePatternSet patterns(context);
    patterns.add<OutlineRootInterface<linalg::ConvolutionOpInterface>>(context);
    patterns.add<OutlineRootInterface<linalg::ContractionOpInterface>>(context);
    populateForwardBackwardFusePatterns(patterns);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    patterns.clear();
    patterns.add<OutlineRootOp<linalg::GenericOp>>(context);
    patterns.add<OutlineYieldOp>(context);
    populateForwardBackwardFusePatterns(patterns);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromLinalgPass() {
  return std::make_unique<CreateDataflowFromLinalg>();
}
