//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Transforms/DialectConversion.h"
#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct NodeConversionPattern : public OpRewritePattern<DataflowNodeOp> {
  NodeConversionPattern(MLIRContext *context, StringRef prefix,
                        unsigned &nodeIdx)
      : OpRewritePattern<DataflowNodeOp>(context), prefix(prefix),
        nodeIdx(nodeIdx) {}

  LogicalResult matchAndRewrite(DataflowNodeOp op,
                                PatternRewriter &rewriter) const override {
    // Analyze the input values and types of the function to create.
    auto liveness = Liveness(op);
    SmallVector<Value, 8> inputs;
    SmallVector<Type, 8> inputTypes;
    for (auto livein : liveness.getLiveIn(op.getBody())) {
      if (op->isAncestor(livein.getParentBlock()->getParentOp()))
        continue;
      inputs.push_back(livein);
      inputTypes.push_back(livein.getType());
    }

    // Create a new sub-function.
    rewriter.setInsertionPoint(op->getParentOfType<func::FuncOp>());
    auto subFunc = rewriter.create<func::FuncOp>(
        op.getLoc(), prefix.str() + "_node" + std::to_string(nodeIdx++),
        rewriter.getFunctionType(inputTypes, TypeRange()));

    // Inline the contents of the dataflow node.
    rewriter.inlineRegionBefore(op.getBodyRegion(), subFunc.getBody(),
                                subFunc.end());
    auto entry = &subFunc.front();
    for (auto input : inputs) {
      auto arg = entry->addArgument(input.getType(), input.getLoc());
      input.replaceUsesWithIf(arg, [&](OpOperand &use) {
        return subFunc->isAncestor(use.getOwner());
      });
    }

    // Replace the original output terminator and dataflow node itself.
    auto output = entry->getTerminator();
    rewriter.setInsertionPoint(output);
    rewriter.replaceOpWithNewOp<func::ReturnOp>(output);
    rewriter.setInsertionPoint(op);
    rewriter.create<func::CallOp>(op.getLoc(), subFunc, inputs);
    rewriter.eraseOp(op);
    return success();
  }

private:
  StringRef prefix;
  unsigned &nodeIdx;
};
} // namespace

namespace {
struct BufferConversionPattern : public OpRewritePattern<DataflowBufferOp> {
  using OpRewritePattern<DataflowBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowBufferOp op,
                                PatternRewriter &rewriter) const override {
    if (auto alloc = op.input().getDefiningOp<memref::AllocOp>()) {
      rewriter.setInsertionPoint(alloc);
      auto primBuffer = rewriter.replaceOpWithNewOp<PrimBufferOp>(
          op, op.getType(), op.depth());
      rewriter.replaceOp(alloc, primBuffer.memref());
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
    localizeConstants(*module.getBody());

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      // Hoist the memrefs and stream channels outputed by each node.
      // TODO: Maybe this should be factored out to somewhere else.
      for (auto node : func.getOps<DataflowNodeOp>()) {
        auto output = node.getOutputOp();
        for (auto &use : output->getOpOperands()) {
          // TODO: Support other types of outputs?
          if (!use.get().getType().isa<MemRefType, StreamType>()) {
            output.emitOpError("dataflow output has not been bufferized");
            return signalPassFailure();
          }

          if (auto defOp = use.get().getDefiningOp())
            if (node->isAncestor(defOp))
              defOp->moveBefore(node);
          node.getResult(use.getOperandNumber()).replaceAllUsesWith(use.get());
        }
      }

      // Convert dataflow node and buffer operations.
      ConversionTarget target(*context);
      target.addIllegalOp<DataflowNodeOp, DataflowOutputOp, DataflowBufferOp>();
      target.addLegalOp<func::FuncOp, func::ReturnOp, func::CallOp,
                        PrimBufferOp>();

      unsigned nodeIdx = 0;
      mlir::RewritePatternSet patterns(context);
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
