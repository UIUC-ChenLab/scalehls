//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "scalehls-simplify-copy"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct SplitElementwiseGenericOp : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(linalg::GenericOp op,
                                PatternRewriter &rewriter) const override {
    if (isElementwiseGenericOp(op) && op.getInputs().size() == 1 &&
        op.getOutputs().size() == 1) {
      auto &input = op->getOpOperand(0);
      auto &output = op->getOpOperand(1);
      if (input.get() == output.get())
        return failure();

      rewriter.create<memref::CopyOp>(op.getLoc(), input.get(), output.get());
      input.set(output.get());
      return success();
    }
    return failure();
  }
};
} // namespace

static void findBufferUsers(Value memref, SmallVector<Operation *> &users) {
  for (auto user : memref.getUsers()) {
    if (auto viewOp = dyn_cast<ViewLikeOpInterface>(user))
      findBufferUsers(viewOp->getResult(0), users);
    else
      users.push_back(user);
  }
}

namespace {
struct SimplifyBufferCopy : public OpRewritePattern<memref::CopyOp> {
  using OpRewritePattern<memref::CopyOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::CopyOp copy,
                                PatternRewriter &rewriter) const override {
    LLVM_DEBUG(llvm::dbgs() << "\nCurrent copy: " << copy << "\n";);

    // If the source and target buffers are allocated in different memory space,
    // return failure.
    auto sourceType = copy.getSource().getType().template cast<MemRefType>();
    auto targetType = copy.getTarget().getType().template cast<MemRefType>();
    if (sourceType.getMemorySpaceAsInt() != targetType.getMemorySpaceAsInt())
      return failure();

    LLVM_DEBUG(llvm::dbgs() << "Located at the same memory space\n";);

    // Both the source and target buffers should be block arguments or defined
    // by BufferOp, otherwise return failure.
    auto source = findBuffer(copy.getSource());
    auto target = findBuffer(copy.getTarget());
    if (!source || !target)
      return failure();

    LLVM_DEBUG(llvm::dbgs() << "Defined by block argument or BufferOp\n";);

    // If both the source and target buffers are block arguments, return failure
    // as either of them can be eliminated.
    auto sourceBuf = source.getDefiningOp<BufferOp>();
    auto targetBuf = target.getDefiningOp<BufferOp>();
    if (!sourceBuf && !targetBuf)
      return failure();

    LLVM_DEBUG(llvm::dbgs() << "At least one buffer is replaceable\n";);

    // Collect all users of the source and target buffer.
    SmallVector<Operation *> sourceUsers;
    SmallVector<Operation *> targetUsers;
    findBufferUsers(source, sourceUsers);
    findBufferUsers(target, targetUsers);

    // Collect the dominating and dominated buffer users.
    SmallVector<Operation *> sourceDomUsers;
    SmallVector<Operation *> sourcePostDomUsers;
    SmallVector<Operation *> targetDomUsers;
    SmallVector<Operation *> targetPostDomUsers;

    for (auto user : sourceUsers) {
      if (user == copy)
        continue;
      else if (crossRegionDominates(user, copy))
        sourceDomUsers.push_back(user);
      else
        sourcePostDomUsers.push_back(user);
    }

    for (auto user : targetUsers) {
      if (user == copy)
        continue;
      else if (crossRegionDominates(user, copy))
        targetDomUsers.push_back(user);
      else
        targetPostDomUsers.push_back(user);
    }

    // A helper to check whether any user has write effect.
    auto hasWriteUsers = [](SmallVector<Operation *> users) {
      return llvm::any_of(users, [](Operation *user) {
        return hasEffect<MemoryEffects::Write>(user) ||
               isa<StreamWriteOp>(user);
      });
    };

    // If the source buffer has write users dominated by the copy and the target
    // buffer has users dominated by the copy, or vice versa, the copy cannot be
    // eliminated.
    if ((hasWriteUsers(sourcePostDomUsers) && !targetPostDomUsers.empty()) ||
        (hasWriteUsers(targetPostDomUsers) && !sourcePostDomUsers.empty()))
      return failure();

    // If the source buffer has writer users dominating the copy and the target
    // buffer has users dominating the copy, the copy cannot be eliminated.
    // Meanwhile, as long as the target buffer has users dominating the copy,
    // return failure.
    if ((hasWriteUsers(sourceDomUsers) && !targetDomUsers.empty()) ||
        hasWriteUsers(targetDomUsers))
      return failure();

    // If both the source and target buffer have users dominating the copy
    // (which should both be read only), the init value must be the same.
    if (!sourceDomUsers.empty() && !targetDomUsers.empty())
      if ((!sourceBuf || !targetBuf) ||
          (sourceBuf.getInitValue() && targetBuf.getInitValue() &&
           sourceBuf.getInitValue().value() !=
               targetBuf.getInitValue().value()))
        return failure();

    LLVM_DEBUG(llvm::dbgs() << "Dominances are valid\n");

    auto sourceView = copy.getSource().getDefiningOp();
    auto targetView = copy.getTarget().getDefiningOp();
    DominanceInfo domInfo;

    // To replace the target buffer, the buffer must be directly defined by a
    // BufferOp without view. Meanwhile, the source view should either be a
    // block argument or dominate all users of the target buffer.
    // TODO: The second condition is quite conservative and could be improved by
    // analyzing whether the source view can be replaced to the location of the
    // target buffer.
    if (targetBuf && targetBuf == targetView &&
        (!sourceView || llvm::all_of(targetUsers, [&](Operation *user) {
          return domInfo.dominates(sourceView, user);
        }))) {
      LLVM_DEBUG(llvm::dbgs() << "Target and copy is erased\n");

      rewriter.replaceOp(targetBuf, copy.getSource());
      rewriter.eraseOp(copy);
      return success();
    }

    // Similarly, we need the same conditions to replace the source buffer.
    if (sourceBuf && sourceBuf == sourceView &&
        (!targetView || llvm::all_of(sourceUsers, [&](Operation *user) {
          return domInfo.dominates(targetView, user);
        }))) {
      // If the source buffer has initial value, the value must be pertained
      // by the target buffer after the replacement. Therefore, we have some
      // additional conditions here to check.
      if (sourceBuf.getInitValue()) {
        if (!targetBuf || (targetBuf.getInitValue() && targetBuf != targetView))
          return failure();
        targetBuf.setInitValueAttr(sourceBuf.getInitValue().value());
      }
      LLVM_DEBUG(llvm::dbgs() << "Source and copy are erased\n");

      rewriter.replaceOp(sourceBuf, copy.getTarget());
      rewriter.eraseOp(copy);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct SimplifyCopy : public SimplifyCopyBase<SimplifyCopy> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<SplitElementwiseGenericOp>(context);
    patterns.add<SimplifyBufferCopy>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSimplifyCopyPass() {
  return std::make_unique<SimplifyCopy>();
}
