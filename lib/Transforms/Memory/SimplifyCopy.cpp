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
template <typename OpType>
struct SimplifyBuffer : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType buf,
                                PatternRewriter &rewriter) const override {
    auto DT = DominanceInfo();
    auto getCopyUser = [&]() {
      for (auto user : buf->getUsers())
        if (auto copyUser = dyn_cast<memref::CopyOp>(user))
          return copyUser;
      return memref::CopyOp();
    };

    // If the current buf is not used by any copy, return failure.
    auto copy = getCopyUser();
    if (!copy)
      return failure();

    // If the current buf dominates another buf, return failure.
    auto anotherVal = buf.getMemref() == copy.getSource() ? copy.getTarget()
                                                          : copy.getSource();
    if (auto anotherBuf = anotherVal.getDefiningOp())
      if (DT.dominates(buf.getOperation(), anotherBuf))
        return failure();
    if (buf.getType().getMemorySpaceAsInt() !=
        anotherVal.getType().template cast<MemRefType>().getMemorySpaceAsInt())
      return failure();

    // If the source memory is used after the copy op, we cannot eliminate the
    // target memory. This is conservative?
    if (llvm::any_of(copy.getSource().getUsers(), [&](Operation *user) {
          return DT.properlyDominates(copy, user);
        }))
      return failure();

    // If the target memory is used before the copy op, we cannot eliminate
    // the target memory. This is conservative?
    if (llvm::any_of(copy.getTarget().getUsers(), [&](Operation *user) {
          return DT.properlyDominates(user, copy);
        }))
      return failure();

    rewriter.replaceOp(buf, anotherVal);
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
    patterns.add<SimplifyBuffer<BufferOp>>(context);
    patterns.add<SimplifyBuffer<memref::AllocOp>>(context);
    patterns.add<SimplifyBuffer<memref::AllocaOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSimplifyCopyPass() {
  return std::make_unique<SimplifyCopy>();
}
