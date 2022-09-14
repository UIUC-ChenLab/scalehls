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
struct ScheduleBufferizationPattern : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp op,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;

    // Bufferize outputs of the node.
    for (auto result : op->getResults()) {
      if (auto tensorType = result.getType().dyn_cast<TensorType>()) {
        hasChanged = true;
        auto memrefType =
            MemRefType::get(tensorType.getShape(), tensorType.getElementType());
        result.setType(memrefType);

        rewriter.setInsertionPointAfter(op);
        auto tensor = rewriter.create<bufferization::ToTensorOp>(
            rewriter.getUnknownLoc(), tensorType, result);
        result.replaceAllUsesExcept(tensor, tensor);

        rewriter.setInsertionPoint(op.getReturnOp());
        auto output = op.getReturnOp().getOperand(result.getResultNumber());
        auto memref = rewriter.create<bufferization::ToMemrefOp>(
            rewriter.getUnknownLoc(), memrefType, output);
        op.getReturnOp()->getOpOperand(result.getResultNumber()).set(memref);
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct TaskBufferizationPattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp op,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;

    // Bufferize inputs of the node.
    for (auto &input : llvm::make_early_inc_range(op->getOpOperands())) {
      if (auto tensorType = input.get().getType().dyn_cast<TensorType>()) {
        hasChanged = true;
        auto memrefType =
            MemRefType::get(tensorType.getShape(), tensorType.getElementType());

        rewriter.setInsertionPoint(op);
        auto memref = rewriter.create<bufferization::ToMemrefOp>(
            rewriter.getUnknownLoc(), memrefType, input.get());
        input.set(memref);

        auto arg = op.getBody()->getArgument(input.getOperandNumber());
        arg.setType(memrefType);

        rewriter.setInsertionPointToStart(op.getBody());
        auto tensor = rewriter.create<bufferization::ToTensorOp>(
            rewriter.getUnknownLoc(), tensorType, arg);
        arg.replaceAllUsesExcept(tensor, tensor);
      }
    }

    // Bufferize outputs of the node.
    for (auto result : op->getResults()) {
      if (auto tensorType = result.getType().dyn_cast<TensorType>()) {
        hasChanged = true;
        auto memrefType =
            MemRefType::get(tensorType.getShape(), tensorType.getElementType());
        result.setType(memrefType);

        rewriter.setInsertionPointAfter(op);
        auto tensor = rewriter.create<bufferization::ToTensorOp>(
            rewriter.getUnknownLoc(), tensorType, result);
        result.replaceAllUsesExcept(tensor, tensor);

        rewriter.setInsertionPoint(op.getYieldOp());
        auto output = op.getYieldOp().getOperand(result.getResultNumber());
        auto memref = rewriter.create<bufferization::ToMemrefOp>(
            rewriter.getUnknownLoc(), memrefType, output);
        op.getYieldOp()->getOpOperand(result.getResultNumber()).set(memref);
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct GetGlobalDemotePattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;

    SmallVector<Value, 4> memrefs;
    SmallVector<Location, 4> locs;
    for (auto getGlobal :
         llvm::make_early_inc_range(task.getOps<memref::GetGlobalOp>()))
      if (getGlobal.getType().getNumElements() > 1024) {
        getGlobal->moveBefore(task);
        memrefs.push_back(getGlobal);
        locs.push_back(getGlobal.getLoc());
        hasChanged = true;
      }

    if (hasChanged) {
      auto args = task.getBody()->addArguments(ValueRange(memrefs), locs);
      for (auto t : llvm::zip(memrefs, args))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

      SmallVector<Value, 16> newInputs(task.inputs());
      newInputs.append(memrefs.begin(), memrefs.end());
      rewriter.setInsertionPoint(task);
      auto newTask = rewriter.create<TaskOp>(task.getLoc(),
                                             task.getResultTypes(), newInputs);
      rewriter.inlineRegionBefore(task.body(), newTask.body(),
                                  newTask.body().end());

      rewriter.replaceOp(task, newTask.getResults());
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct BufferizeDataflow : public BufferizeDataflowBase<BufferizeDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<TaskBufferizationPattern>(context);
    patterns.add<ScheduleBufferizationPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    // TODO: Temporary approach. This should be factored out.
    patterns.clear();
    patterns.add<GetGlobalDemotePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createBufferizeDataflowPass() {
  return std::make_unique<BufferizeDataflow>();
}
