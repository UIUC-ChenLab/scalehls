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

static void createBufferAndCopy(MemRefType type, Value memref,
                                OpBuilder &builder) {
  // We strip the original layout map and memory kind when constructing the
  // local buffer's memref type.
  auto bufType = MemRefType::get(type.getShape(), type.getElementType(),
                                 AffineMap(), (unsigned)MemoryKind::BRAM_S2P);
  auto loc = builder.getUnknownLoc();

  // Check the read/write status of the memref.
  auto readFlag = llvm::any_of(memref.getUsers(), [](Operation *op) {
    return isa<mlir::AffineReadOpInterface, memref::LoadOp, func::CallOp>(op);
  });
  auto writeFlag = llvm::any_of(memref.getUsers(), [](Operation *op) {
    return isa<mlir::AffineWriteOpInterface, memref::StoreOp, func::CallOp>(op);
  });

  // Allocate an on-chip buffer and replace all its uses.
  if (!readFlag && !writeFlag)
    return;
  auto buf = builder.create<BufferOp>(loc, bufType);
  memref.replaceAllUsesWith(buf);

  if (readFlag)
    builder.create<memref::CopyOp>(loc, memref, buf);
  if (writeFlag) {
    builder.setInsertionPoint(memref.getParentRegion()->back().getTerminator());
    builder.create<memref::CopyOp>(loc, buf, memref);
  }
}

namespace {
struct CreateLocalBufferPattern : public OpRewritePattern<memref::SubViewOp> {
  using OpRewritePattern<memref::SubViewOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::SubViewOp subview,
                                PatternRewriter &rewriter) const override {
    if (!isExternalBuffer(subview.source()))
      return failure();

    rewriter.setInsertionPointAfter(subview);
    createBufferAndCopy(subview.getType(), subview.result(), rewriter);
    return success();
  }
};
} //  namespace

namespace {
struct CreateLocalBuffer
    : public scalehls::CreateLocalBufferBase<CreateLocalBuffer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    // We assume after create-axi-interface, we should not allocate any on-chip
    // buffer in the top function. TODO: Make this an option.
    // if (hasTopFuncAttr(func) || hasRuntimeAttr(func))
    //   return;

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
    patterns.add<CreateLocalBufferPattern>(func.getContext());
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns),
                                       {false, true, 1});
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateLocalBufferPass() {
  return std::make_unique<CreateLocalBuffer>();
}
