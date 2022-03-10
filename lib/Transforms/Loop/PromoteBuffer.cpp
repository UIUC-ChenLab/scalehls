//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/AffineExprVisitor.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

static void createBufferAndCopy(MemRefType type, Value memref,
                                OpBuilder &builder) {
  // We strip the original layout map and memory kind when constructing the
  // local buffer's memref type.
  auto bufType = MemRefType::get(type.getShape(), type.getElementType());
  auto loc = builder.getUnknownLoc();

  // Allocate an on-chip buffer and create a copy from memory to the buffer.
  auto buf = builder.create<memref::AllocOp>(loc, bufType);
  memref.replaceAllUsesWith(buf);
  auto copy = builder.create<memref::CopyOp>(loc, memref, buf);

  // If the buffer's state is updated in the function, create a copy from the
  // buffer to memory.
  if (llvm::any_of(buf->getUsers(), [](Operation *op) {
        return isa<AffineWriteOpInterface, memref::StoreOp>(op);
      })) {
    // Create another result buffer to prepare for the dataflowing.
    auto resultBuf = builder.create<memref::AllocOp>(loc, bufType);
    buf.memref().replaceAllUsesExcept(resultBuf, copy);
    builder.create<memref::CopyOp>(loc, buf, resultBuf);

    builder.setInsertionPoint(memref.getParentRegion()->back().getTerminator());
    builder.create<memref::CopyOp>(loc, resultBuf, memref);
  }
}

namespace {
struct PromoteBufferPattern : public OpRewritePattern<memref::SubViewOp> {
  using OpRewritePattern<memref::SubViewOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::SubViewOp subview,
                                PatternRewriter &rewriter) const override {
    if (!subview.source().isa<BlockArgument>())
      return failure();

    rewriter.setInsertionPointAfter(subview);
    createBufferAndCopy(subview.getType(), subview.result(), rewriter);
    return success();
  }
};
} //  namespace

namespace {
struct PromoteBuffer : public scalehls::PromoteBufferBase<PromoteBuffer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    // Promote function arguments that are not only used by subviews.
    for (auto arg : func.getArguments()) {
      auto type = arg.getType().dyn_cast<MemRefType>();
      if (!type || llvm::all_of(arg.getUsers(), [&](Operation *op) {
            return isa<memref::SubViewOp>(op);
          }))
        continue;

      builder.setInsertionPointToStart(&func.front());
      createBufferAndCopy(type, arg, builder);
    }

    // Promote subviews to local buffers.
    mlir::RewritePatternSet patterns(func.getContext());
    patterns.add<PromoteBufferPattern>(func.getContext());
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns),
                                       {false, true, 1});
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createPromoteBufferPass() {
  return std::make_unique<PromoteBuffer>();
}
