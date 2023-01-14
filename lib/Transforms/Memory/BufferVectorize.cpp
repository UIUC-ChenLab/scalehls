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

LogicalResult vectorizeMemref(Value memref) {
  auto layout = getTileLayout(memref);
  if (!isExtBuffer(memref) || !layout)
    return failure();

  auto ctx = memref.getContext();
  auto b = OpBuilder(ctx);
  auto type = memref.getType().cast<MemRefType>();

  // Apply the buffer layout.
  memref.setType(MemRefType::get(type.getShape(), type.getElementType(), layout,
                                 type.getMemorySpace()));

  // Calculate the new memref type after vectorization.
  auto newShape = SmallVector<int64_t>(type.getShape());
  auto vectorLength = 1;
  for (auto [size, vectorSize] : llvm::zip(newShape, layout.getVectorShape())) {
    size /= vectorSize;
    vectorLength *= vectorSize;
  }

  auto newElementType = type.getElementType();
  if (layout.isVectorized())
    newElementType = VectorType::get({vectorLength}, type.getElementType());
  auto newType = MemRefType::get(newShape, newElementType, AffineMap(),
                                 type.getMemorySpace());
  memref.setType(newType);

  // Insert devectorize op after the memref for adapting to its uses.
  b.setInsertionPointAfterValue(memref);
  auto newMemref =
      b.create<BufferDevectorizeOp>(memref.getLoc(), newType, memref);
  memref.replaceUsesWithIf(
      newMemref, [&](OpOperand &use) { return use.getOwner() != newMemref; });

  return success();
}

namespace {
struct Materializelayout : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    for (auto arg : func.getArguments())
      if (succeeded(vectorizeMemref(arg))) {
        hasChanged = true;
        func.removeArgAttr(arg.getArgNumber(), "hls.buffer_info");
      }

    func.walk([&](hls::BufferLikeInterface buffer) {
      if (succeeded(vectorizeMemref(buffer.getMemref()))) {
        hasChanged = true;
        buffer->removeAttr("buffer_info");
      }
    });

    if (hasChanged) {
      // Update the type of schedules and nodes recursively.
      for (auto schedule : func.getOps<ScheduleOp>())
        schedule.updateSignatureRecursively();

      // Update the type of the function.
      func.setType(rewriter.getFunctionType(
          func.front().getArgumentTypes(),
          func.front().getTerminator()->getOperandTypes()));
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct LowerTransferRead : public OpRewritePattern<vector::TransferReadOp> {
  using OpRewritePattern<vector::TransferReadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(vector::TransferReadOp read,
                                PatternRewriter &rewriter) const override {
    auto vectorType =
        read.getShapedType().getElementType().dyn_cast<VectorType>();
    if (!vectorType ||
        vectorType.getNumElements() != read.getVectorType().getNumElements())
      return failure();

    if (isExtBuffer(read.getSource())) {
      read.getResult().setType(vectorType);
      rewriter.replaceOpWithNewOp<vector::LoadOp>(
          read, vectorType, read.getSource(), read.getIndices());
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct LowerTransferWrite : public OpRewritePattern<vector::TransferWriteOp> {
  using OpRewritePattern<vector::TransferWriteOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(vector::TransferWriteOp write,
                                PatternRewriter &rewriter) const override {
    auto vectorType =
        write.getShapedType().getElementType().dyn_cast<VectorType>();
    if (!vectorType || vectorType != write.getVectorType())
      return failure();

    if (isExtBuffer(write.getSource())) {
      rewriter.replaceOpWithNewOp<vector::StoreOp>(
          write, write.getVector(), write.getSource(), write.getIndices());
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct BufferVectorize : public BufferVectorizeBase<BufferVectorize> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<Materializelayout>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));

    patterns.clear();
    patterns.add<LowerTransferRead>(context);
    patterns.add<LowerTransferWrite>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createBufferVectorizePass() {
  return std::make_unique<BufferVectorize>();
}
