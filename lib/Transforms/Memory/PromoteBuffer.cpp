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
using namespace hls;

static void createBufferAndCopy(MemRefType type, Value memref,
                                OpBuilder &builder) {
  // We strip the original layout map and memory kind when constructing the
  // local buffer's memref type.
  auto bufType = MemRefType::get(type.getShape(), type.getElementType());
  auto loc = builder.getUnknownLoc();

  // Check the read/write status of the memref.
  auto readFlag = llvm::any_of(memref.getUsers(), [](Operation *op) {
    return isa<mlir::AffineReadOpInterface, memref::LoadOp, func::CallOp>(op);
  });
  auto writeFlag = llvm::any_of(memref.getUsers(), [](Operation *op) {
    return isa<mlir::AffineWriteOpInterface, memref::StoreOp, func::CallOp>(op);
  });

  // Allocate an on-chip buffer and replace all its uses.
  assert((readFlag || writeFlag) && "found unused memref");
  auto buf = builder.create<memref::AllocOp>(loc, bufType);
  memref.replaceAllUsesWith(buf);

  if (readFlag && !writeFlag) {
    // If the on-chip buffer is read-only, we copy the data from DDR to buffer
    // right after the buffer allocation.
    builder.create<memref::CopyOp>(loc, memref, buf);

  } else if (!readFlag && writeFlag) {
    // If the on-chip buffer is write-only, we copy the data from buffer to DDR
    // at the end of the current region.
    builder.setInsertionPoint(memref.getParentRegion()->back().getTerminator());
    builder.create<memref::CopyOp>(loc, buf, memref);

  } else {
    // Otherwise, if the on-chip buffer has both read and write, to enable the
    // pipeline between load-compute-store, we must create another "result"
    // buffer and carry out the computation over the "result" buffer.
    auto resultBuf = builder.create<memref::AllocOp>(loc, bufType);
    buf.memref().replaceAllUsesWith(resultBuf);

    builder.create<memref::CopyOp>(loc, memref, buf);
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
    if (subview.source().getType().cast<MemRefType>().getMemorySpaceAsInt() !=
        (unsigned)MemoryKind::DRAM)
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

    // We assume after create-axi-interface, we should not allocate any on-chip
    // buffer in the top function. TODO: Make this an option.
    if (hasTopFuncAttr(func) || hasRuntimeAttr(func))
      return;

    // Promote function arguments that are not only used by subviews.
    for (auto arg : func.getArguments()) {
      auto type = arg.getType().dyn_cast<MemRefType>();
      if (!type || type.getMemorySpaceAsInt() != (unsigned)MemoryKind::DRAM ||
          llvm::all_of(arg.getUsers(), [&](Operation *op) {
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
