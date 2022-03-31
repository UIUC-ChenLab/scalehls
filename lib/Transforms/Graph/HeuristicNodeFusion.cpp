//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Matchers.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// Outline each op with the specified types into a new sub-function.
template <typename... OpTypes> static void applyOutlining(FuncOp func) {
  auto builder = OpBuilder(func);
  localizeConstants(func.front());

  unsigned nodeIdx = 0;
  for (auto &op : llvm::make_early_inc_range(func.getOps())) {
    if (!isa<OpTypes...>(op))
      continue;

    SmallVector<tosa::ConstOp, 4> localConsts;
    SmallVector<Value, 4> args;
    SmallVector<Type, 4> argTypes;
    for (auto operand : op.getOperands()) {
      if (auto constOp = operand.template getDefiningOp<tosa::ConstOp>()) {
        assert(constOp->hasOneUse() && "constant is not localized");
        localConsts.push_back(constOp);
        continue;
      }
      args.push_back(operand);
      argTypes.push_back(operand.getType());
    }

    // Create new sub-function.
    builder.setInsertionPoint(func);
    auto subFuncName =
        func.getName().str() + "_node" + std::to_string(nodeIdx++);
    auto subFunc = builder.template create<FuncOp>(
        op.getLoc(), subFuncName,
        builder.getFunctionType(argTypes, op.getResult(0).getType()));

    // Create sub-function call.
    builder.setInsertionPoint(&op);
    auto call =
        builder.template create<func::CallOp>(op.getLoc(), subFunc, args);
    op.replaceAllUsesWith(call);

    // Create a return op for the sub-function.
    auto entry = subFunc.addEntryBlock();
    builder.setInsertionPointToEnd(entry);
    auto returnOp =
        builder.template create<func::ReturnOp>(op.getLoc(), op.getResult(0));

    // Move local constants and conv2d/pool2d/matmul/add to the new created
    // sub-function.
    for (auto localConst : localConsts)
      localConst->moveBefore(returnOp);
    for (auto zip : llvm::zip(args, entry->getArguments()))
      std::get<0>(zip).replaceUsesWithIf(std::get<1>(zip), [&](OpOperand &use) {
        return use.getOwner() == &op;
      });
    op.moveBefore(returnOp);
  }
}

namespace {
/// This pattern tries to fuse each op with the specified types forward if it
/// appears before a sub-function call.
template <typename... OpTypes>
struct ForwardFusingRewritePattern : public OpRewritePattern<func::CallOp> {
  ForwardFusingRewritePattern(MLIRContext *context, ModuleOp &module)
      : OpRewritePattern<func::CallOp>(context), module(module) {}
  using OpRewritePattern<func::CallOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::CallOp call,
                                PatternRewriter &rewriter) const override {
    auto func = module.lookupSymbol<FuncOp>(call.getCallee());
    auto firstOp = &func.front().front();

    // Used to collect the new input types of the sub-function.
    SmallVector<Type, 4> inputTypes;
    for (auto &input : call->getOpOperands()) {
      auto inputValue = input.get();

      // TODO: This could be more flexible. For example, support multiple users.
      if (inputValue.hasOneUse() && inputValue.getDefiningOp() &&
          isa<OpTypes...>(inputValue.getDefiningOp())) {
        auto defOp = inputValue.getDefiningOp();
        auto &defOperand = defOp->getOpOperand(0);

        // TODO: Support to add new arguments to the sub-function.
        if (llvm::any_of(defOp->getOperands(), [&](Value v) {
              return v != defOperand.get() && !v.getDefiningOp<tosa::ConstOp>();
            }))
          continue;

        // Move into the sub-function and replace all its uses.
        for (auto operand : defOp->getOperands())
          if (auto localConst = operand.getDefiningOp<tosa::ConstOp>())
            localConst->moveBefore(firstOp);
        defOp->moveBefore(firstOp);

        auto arg = func.getArgument(input.getOperandNumber());
        arg.replaceAllUsesWith(inputValue);
        input.set(defOperand.get());

        // Set argument type and collect input types.
        arg.setType(defOperand.get().getType());
        defOperand.set(arg);
        inputTypes.push_back(defOperand.get().getType());
      } else
        inputTypes.push_back(inputValue.getType());
    }

    // Finally, we need to update the sub-function type.
    if (inputTypes != func.getArgumentTypes()) {
      func.setType(rewriter.getFunctionType(inputTypes, func.getResultTypes()));
      return success();
    } else
      return failure();
  }

private:
  ModuleOp &module;
};
} // namespace

namespace {
/// This pattern tries to fuse each op with the specified types backward if it
/// appears after a sub-function call.
template <typename... OpTypes>
struct BackwardFusingRewritePattern : public OpRewritePattern<func::CallOp> {
  BackwardFusingRewritePattern(MLIRContext *context, ModuleOp &module)
      : OpRewritePattern<func::CallOp>(context), module(module) {}
  using OpRewritePattern<func::CallOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::CallOp call,
                                PatternRewriter &rewriter) const override {
    auto func = module.lookupSymbol<FuncOp>(call.getCallee());
    auto returnOp = func.back().getTerminator();

    // Used to collect the new output types of the sub-function.
    SmallVector<Type, 4> outputTypes;
    for (auto result : call.getResults()) {
      // TODO: This could be more flexible. For example, support multiple users.
      if (result.hasOneUse() && isa<OpTypes...>(*result.user_begin())) {
        auto &use = *result.use_begin();
        auto user = use.getOwner();
        auto userResult = user->getResult(0);

        // TODO: Support to add new arguments to the sub-function.
        if (llvm::any_of(user->getOperands(), [&](Value v) {
              return v != use.get() && !v.getDefiningOp<tosa::ConstOp>();
            }))
          continue;

        // Move into the sub-function and replace all its uses.
        for (auto operand : user->getOperands())
          if (auto localConst = operand.getDefiningOp<tosa::ConstOp>())
            localConst->moveBefore(returnOp);
        user->moveBefore(returnOp);

        userResult.replaceAllUsesWith(result);
        use.set(returnOp->getOperand(result.getResultNumber()));
        returnOp->setOperand(result.getResultNumber(), userResult);

        // Update the call result type and collect output types.
        result.setType(userResult.getType());
        outputTypes.push_back(userResult.getType());
      } else
        outputTypes.push_back(result.getType());
    }

    // Finally, we need to update the sub-function type.
    if (outputTypes != func.getResultTypes()) {
      func.setType(
          rewriter.getFunctionType(func.getArgumentTypes(), outputTypes));
      return success();
    } else
      return failure();
  }

private:
  ModuleOp &module;
};
} // namespace

namespace {
struct HeuristicNodeFusion
    : public HeuristicNodeFusionBase<HeuristicNodeFusion> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    // Outline the computation intensive operations.
    for (auto func : llvm::make_early_inc_range(module.getOps<FuncOp>()))
      applyOutlining<tosa::Conv2DOp, tosa::AvgPool2dOp, tosa::MaxPool2dOp,
                     tosa::MatMulOp, tosa::AddOp>(func);

    // Fuse other operations into sub-functions.
    mlir::RewritePatternSet patterns(context);
    patterns.add<BackwardFusingRewritePattern<tosa::ClampOp>>(context, module);
    patterns
        .add<ForwardFusingRewritePattern<tosa::ReshapeOp, tosa::TransposeOp>>(
            context, module);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createHeuristicNodeFusionPass() {
  return std::make_unique<HeuristicNodeFusion>();
}
