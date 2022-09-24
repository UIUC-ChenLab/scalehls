//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct SimplifyBuffer : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp buf,
                                PatternRewriter &rewriter) const override {
    auto DT = DominanceInfo();
    auto getCopyUser = [&]() {
      for (auto user : buf->getUsers())
        if (auto copyUser = dyn_cast<memref::CopyOp>(user))
          return copyUser;
      return memref::CopyOp();
    };

    // If the current buffer is not used by any copy, return failure.
    memref::CopyOp copy = getCopyUser();
    if (!copy)
      return failure();

    // Get the the other buffer of the copy op.
    bool bufIsSource = buf.getMemref() == copy.getSource();
    auto theOtherBuf = bufIsSource ? copy.getTarget() : copy.getSource();
    auto theOtherOp = theOtherBuf.getDefiningOp();

    // If the current buffer is allocated at different memory space with the
    // the other buffer, return failure.
    if (buf.getType().getMemorySpaceAsInt() !=
        theOtherBuf.getType().template cast<MemRefType>().getMemorySpaceAsInt())
      return failure();

    // If the current buffer is source buffer and has initial value, but the the
    // other buffer is a block argument or not a buffer op, return failure.
    if (bufIsSource && buf.getInitValue() &&
        (!theOtherOp || !isa<BufferOp>(theOtherOp)))
      return failure();

    // If the other buffer exists but doesn't dominate the current buffer,
    // return failure.
    if (theOtherOp && DT.dominates(buf.getOperation(), theOtherOp))
      return failure();

    // If the source buffer is used after the copy op, we cannot eliminate the
    // copy op. This is conservative.
    if (llvm::any_of(copy.getSource().getUsers(), [&](Operation *user) {
          return DT.properlyDominates(copy, user);
        }))
      return failure();

    // If the target buffer is used before the copy op, we cannot eliminate the
    // copy op as well. This is conservative.
    if (llvm::any_of(copy.getTarget().getUsers(), [&](Operation *user) {
          return DT.properlyDominates(user, copy);
        }))
      return failure();

    // If the other buffer doesn't have an initial value, we assign the initial
    // value of current buffer to it. This is safe as undefined initial value
    // means the users of the other buffer are not sensitive to it.
    if (bufIsSource && buf.getInitValue())
      cast<BufferOp>(theOtherOp).setInitValueAttr(buf.getInitValue().value());

    // Finally, we can replace the current buffer with the other buffer and
    // erase the copy op as well.
    rewriter.replaceOp(buf, theOtherBuf);
    rewriter.eraseOp(copy);
    return success();
  }
};
} // namespace

namespace {
struct SimplifyCopy : public SimplifyCopyBase<SimplifyCopy> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<SimplifyBuffer>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSimplifyCopyPass() {
  return std::make_unique<SimplifyCopy>();
}
