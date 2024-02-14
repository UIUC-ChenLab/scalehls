//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

using CallToFuncMap = llvm::SmallDenseMap<func::CallOp, func::FuncOp>;

namespace {
/// Sink memref.subview into its call users recursively.
struct SubViewSinkPattern : public OpRewritePattern<func::CallOp> {
  using OpRewritePattern<func::CallOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::CallOp call,
                                PatternRewriter &rewriter) const override {
    auto func = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
        call, call.getCalleeAttr());
    assert(func && "function definition not found");

    SmallVector<Value, 16> newInputs;
    bool hasChanged = false;
    for (auto operand : call->getOperands()) {
      if (auto subview = operand.getDefiningOp<memref::SubViewOp>()) {
        // Create a cloned subview at the start of the function.
        rewriter.setInsertionPointToStart(&func.front());
        auto cloneSubview = cast<memref::SubViewOp>(rewriter.clone(*subview));

        // Get the current argument and replace all its uses.
        auto argIdx = newInputs.size();
        auto arg = func.getArgument(argIdx);
        arg.replaceAllUsesWith(cloneSubview.getResult());
        func.eraseArgument(argIdx);

        // Insert new arguments and replace the operand of the cloned subview.
        for (auto type : llvm::enumerate(subview.getOperandTypes())) {
          auto newArg = func.front().insertArgument(
              argIdx + type.index(), type.value(), rewriter.getUnknownLoc());
          cloneSubview.setOperand(type.index(), newArg);
        }

        newInputs.append(subview.operand_begin(), subview.operand_end());
        hasChanged = true;
      } else
        newInputs.push_back(operand);
    }

    if (hasChanged) {
      func.setType(rewriter.getFunctionType(TypeRange(ValueRange(newInputs)),
                                            func.getResultTypes()));
      rewriter.setInsertionPoint(call);
      rewriter.replaceOpWithNewOp<func::CallOp>(call, func, newInputs);
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct FuncDuplication : public FuncDuplicationBase<FuncDuplication> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    auto builder = OpBuilder(module);

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      unsigned idx = 0;
      if (auto symbolUses = func.getSymbolUses(module)) {
        for (auto use : llvm::make_early_inc_range(symbolUses.value())) {
          auto call = cast<func::CallOp>(use.getUser());
          builder.setInsertionPoint(func);
          auto cloneFunc = cast<func::FuncOp>(builder.clone(*func));
          auto newName = func.getName().str() + "_" + std::to_string(idx++);
          cloneFunc.setName(newName);
          call->setAttr(call.getCalleeAttrName(),
                        FlatSymbolRefAttr::get(func.getContext(), newName));
        }
        if (!symbolUses.value().empty())
          func.erase();
      }
    }

    // TODO: This should be factored out someday somehow. However, because this
    // must be applied after function duplication, the refactoring has to be
    // done very carefully.
    mlir::RewritePatternSet patterns(context);
    patterns.add<SubViewSinkPattern>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createFuncDuplicationPass() {
  return std::make_unique<FuncDuplication>();
}
