//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/Matchers.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct AllocOpRewritePattern : public OpRewritePattern<memref::AllocOp> {
  AllocOpRewritePattern(MLIRContext *context, DominanceInfo &DT)
      : OpRewritePattern(context), DT(DT) {}
  using OpRewritePattern<memref::AllocOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::AllocOp alloc,
                                PatternRewriter &rewriter) const override {
    auto getCopyUser = [&]() {
      for (auto user : alloc->getUsers())
        if (auto copyUser = dyn_cast<memref::CopyOp>(user))
          return copyUser;
      return memref::CopyOp();
    };

    // If the current alloc is not used by any copy, return failure.
    auto copy = getCopyUser();
    if (!copy)
      return failure();

    // If the current alloc dominates another alloc, return failure.
    auto anotherMemref = alloc.memref() == copy.getSource() ? copy.getTarget()
                                                            : copy.getSource();
    if (auto anotherAlloc = anotherMemref.getDefiningOp())
      if (DT.dominates(alloc.getOperation(), anotherAlloc))
        return failure();
    if (alloc.getType().getMemorySpaceAsInt() !=
        anotherMemref.getType().cast<MemRefType>().getMemorySpaceAsInt())
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

    rewriter.replaceOp(alloc, anotherMemref);
    rewriter.eraseOp(copy);

    return success();
  }

private:
  DominanceInfo &DT;
};
} // namespace

namespace {
struct BufferOpRewritePattern : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp assign,
                                PatternRewriter &rewriter) const override {
    if (!assign->hasOneUse())
      return failure();

    auto toTensorOp = assign.input().getDefiningOp<bufferization::ToTensorOp>();
    auto toMemrefOp =
        dyn_cast<bufferization::ToMemrefOp>(*assign.output().user_begin());
    if (!toTensorOp || !toMemrefOp)
      return failure();

    // Convert the tensor assign to an explicit alloc+copy.
    rewriter.setInsertionPointAfter(toMemrefOp);
    rewriter.create<memref::CopyOp>(assign.getLoc(), toTensorOp.memref(),
                                    toMemrefOp.memref());
    rewriter.replaceOpWithNewOp<memref::AllocOp>(
        toMemrefOp, toMemrefOp.getType().cast<MemRefType>());
    rewriter.eraseOp(assign);

    return success();
  }
};
} // namespace

namespace {
/// From the semantics point of view, reshape should not introduce a redundant
/// memref copy. However, in HLS, a reinterpret-like statement will obstruct the
/// array partition of the on-chip memory. Therefore, we convert reshape to
/// explict alloc and copy in this lowering.
struct ReshapeOpLoweringPattern : public OpRewritePattern<tensor::ReshapeOp> {
  using OpRewritePattern<tensor::ReshapeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(tensor::ReshapeOp reshape,
                                PatternRewriter &rewriter) const override {
    if (!reshape->hasOneUse())
      return failure();

    auto toTensorOp =
        reshape.source().getDefiningOp<bufferization::ToTensorOp>();
    auto toMemrefOp =
        dyn_cast<bufferization::ToMemrefOp>(*reshape.result().user_begin());
    if (!toTensorOp || !toMemrefOp)
      return failure();

    auto inputType = toTensorOp.memref().getType().cast<MemRefType>();
    auto resultType = toMemrefOp.getType().cast<MemRefType>();
    auto loc = reshape.getLoc();

    // Create a single loop to traverse all elements of the memrefs.
    rewriter.setInsertionPointAfter(toMemrefOp);
    auto loop =
        rewriter.create<mlir::AffineForOp>(loc, 0, resultType.getNumElements());
    rewriter.setInsertionPointToStart(loop.getBody());

    // A helper to get the memory access map.
    auto getMemrefAccessMap = [&](MemRefType type) {
      unsigned rank = type.getRank();
      SmallVector<AffineExpr, 4> exprs(rank, rewriter.getAffineDimExpr(0));

      for (unsigned dim = 0; dim < rank; ++dim)
        for (unsigned idx = 0; idx < dim; ++idx)
          exprs[idx] = exprs[idx].floorDiv(type.getDimSize(dim));

      for (unsigned idx = 0; idx < rank; ++idx) {
        auto &expr = exprs[idx];
        if (auto constantExpr = expr.dyn_cast<AffineDimExpr>())
          if (resultType.getNumElements() <= type.getDimSize(idx))
            continue;
        expr = expr % type.getDimSize(idx);
      }

      return AffineMap::get(/*dimCount=*/1, 0, exprs, rewriter.getContext());
    };

    // Create affine load/store operations.
    auto value = rewriter.create<mlir::AffineLoadOp>(
        loc, toTensorOp.memref(), getMemrefAccessMap(inputType),
        loop.getInductionVar());
    rewriter.create<mlir::AffineStoreOp>(loc, value, toMemrefOp.memref(),
                                         getMemrefAccessMap(resultType),
                                         loop.getInductionVar());

    // Convert the reshape result to an explicit alloc.
    rewriter.setInsertionPointAfter(toMemrefOp);
    rewriter.replaceOpWithNewOp<memref::AllocOp>(toMemrefOp, resultType);
    rewriter.eraseOp(reshape);

    return success();
  }
};
} // namespace

