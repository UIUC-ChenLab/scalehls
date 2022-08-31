//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ConstBufferConversionPattern
    : public OpRewritePattern<arith::ConstantOp> {
  using OpRewritePattern<arith::ConstantOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(arith::ConstantOp op,
                                PatternRewriter &rewriter) const override {
    if (auto type = op.getType().dyn_cast<TensorType>()) {
      auto memrefType = MemRefType::get(type.getShape(), type.getElementType());
      rewriter.setInsertionPoint(op);
      auto memref = rewriter.create<ConstBufferOp>(
          op.getLoc(), memrefType, op.getValue().cast<ElementsAttr>());
      rewriter.replaceOpWithNewOp<bufferization::ToTensorOp>(op, memref);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
template <typename OpType>
struct BufferConversionPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<BufferOp>(op, op.getType(), /*depth=*/1);
    return success();
  }
};
} // namespace

namespace {
struct GraphNodeBufferizationPattern : public OpRewritePattern<GraphNodeOp> {
  using OpRewritePattern<GraphNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(GraphNodeOp op,
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

        rewriter.setInsertionPoint(op.getOutputOp());
        auto output = op.getOutputOp().getOperand(result.getResultNumber());
        auto memref = rewriter.create<bufferization::ToMemrefOp>(
            rewriter.getUnknownLoc(), memrefType, output);
        op.getOutputOp().outputsMutable().assign(memref);
      }
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct NodeConversionPattern : public OpRewritePattern<GraphNodeOp> {
  using OpRewritePattern<GraphNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(GraphNodeOp op,
                                PatternRewriter &rewriter) const override {
    SmallVector<Value, 8> outputMemrefs;
    SmallVector<Location, 8> outputLocs;
    for (auto output : op.getOutputOp().getOperands()) {
      auto buffer = output.getDefiningOp();
      if (!isa<BufferOp>(buffer))
        return op.emitOpError("output memref must be defined by buffer op");
      buffer->moveBefore(op);
      outputMemrefs.push_back(output);
      outputLocs.push_back(output.getLoc());
    }

    rewriter.setInsertionPoint(op);
    auto node = rewriter.create<NodeOp>(rewriter.getUnknownLoc(),
                                        op.getOperands(), outputMemrefs);
    rewriter.inlineRegionBefore(op.body(), node.body(), node.body().end());
    node.getBody()->getTerminator()->erase();

    auto args =
        node.getBody()->addArguments(ValueRange(outputMemrefs), outputLocs);
    for (auto t : llvm::zip(outputMemrefs, args))
      std::get<0>(t).replaceAllUsesExcept(std::get<1>(t), node);
    rewriter.replaceOp(op, outputMemrefs);
    return success();
  }
};
} // namespace

namespace {
struct ConvertGraphToDataflow
    : public ConvertGraphToDataflowBase<ConvertGraphToDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    // The intention of split the conversion into two parts is to allow the
    // bufferization ops being canonicalized away.
    mlir::RewritePatternSet patterns(context);
    patterns.add<ConstBufferConversionPattern>(context);
    patterns.add<BufferConversionPattern<memref::AllocOp>>(context);
    patterns.add<BufferConversionPattern<memref::AllocaOp>>(context);
    patterns.add<GraphNodeBufferizationPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    // Convert dataflow node operations.
    patterns.clear();
    patterns.add<NodeConversionPattern>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertGraphToDataflowPass() {
  return std::make_unique<ConvertGraphToDataflow>();
}
