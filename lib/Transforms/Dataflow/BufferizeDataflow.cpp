//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
template <typename OpType>
struct BufferizeDispatchOrTask : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;

    for (auto result : op->getResults()) {
      if (auto tensorType = result.getType().template dyn_cast<TensorType>()) {
        auto memrefType =
            MemRefType::get(tensorType.getShape(), tensorType.getElementType());
        result.setType(memrefType);

        auto loc = rewriter.getUnknownLoc();
        rewriter.setInsertionPointAfter(op);
        auto tensor = rewriter.template create<bufferization::ToTensorOp>(
            loc, tensorType, result);
        result.replaceAllUsesExcept(tensor, tensor);

        rewriter.setInsertionPoint(op.getYieldOp());
        auto output = op.getYieldOp().getOperand(result.getResultNumber());
        auto memref = rewriter.template create<bufferization::ToMemrefOp>(
            loc, memrefType, output);
        op.getYieldOp()->getOpOperand(result.getResultNumber()).set(memref);
        hasChanged = true;
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
template <typename OpType> struct HoistAlloc : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    for (auto &result : op.getYieldOp()->getOpOperands())
      if (auto alloc = result.get().template getDefiningOp<memref::AllocOp>())
        if (op == alloc->getParentOp()) {
          alloc->moveBefore(op);
          op.getResult(result.getOperandNumber()).replaceAllUsesWith(alloc);
          return success();
        }
    return failure();
  }
};
} // namespace

namespace {
struct BufferizeDataflow : public BufferizeDataflowBase<BufferizeDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    // patterns.add<ConvertGetGlobalToConstBuffer>(context);
    patterns.add<BufferizeDispatchOrTask<DispatchOp>>(context);
    patterns.add<BufferizeDispatchOrTask<TaskOp>>(context);
    patterns.add<HoistAlloc<DispatchOp>>(context);
    patterns.add<HoistAlloc<TaskOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createBufferizeDataflowPass() {
  return std::make_unique<BufferizeDataflow>();
}
