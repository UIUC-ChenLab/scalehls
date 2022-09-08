//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct NodeConversionPattern : public OpRewritePattern<NodeOp> {
  NodeConversionPattern(MLIRContext *context, StringRef prefix,
                        unsigned &nodeIdx)
      : OpRewritePattern<NodeOp>(context), prefix(prefix), nodeIdx(nodeIdx) {}

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    // Create a new sub-function.
    rewriter.setInsertionPoint(node->getParentOfType<func::FuncOp>());
    auto subFunc = rewriter.create<func::FuncOp>(
        node.getLoc(), prefix.str() + "_node" + std::to_string(nodeIdx++),
        rewriter.getFunctionType(node.getOperandTypes(), TypeRange()));

    // Inline the contents of the dataflow node.
    rewriter.inlineRegionBefore(node.getBodyRegion(), subFunc.getBody(),
                                subFunc.end());
    rewriter.setInsertionPointToEnd(&subFunc.front());
    rewriter.create<func::ReturnOp>(rewriter.getUnknownLoc());

    // Replace original with a function call.
    rewriter.setInsertionPoint(node);
    rewriter.create<func::CallOp>(node.getLoc(), subFunc, node.getOperands());
    rewriter.eraseOp(node);

    setFuncDirective(subFunc, false, 1, true);
    return success();
  }

private:
  StringRef prefix;
  unsigned &nodeIdx;
};
} // namespace

namespace {
struct BufferConversionPattern : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp buffer,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<memref::AllocOp>(buffer, buffer.getType());
    return success();
  }
};
} // namespace

namespace {
struct PromoteConstBufferPattern : public OpRewritePattern<ConstBufferOp> {
  using OpRewritePattern<ConstBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ConstBufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (buffer.getType().getNumElements() < 1024)
      return failure();

    if (auto node = buffer->getParentOfType<NodeOp>()) {
      buffer->moveBefore(node);
      SmallVector<Value, 8> inputs(node.inputs());
      inputs.push_back(buffer.memref());

      auto newArg = node.getBody()->insertArgument(
          node.getNumInputs(), buffer.getType(), buffer.getLoc());
      buffer.memref().replaceAllUsesWith(newArg);

      rewriter.setInsertionPoint(node);
      auto newNode =
          rewriter.create<NodeOp>(node.getLoc(), inputs, node.outputs());
      rewriter.inlineRegionBefore(node.body(), newNode.body(),
                                  newNode.body().end());
      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct ConvertDataflowToFunc
    : public ConvertDataflowToFuncBase<ConvertDataflowToFunc> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      mlir::RewritePatternSet patterns(context);
      patterns.add<PromoteConstBufferPattern>(context);
      (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

      ConversionTarget target(*context);
      target.addIllegalOp<NodeOp, BufferOp>();
      target.addLegalOp<func::FuncOp, func::ReturnOp, func::CallOp,
                        memref::AllocOp>();

      unsigned nodeIdx = 0;
      patterns.clear();
      patterns.add<NodeConversionPattern>(context, func.getName(), nodeIdx);
      patterns.add<BufferConversionPattern>(context);
      if (failed(applyPartialConversion(func, target, std::move(patterns))))
        return signalPassFailure();
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertDataflowToFuncPass() {
  return std::make_unique<ConvertDataflowToFunc>();
}
