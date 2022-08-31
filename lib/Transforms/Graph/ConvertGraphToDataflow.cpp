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
struct NodeConversionPattern : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp op,
                                PatternRewriter &rewriter) const override {
    return success();
  }
};
} // namespace

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
struct ConvertGraphToDataflow
    : public ConvertGraphToDataflowBase<ConvertGraphToDataflow> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    // FIXME: Here we set a magic number as threshold, which is the size in bits
    // of one Xilinx BRAM instance.
    // localizeConstants(*module.getBody(), 1024 * 16);

    // // Hoist the memrefs and stream channels outputed by each node.
    // // TODO: Maybe this should be factored out to somewhere else.
    // module.walk([&](DataflowNodeOp node) {
    //   auto output = node.getOutputOp();
    //   for (auto &use : output->getOpOperands()) {
    //     // TODO: Support other types of outputs?
    //     if (!use.get().getType().isa<MemRefType, StreamType>()) {
    //       output.emitOpError("dataflow output has not been bufferized");
    //       return signalPassFailure();
    //     }

    //     if (auto defOp = use.get().getDefiningOp())
    //       if (node->isAncestor(defOp))
    //         defOp->moveBefore(node);
    //     node.getResult(use.getOperandNumber()).replaceAllUsesWith(use.get());
    //   }
    // });

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      // Convert dataflow node and buffer operations.
      ConversionTarget target(*context);
      target
          .addIllegalOp<arith::ConstantOp, memref::AllocOp, memref::AllocaOp>();
      target.addLegalOp<ConstBufferOp, BufferOp>();
      target.addDynamicallyLegalOp<arith::ConstantOp>(
          [](arith::ConstantOp op) { return !op.getType().isa<TensorType>(); });

      mlir::RewritePatternSet patterns(context);
      patterns.add<NodeConversionPattern>(context);
      patterns.add<ConstBufferConversionPattern>(context);
      patterns.add<BufferConversionPattern<memref::AllocOp>>(context);
      patterns.add<BufferConversionPattern<memref::AllocaOp>>(context);

      // if (failed(applyPartialConversion(func, target, std::move(patterns))))
      //   return signalPassFailure();

      if (failed(applyPatternsAndFoldGreedily(func, std::move(patterns))))
        return signalPassFailure();
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertGraphToDataflowPass() {
  return std::make_unique<ConvertGraphToDataflow>();
}