namespace {
struct CopyOpLoweringPattern : public OpRewritePattern<memref::CopyOp> {
  CopyOpLoweringPattern(MLIRContext *context, bool internCopyOnly = true)
      : OpRewritePattern(context), internCopyOnly(internCopyOnly) {}

  using OpRewritePattern<memref::CopyOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::CopyOp copy,
                                PatternRewriter &rewriter) const override {
    // Check whether the copy op communicates with an AXI interface.
    auto isAxiInterf =
        copy.source().getType().cast<MemRefType>().getMemorySpaceAsInt() ==
            (unsigned)MemoryKind::DRAM ||
        copy.target().getType().cast<MemRefType>().getMemorySpaceAsInt() ==
            (unsigned)MemoryKind::DRAM;

    // Return failure if we don't need to lower copy op with AXI interfaces.
    if (internCopyOnly && isAxiInterf)
      return failure();

    rewriter.setInsertionPoint(copy);
    auto loc = copy.getLoc();
    auto memrefType = copy.source().getType().cast<MemRefType>();

    // Create explicit memory copy using an affine loop nest.
    SmallVector<Value, 4> ivs;
    for (auto dimSize : memrefType.getShape()) {
      auto loop = rewriter.create<mlir::AffineForOp>(loc, 0, dimSize);
      // If the copy op is not with  an AXI interface, we consider the loop as
      // point loop that needs to be optimized later.
      if (!isAxiInterf)
        setPointAttr(loop);
      rewriter.setInsertionPointToStart(loop.getBody());
      ivs.push_back(loop.getInductionVar());
    }

    // Create affine load/store operations.
    auto value = rewriter.create<mlir::AffineLoadOp>(loc, copy.source(), ivs);
    rewriter.create<mlir::AffineStoreOp>(loc, value, copy.target(), ivs);

    rewriter.eraseOp(copy);
    return success();
  }

private:
  bool internCopyOnly = true;
};
} // namespace

namespace {
struct ConvertCopyToAffineLoops
    : public ConvertCopyToAffineLoopsBase<ConvertCopyToAffineLoops> {
  ConvertCopyToAffineLoops() = default;
  ConvertCopyToAffineLoops(bool convertInternCopyOnly) {
    internCopyOnly = convertInternCopyOnly;
  }

  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    auto DT = DominanceInfo(module);

    // Simplify alloc and copy ops.
    mlir::RewritePatternSet patterns(context);
    patterns.add<AllocOpRewritePattern>(context, DT);
    patterns.add<BufferOpRewritePattern>(context);
    patterns.add<ReshapeOpLoweringPattern>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));

    // Lower copy and assign operation.
    patterns.clear();
    patterns.add<CopyOpLoweringPattern>(context, internCopyOnly);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createConvertCopyToAffineLoopsPass(bool convertInternCopyOnly) {
  return std::make_unique<ConvertCopyToAffineLoops>(convertInternCopyOnly);
}
