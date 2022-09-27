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
  CreateLocalBuffer() = default;
  CreateLocalBuffer(bool argExternalBufferOnly, bool argRegisterOnly) {
    externalBufferOnly = argExternalBufferOnly;
    registerOnly = argRegisterOnly;
  }

  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    func.walk([&](memref::SubViewOp subview) {
      if (externalBufferOnly && !isExternalBuffer(subview.source()))
        return WalkResult::advance();

      if (registerOnly && subview.getType().getNumElements() != 1)
        return WalkResult::advance();

      // Check the read/write status of the memref.
      auto readFlag = llvm::any_of(subview->getUses(), isRead);
      auto writeFlag = llvm::any_of(subview->getUses(), isWritten);
      if (!readFlag && !writeFlag)
        return WalkResult::advance();

      // We strip the original layout map and memory kind when constructing the
      // local buffer's memref type.
      auto bufType = MemRefType::get(
          subview.getType().getShape(), subview.getType().getElementType(),
          AffineMap(), (unsigned)MemoryKind::BRAM_S2P);

      // Allocate an on-chip buffer and replace all its uses.
      auto loc = builder.getUnknownLoc();
      builder.setInsertionPointAfter(subview);
      auto buf = builder.create<BufferOp>(loc, bufType);
      subview.result().replaceAllUsesWith(buf);

      // If the global buffer has initial value, set it to the local buffer.
      auto globalBuf = findBufferOp(subview.getSource());
      if (globalBuf && globalBuf.getBufferInitValue())
        buf.setInitValueAttr(globalBuf.getBufferInitValue().value());

      // Create explicit copy from/to the local buffer.
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

std::unique_ptr<Pass>
scalehls::createCreateLocalBufferPass(bool externalBufferOnly,
                                      bool registerOnly) {
  return std::make_unique<CreateLocalBuffer>(externalBufferOnly, registerOnly);
}
