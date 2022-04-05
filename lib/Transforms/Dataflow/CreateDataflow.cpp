//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
/// Wrap operations in the front block into dataflow nodes based on heuristic if
/// they have not. FuncOp and AffineForOp are supported.
template <typename OpType>
struct DataflowNodeCreatePattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType target,
                                PatternRewriter &rewriter) const override {
    if (!llvm::hasSingleElement(target.getRegion()))
      return target.emitOpError("target region has multiple blocks");
    auto &block = target.getRegion().front();

    // Fuse operations into dataflow nodes. TODO: We need more case study to
    // figure out any other operations need to be separately handled.
    SmallVector<Operation *, 4> opsToFuse;
    for (auto &op : llvm::make_early_inc_range(block)) {
      if (isa<linalg::LinalgDialect>(op.getDialect())) {
        // Linalg operations have unique consumer and producer semantics that
        // cannot be handled by normal SSA analysis.
        return op.emitOpError("linalg op is not supported in dataflowing");

      } else if (isa<tosa::ConstOp, arith::ConstantOp, memref::AllocOp,
                     memref::AllocaOp>(op)) {
        // Constant or alloc operations are moved to the begining and skipped.
        op.moveBefore(&block, block.begin());

      } else if (isa<bufferization::BufferizationDialect>(op.getDialect())) {
        // Bufferization operation is moved right after its defining point,
        // which is either an operation or a block argument, and skipped.
        if (auto defOp = op.getOperand(0).getDefiningOp())
          op.moveAfter(defOp);
        else
          op.moveBefore(&block, block.begin());

      } else if (&op == block.getTerminator()) {
        // If the block is empty or only has one dataflow stage, we'll not touch
        // it and directly return.
        if (opsToFuse.empty() || opsToFuse.front() == &block.front())
          return failure();
        fuseOpsIntoNewNode(opsToFuse, rewriter);
        opsToFuse.clear();

      } else if (isa<DataflowNodeOp, AffineForOp, func::CallOp>(op) ||
                 isa<tosa::TosaDialect>(op.getDialect())) {
        // We always fuse dataflow node, affine loop, function call, and tosa
        // operation with all the collected operations.
        opsToFuse.push_back(&op);
        fuseOpsIntoNewNode(opsToFuse, rewriter);
        opsToFuse.clear();

      } else {
        // Otherwise, we push back the current operation to the list.
        opsToFuse.push_back(&op);
      }
    }
    return success();
  }
};
} // namespace

namespace {
struct CreateFuncDataflow : public CreateFuncDataflowBase<CreateFuncDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<DataflowNodeCreatePattern<func::FuncOp>>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));
  }
};
} // namespace

namespace {
struct CreateLoopDataflow : public CreateLoopDataflowBase<CreateLoopDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);

    // Create loop dataflow to each innermost loop.
    mlir::RewritePatternSet patterns(context);
    patterns.add<DataflowNodeCreatePattern<mlir::AffineForOp>>(context);
    FrozenRewritePatternSet frozenPatterns(std::move(patterns));
    for (auto &band : targetBands)
      (void)applyOpPatternsAndFold(band.back(), frozenPatterns);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateFuncDataflowPass() {
  return std::make_unique<CreateFuncDataflow>();
}

std::unique_ptr<Pass> scalehls::createCreateLoopDataflowPass() {
  return std::make_unique<CreateLoopDataflow>();
}
