//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct NodeBufferizePattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPointAfter(op);
    bool hasChanged = false;
    for (auto result : op.getResults()) {
      if (auto tensorType = result.getType().dyn_cast<TensorType>()) {
        auto memrefType =
            MemRefType::get(tensorType.getShape(), tensorType.getElementType());
        result.setType(memrefType);
        auto tensor =
            rewriter.create<bufferization::ToTensorOp>(op.getLoc(), result);
        result.replaceAllUsesExcept(tensor.result(), tensor);
        hasChanged = true;

      } else if (!result.getType().isa<ShapedType, StreamType>()) {
        auto streamType =
            StreamType::get(result.getType().getContext(), result.getType(), 1);
        result.setType(streamType);
        hasChanged = true;
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct OutputBufferizePattern : public OpRewritePattern<DataflowOutputOp> {
  using OpRewritePattern<DataflowOutputOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowOutputOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPoint(op);
    bool hasChanged = false;
    for (auto &use : llvm::make_early_inc_range(op->getOpOperands())) {
      if (auto tensorType = use.get().getType().dyn_cast<TensorType>()) {
        auto memrefType =
            MemRefType::get(tensorType.getShape(), tensorType.getElementType());
        auto memref = rewriter.create<bufferization::ToMemrefOp>(
            op.getLoc(), memrefType, use.get());
        use.set(memref);
        hasChanged = true;

      } else if (!use.get().getType().isa<ShapedType, StreamType>()) {
        auto streamType = StreamType::get(use.get().getType().getContext(),
                                          use.get().getType(), 1);
        auto channel =
            rewriter.create<StreamChannelOp>(op.getLoc(), streamType);
        rewriter.create<StreamWriteOp>(op.getLoc(), channel, use.get());
        use.set(channel);
        hasChanged = true;
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct SourceBufferizePattern : public OpRewritePattern<DataflowSourceOp> {
  using OpRewritePattern<DataflowSourceOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowSourceOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPoint(op);
    rewriter.replaceOpWithNewOp<arith::ConstantOp>(
        op, rewriter.getZeroAttr(op.getType()));
    return success();
  }
};
} // namespace

namespace {
struct SinkBufferizePattern : public OpRewritePattern<DataflowSinkOp> {
  using OpRewritePattern<DataflowSinkOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowSinkOp op,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPoint(op);
    rewriter.replaceOpWithNewOp<StreamReadOp>(op, Type(), op.input());
    return success();
  }
};
} // namespace

namespace {
struct BufferBufferizePattern : public OpRewritePattern<DataflowBufferOp> {
  using OpRewritePattern<DataflowBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowBufferOp op,
                                PatternRewriter &rewriter) const override {
    if (auto tensorType = op.getType().dyn_cast<TensorType>()) {
      auto memrefType =
          MemRefType::get(tensorType.getShape(), tensorType.getElementType());

      rewriter.setInsertionPoint(op);
      auto memref = rewriter.create<bufferization::ToMemrefOp>(
          op.getLoc(), memrefType, op.input());
      op.inputMutable().assign(memref);

      rewriter.setInsertionPointAfter(op);
      op.output().setType(memrefType);
      auto tensor =
          rewriter.create<bufferization::ToTensorOp>(op.getLoc(), op.output());
      op.output().replaceAllUsesExcept(tensor.result(), tensor);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct ConstantBufferizePattern
    : public OpRewritePattern<bufferization::ToMemrefOp> {
  using OpRewritePattern<bufferization::ToMemrefOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(bufferization::ToMemrefOp op,
                                PatternRewriter &rewriter) const override {
    if (auto constant = op.tensor().getDefiningOp<arith::ConstantOp>()) {
      rewriter.setInsertionPoint(op);
      rewriter.replaceOpWithNewOp<PrimConstOp>(
          op, op.getType(), constant.getValue().cast<ElementsAttr>());
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
    patterns.add<NodeBufferizePattern>(context);
    patterns.add<OutputBufferizePattern>(context);
    patterns.add<SourceBufferizePattern>(context);
    patterns.add<SinkBufferizePattern>(context);
    patterns.add<BufferBufferizePattern>(context);
    patterns.add<ConstantBufferizePattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createBufferizeDataflowPass() {
  return std::make_unique<BufferizeDataflow>();
}
