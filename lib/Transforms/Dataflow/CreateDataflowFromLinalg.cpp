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
/// Forward fuse generic tensor copies.
struct ForwardFuseGenericOp : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::GenericOp op,
                                PatternRewriter &rewriter) const override {
    bool matched = false;
    if (op.getNumInputs() == 1 && op.getNumOutputs() == 1) {
      auto body = op.getBody();
      if (body->getArgument(0) == body->getTerminator()->getOperand(0) &&
          llvm::hasSingleElement(body->getOperations()))
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

bool isElementwiseGenericOp(linalg::GenericOp op) {
  // All loops must be parallel loop.
  if (op.getNumParallelLoops() != op.getNumLoops())
    return false;

  for (auto valueMap : llvm::zip(op.getOperands(), op.getIndexingMapsArray())) {
    auto type = std::get<0>(valueMap).getType().cast<ShapedType>();
    auto map = std::get<1>(valueMap);

    // If the operand doens't have static shape, the index map must be identity.
    if (!type.hasStaticShape()) {
      if (!map.isIdentity())
        return false;
      continue;
    }

    // Otherwise, each dimension must either have a size of one or have identity
    // access index.
    unsigned index = map.getNumDims() - type.getRank();
    for (auto shapeExpr : llvm::zip(type.getShape(), map.getResults())) {
      auto dimSize = std::get<0>(shapeExpr);
      auto expr = std::get<1>(shapeExpr);
      if (expr != getAffineDimExpr(index++, expr.getContext()) && dimSize != 1)
        return false;
    }
  }
  return true;
}

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
  patterns.add<ForwardFuseOp<linalg::InitTensorOp>>(context);
  patterns.add<ForwardFuseOp<tensor::PadOp>>(context);
  patterns.add<ForwardFuseOp<tensor::CollapseShapeOp>>(context);
  patterns.add<ForwardFuseOp<tensor::ExpandShapeOp>>(context);
}

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
