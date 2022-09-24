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
template <typename OpType>
struct HoistBuffer : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    for (auto &result : op.getYieldOp()->getOpOperands())
      if (auto buffer =
              result.get().template getDefiningOp<BufferLikeInterface>())
        if (op == buffer->getParentOp()) {
          buffer->moveBefore(op);
          op.getResult(result.getOperandNumber())
              .replaceAllUsesWith(buffer.getMemref());
          return success();
        }
    return failure();
  }
};
} // namespace

namespace {
// If an alloc is filled before any other uses, the alloc can be converted to a
// buffer with initial value.
template <typename OpType>
struct ConvertAllocToBufferWithInitValue : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    DominanceInfo DT;
    SmallVector<Operation *> users(op->user_begin(), op->user_end());
    llvm::sort(users, [&](auto a, auto b) { return DT.dominates(a, b); });

    if (auto fill = dyn_cast<linalg::FillOp>(users.front()))
      if (auto constant = fill.value().getDefiningOp<arith::ConstantOp>()) {
        rewriter.replaceOpWithNewOp<BufferOp>(op, op.getType(),
                                              /*depth=*/1, constant.getValue());
        rewriter.eraseOp(fill);
        return success();
      }
    return failure();
  }
};
} // namespace

namespace {
template <typename OpType>
struct ConvertAllocToBuffer : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<BufferOp>(op, op.getType());
    return success();
  }
};
} // namespace

namespace {
struct ConvertGetGlobalToConstBuffer
    : public OpRewritePattern<memref::GetGlobalOp> {
  using OpRewritePattern<memref::GetGlobalOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::GetGlobalOp op,
                                PatternRewriter &rewriter) const override {
    auto global = SymbolTable::lookupNearestSymbolFrom<memref::GlobalOp>(
        op, op.nameAttr());
    rewriter.replaceOpWithNewOp<ConstBufferOp>(op, global.type(),
                                               global.getConstantInitValue());
    return success();
  }
};
} // namespace

void scalehls::populateBufferConversionPatterns(RewritePatternSet &patterns) {
  auto context = patterns.getContext();
  patterns.add<ConvertAllocToBufferWithInitValue<memref::AllocOp>>(context);
  patterns.add<ConvertAllocToBufferWithInitValue<memref::AllocaOp>>(context);
  patterns.add<ConvertAllocToBuffer<memref::AllocOp>>(context);
  patterns.add<ConvertAllocToBuffer<memref::AllocaOp>>(context);
  patterns.add<ConvertGetGlobalToConstBuffer>(context);
}

namespace {
struct BufferizeDataflow : public BufferizeDataflowBase<BufferizeDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    populateBufferConversionPatterns(patterns);
    patterns.add<BufferizeDispatchOrTask<DispatchOp>>(context);
    patterns.add<BufferizeDispatchOrTask<TaskOp>>(context);
    patterns.add<HoistBuffer<DispatchOp>>(context);
    patterns.add<HoistBuffer<TaskOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createBufferizeDataflowPass() {
  return std::make_unique<BufferizeDataflow>();
}
