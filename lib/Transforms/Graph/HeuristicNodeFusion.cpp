//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Matchers.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct ClampOpRewritePattern : public OpRewritePattern<tosa::ClampOp> {
  using OpRewritePattern<tosa::ClampOp>::OpRewritePattern;
  ClampOpRewritePattern(MLIRContext *context, unsigned &nodeIdx)
      : OpRewritePattern(context), nodeIdx(nodeIdx) {}

  LogicalResult matchAndRewrite(tosa::ClampOp clamp,
                                PatternRewriter &rewriter) const override {
    auto defOp = clamp.input().getDefiningOp();
    if (!isa<tosa::Conv2DOp, tosa::AddOp>(defOp) || !defOp->hasOneUse())
      return failure();

    // Localize constant operands.
    SmallVector<tosa::ConstOp, 4> localConsts;
    SmallVector<Value, 4> args;
    SmallVector<Type, 4> argTypes;
    for (auto operand : defOp->getOperands()) {
      if (auto constOp = operand.getDefiningOp<tosa::ConstOp>())
        if (constOp->hasOneUse()) {
          localConsts.push_back(constOp);
          continue;
        }
      args.push_back(operand);
      argTypes.push_back(operand.getType());
    }

    // Create new sub-function.
    rewriter.setInsertionPoint(clamp->getParentOfType<FuncOp>());
    auto subFuncName = "node" + std::to_string(nodeIdx++);
    auto subFunc = rewriter.create<FuncOp>(
        defOp->getLoc(), subFuncName,
        rewriter.getFunctionType(argTypes, clamp.getType()));
    auto entry = subFunc.addEntryBlock();

    // Create sub-function call.
    rewriter.setInsertionPoint(clamp);
    auto call = rewriter.create<func::CallOp>(defOp->getLoc(), subFunc, args);
    clamp.replaceAllUsesWith(call);

    // Move clamp and conv2d/add to the new sub-function.
    rewriter.setInsertionPointToEnd(entry);
    auto returnOp = rewriter.create<func::ReturnOp>(rewriter.getUnknownLoc(),
                                                    clamp.output());

    for (auto localConst : localConsts)
      localConst->moveBefore(returnOp);
    for (auto zip : llvm::zip(args, entry->getArguments()))
      std::get<0>(zip).replaceUsesWithIf(std::get<1>(zip), [&](OpOperand &use) {
        return use.getOwner() == defOp;
      });

    defOp->moveBefore(returnOp);
    clamp->moveBefore(returnOp);

    return success();
  }

private:
  unsigned &nodeIdx;
};
} // namespace

namespace {
struct HeuristicNodeFusion
    : public HeuristicNodeFusionBase<HeuristicNodeFusion> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    unsigned nodeIdx = 0;

    mlir::RewritePatternSet patterns(context);
    patterns.add<ClampOpRewritePattern>(context, nodeIdx);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns),
                                       {false, true, 1});
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createHeuristicNodeFusionPass() {
  return std::make_unique<HeuristicNodeFusion>();
}
