//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Transforms/DialectConversion.h"
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

    setFuncDirective(subFunc, false, 1, true);
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

/// Localize each tosa/arith constant to right before its each use. Only
/// localize the constants whose size is below the bitsThreshold.
static void localizeConstants(Block &block, int64_t bitsThreshold = INT64_MAX) {
  auto builder = OpBuilder(block.getParentOp());

  // Collect all constants.
  SmallVector<Operation *, 16> constants;
  block.walk([&](Operation *constant) {
    if (isa<arith::ConstantOp, PrimConstOp>(constant)) {
      auto type = constant->getResult(0).getType();
      if (auto shapedType = type.dyn_cast<ShapedType>()) {
        if (shapedType.getSizeInBits() <= bitsThreshold)
          constants.push_back(constant);
      } else
        constants.push_back(constant);
    }
  });

  // Localize constants to each of its use.
  for (auto constant : constants) {
    for (auto &use : llvm::make_early_inc_range(constant->getUses())) {
      // Avoid to move constant across loop nests.
      if (auto loop = use.getOwner()->getParentOfType<mlir::AffineForOp>())
        if (loop != constant->getParentOp())
          continue;
      builder.setInsertionPoint(use.getOwner());
      auto cloneConstant = builder.clone(*constant);
      use.set(cloneConstant->getResult(0));
    }
    if (constant->use_empty())
      constant->erase();
  }
}

namespace {
struct ConvertDataflowToFunc
    : public ConvertDataflowToFuncBase<ConvertDataflowToFunc> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    // FIXME: Here we set a magic number as threshold, which is the size in bits
    // of one Xilinx BRAM instance.
    localizeConstants(*module.getBody(), 1024 * 16);

    // Hoist the memrefs and stream channels outputed by each node.
    // TODO: Maybe this should be factored out to somewhere else.
    module.walk([&](DataflowNodeOp node) {
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
    });

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
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
