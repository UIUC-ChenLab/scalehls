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
    // FIXME: Check there's no intervening ops in between.
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
    // FIXME: Check there's no intervening ops in between.
    llvm::sort(taskDefOps, [&](auto a, auto b) { return DT.dominates(a, b); });
    fuseOpsIntoTask({taskDefOps.back(), op}, rewriter, /*insertToLastOp=*/true);
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

    if (op.getOutputs().size() == 1 &&
        llvm::hasSingleElement(body->getOperations())) {
      auto output = body->getTerminator()->getOperand(0);

      // Copy from input to output.
      if (op.getInputs().size() == 1 && output == body->getArgument(0))
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
    populateForwardBackwardFusePatterns(patterns);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromLinalgPass() {
  return std::make_unique<CreateDataflowFromLinalg>();
}
