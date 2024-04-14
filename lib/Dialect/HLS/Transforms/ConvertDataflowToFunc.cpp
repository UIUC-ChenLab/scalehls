//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;
using namespace affine;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_CONVERTDATAFLOWTOFUNC
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
struct ConvertTaskToFunc : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    if (task.getNumResults())
      return task.emitOpError("should not yield any results");

    // Collect all live-ins of the task.
    rewriter.setInsertionPointToStart(&task.getBody().front());
    SmallVector<Value, 8> operands;
    SmallVector<int64_t> stableIndices;
    unsigned index = 0;
    auto liveins = task.getLiveIns();
    for (auto livein : liveins) {
      if (auto constLivein = livein.getDefiningOp<arith::ConstantOp>()) {
        // Sink constant live-ins to the sub-function.
        auto cloneLivein =
            cast<arith::ConstantOp>(rewriter.clone(*constLivein));
        rewriter.replaceUsesWithIf(livein, cloneLivein, [&](OpOperand &use) {
          return task->isAncestor(use.getOwner());
        });
      } else {
        operands.push_back(livein);
        if (livein.getDefiningOp<memref::GetGlobalOp>())
          stableIndices.push_back(index);
        else if (auto arg = dyn_cast<BlockArgument>(livein))
          if (auto func = arg.getDefiningOp<func::FuncOp>())
            if (func.getArgAttrOfType<UnitAttr>(arg.getArgNumber(),
                                                kStableAttrName))
              stableIndices.push_back(index);
        index++;
      }
    }

    // Create a new sub-function.
    rewriter.setInsertionPoint(task->getParentOfType<func::FuncOp>());
    auto subFunc = rewriter.create<func::FuncOp>(
        task.getLoc(), task.getNameAttr(),
        rewriter.getFunctionType(TypeRange(operands), TypeRange()));
    if (task.getLocation())
      subFunc->setAttr(kLocationAttrName, task.getLocationAttr());

    // Apply all attributes from the task to the sub-function.
    for (auto attr : task->getAttrs())
      if (attr.getName() != task.getLocationAttrName() &&
          attr.getName() != task.getNameAttrName())
        subFunc->setAttr(attr.getName(), attr.getValue());

    // Mark stable arguments.
    for (auto index : stableIndices)
      subFunc.setArgAttr(index, kStableAttrName, rewriter.getUnitAttr());

    // Construct the body and arguments of the sub-function.
    auto subFuncBlock = rewriter.createBlock(&subFunc.getBody());
    auto subFuncArgs = subFuncBlock->addArguments(
        TypeRange(operands),
        llvm::map_to_vector(operands, [&](Value v) { return v.getLoc(); }));
    for (auto [operand, subFuncArg] : llvm::zip(operands, subFuncArgs))
      operand.replaceUsesWithIf(subFuncArg, [&](OpOperand &use) {
        return task->isAncestor(use.getOwner());
      });

    // Merge the task block into the sub-function block.
    rewriter.mergeBlocks(&task.getBody().front(), subFuncBlock);
    rewriter.replaceOpWithNewOp<func::ReturnOp>(&subFuncBlock->back());

    // Replace original with a function call.
    rewriter.setInsertionPoint(task);
    rewriter.replaceOpWithNewOp<func::CallOp>(task, subFunc, operands);
    return success();
  }
};
} // namespace

namespace {
struct ConvertDataflowToFunc
    : public hls::impl::ConvertDataflowToFuncBase<ConvertDataflowToFunc> {
  void runOnOperation() override {
    auto context = &getContext();
    for (auto func :
         llvm::make_early_inc_range(getOperation().getOps<func::FuncOp>())) {
      mlir::RewritePatternSet patterns(context);
      patterns.add<ConvertTaskToFunc>(context);
      (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
    }
  }
};
} // namespace
