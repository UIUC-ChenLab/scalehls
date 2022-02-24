//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/Arithmetic/IR/Arithmetic.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLSCpp/HLSCpp.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

static bool applySplitFunction(FuncOp func, ArrayRef<Operation *> ops,
                               StringRef name) {
  Liveness liveness(func);
  auto builder = OpBuilder(func);

  // A helper that checks whether a value is a liveout value.
  auto isLiveOut = [&](Value value) {
    return any_of(value.getUsers(), [&](auto user) {
      return all_of(ops, [&](auto op) { return !op->isAncestor(user); });
    });
  };

  // Output types and values of the sub-function.
  SmallVector<Type, 8> outputTypes;
  SmallVector<Value, 8> outputValues;

  // Internal values of the sub-function.
  llvm::SmallDenseSet<Value, 16> internalValues;

  for (auto op : ops)
    for (auto result : op->getResults()) {
      internalValues.insert(result);
      if (isLiveOut(result)) {
        outputTypes.push_back(result.getType());
        outputValues.push_back(result);
      }
    }

  // Input types and values of the sub-function.
  SmallVector<Type, 8> inputTypes;
  SmallVector<Value, 8> inputValues;

  // Local buffers of the sub-function.
  llvm::SmallDenseSet<Operation *, 8> localOps;

  for (auto op : ops) {
    // Push back all operands and liveins as candidates.
    SmallVector<Value, 8> inputCandidates(op->getOperands());
    for (auto &region : op->getRegions()) {
      auto entryBlock = &region.front();
      auto args = entryBlock->getArguments();

      for (auto liveIn : liveness.getLiveIn(entryBlock))
        if (llvm::find(args, liveIn) == args.end())
          inputCandidates.push_back(liveIn);
    }

    for (auto input : inputCandidates) {
      // If the current input is a induction variable or internal value, it
      // doesn't needs to be passed in as argument.
      if (isForInductionVar(input) || internalValues.count(input))
        continue;

      if (auto defOp = input.getDefiningOp()) {
        // If the current input is not a liveout and it's defined by an memref
        // alloc/alloca/get_global or tensor_init op, it is a local buffer and
        // can be localized later.
        if (!isLiveOut(input) &&
            isa<memref::GetGlobalOp, memref::AllocOp, memref::AllocaOp,
                linalg::InitTensorOp>(defOp)) {
          localOps.insert(defOp);
          continue;
        }

        // Since we have localized all tosa constant operations, we can safely
        // insert a constant as a local op here.
        if (isa<tosa::ConstOp>(defOp)) {
          localOps.insert(defOp);
          continue;
        }
      }

      // Only unique inputs will be added.
      if (llvm::find(inputValues, input) != inputValues.end())
        continue;

      inputTypes.push_back(input.getType());
      inputValues.push_back(input);
    }
  }

  // Create a new function for the current dataflow level.
  builder.setInsertionPoint(func);
  auto subFunc = builder.create<FuncOp>(
      func.getLoc(), name, builder.getFunctionType(inputTypes, outputTypes));

  // Create a function call and reconnect all inputs and outputs.
  builder.setInsertionPointAfter(ops.back());
  auto call = builder.create<CallOp>(func.getLoc(), subFunc, inputValues);
  unsigned outputIdx = 0;
  for (auto result : call.getResults())
    outputValues[outputIdx++].replaceAllUsesWith(result);

  // Create new return operation in the new created function.
  auto entry = subFunc.addEntryBlock();
  builder.setInsertionPointToEnd(entry);
  auto returnOp = builder.create<ReturnOp>(subFunc.getLoc(), outputValues);

  // Move local buffers into the new created function.
  for (auto localOp : localOps)
    localOp->moveBefore(&subFunc.front().front());

  // Move same level operations into the new created function.
  for (auto op : ops) {
    op->moveBefore(returnOp);
    op->removeAttr("dataflow_level");
  }

  // Connect operands to the arguments of the new created function.
  for (unsigned i = 0, e = inputValues.size(); i < e; ++i)
    inputValues[i].replaceUsesWithIf(
        entry->getArgument(i),
        [&](OpOperand &use) { return subFunc->isAncestor(use.getOwner()); });

  return true;
}

namespace {
/// The tosa-to-tensor reshape conversion.
/// TODO: This should be factored out! Also, the tensor reshape SHOULD be
/// lowered to affine loops, such that the it's semantics can be fully undertood
/// by the subsequent passes. For now, as a temporary solution, we directly
/// support the emission of reshape in the emit-hlscpp translator.
struct ReshapeOpRewritePattern : public OpRewritePattern<tosa::ReshapeOp> {
  using OpRewritePattern<tosa::ReshapeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tosa::ReshapeOp reshape,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPoint(reshape);
    auto newShapeType = RankedTensorType::get(
        {(int64_t)reshape.new_shape().size()}, rewriter.getI32Type());
    auto newShapeArray = llvm::to_vector<8>(
        llvm::map_range(reshape.new_shape(), [&](Attribute attr) {
          return APInt(32, attr.cast<IntegerAttr>().getInt());
        }));
    auto newShapeAttr = DenseIntElementsAttr::get(newShapeType, newShapeArray);

    auto newShape =
        rewriter.create<arith::ConstantOp>(reshape.getLoc(), newShapeAttr);
    rewriter.replaceOpWithNewOp<tensor::ReshapeOp>(reshape, reshape.getType(),
                                                   reshape.input1(), newShape);
    return success();
  }
};
} // namespace

namespace {
struct SplitFunction : public SplitFunctionBase<SplitFunction> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    auto builder = OpBuilder(module);

    // Collect functions to be split.
    SmallVector<FuncOp, 4> funcs;
    for (auto func : module.getOps<FuncOp>())
      funcs.push_back(func);

    for (auto func : funcs) {
      // Collect all constans that have more than one use.
      SmallVector<tosa::ConstOp, 16> constants;
      func.walk([&](tosa::ConstOp constant) {
        if (!constant->hasOneUse())
          constants.push_back(constant);
      });
      // Localize constants to each of its use.
      for (auto constant : constants) {
        for (auto &use : llvm::make_early_inc_range(constant->getUses())) {
          auto cloneConstant = constant->clone();
          builder.setInsertionPoint(use.getOwner());
          builder.insert(cloneConstant);
          use.set(cloneConstant->getResult(0));
        }
      }

      // Split sub-functions.
      DenseMap<int64_t, SmallVector<Operation *, 8>> dataflowOps;
      for (auto &op : func.front().getOperations())
        if (auto attr = op.getAttrOfType<IntegerAttr>("dataflow_level"))
          dataflowOps[attr.getInt()].push_back(&op);

      for (auto pair : dataflowOps) {
        auto name = "dataflow" + std::to_string(pair.first);
        applySplitFunction(func, pair.second, name);
      }
    }

    // Simplify copy and assign operations generated by LegalizeDataflow.
    mlir::RewritePatternSet patterns(context);
    patterns.add<ReshapeOpRewritePattern>(context);
    hlscpp::AssignOp::getCanonicalizationPatterns(patterns, context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSplitFunctionPass() {
  return std::make_unique<SplitFunction>();
}
