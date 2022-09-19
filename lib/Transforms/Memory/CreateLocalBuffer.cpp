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

namespace {
struct CreateLocalBuffer
    : public scalehls::CreateLocalBufferBase<CreateLocalBuffer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    func.walk([&](memref::SubViewOp subview) {
      if (!isExternalBuffer(subview.source()))
        return WalkResult::advance();

      // We strip the original layout map and memory kind when constructing the
      // local buffer's memref type.
      auto bufType = MemRefType::get(
          subview.getType().getShape(), subview.getType().getElementType(),
          AffineMap(), (unsigned)MemoryKind::BRAM_S2P);

      // Check the read/write status of the memref.
      auto readFlag = llvm::any_of(subview->getUses(), isRead);
      auto writeFlag = llvm::any_of(subview->getUses(), isWritten);
      if (!readFlag && !writeFlag)
        return WalkResult::advance();

      // Allocate an on-chip buffer and replace all its uses.
      auto loc = builder.getUnknownLoc();
      builder.setInsertionPointAfter(subview);
      auto buf = builder.create<BufferOp>(loc, bufType);
      subview.result().replaceAllUsesWith(buf);

      if (readFlag)
        builder.create<memref::CopyOp>(loc, subview, buf);
      if (writeFlag) {
        builder.setInsertionPoint(subview->getBlock()->getTerminator());
        builder.create<memref::CopyOp>(loc, buf, subview);
      }
      return WalkResult::advance();
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateLocalBufferPass() {
  return std::make_unique<CreateLocalBuffer>();
}
