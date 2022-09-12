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
struct BufferizeDataflow : public BufferizeDataflowBase<BufferizeDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<TaskBufferizationPattern>(context);
    patterns.add<ScheduleBufferizationPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createBufferizeDataflowPass() {
  return std::make_unique<BufferizeDataflow>();
}
