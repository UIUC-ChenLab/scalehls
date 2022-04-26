//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/CallGraph.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SCCIterator.h"

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
    // figure out any other operations need to be separately handled. For
    // example, how to handle AffineIfOp?
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
        // If the block is empty, directly return.
        if (opsToFuse.empty())
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
struct CreateDataflow : public CreateDataflowBase<CreateDataflow> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    CallGraph graph(module);

    // If any cycle appears in the call graph, return.
    using SCCIterator = llvm::scc_iterator<const CallGraph *>;
    for (auto scc = SCCIterator::begin(&graph); !scc.isAtEnd(); ++scc)
      if (scc.hasCycle()) {
        emitError(module.getLoc(), "has cycle in the call graph");
        return signalPassFailure();
      }

    // Traverse each function in a post order and dataflow each of them.
    mlir::RewritePatternSet patterns(context);
    for (auto node : llvm::make_early_inc_range(
             llvm::post_order<const CallGraph *>(&graph))) {
      if (node->isExternal())
        continue;

      if (auto func =
              node->getCallableRegion()->getParentOfType<func::FuncOp>()) {
        // Collect all target loop bands in the current function. FIXME: Using
        // getTileableBands is a temporary solution.
        AffineLoopBands targetBands;
        getTileableBands(func, &targetBands);

        // Create dataflow to the innermost loop of each loop band.
        patterns.clear();
        patterns.add<DataflowNodeCreatePattern<mlir::AffineForOp>>(context);
        FrozenRewritePatternSet loopPattern(std::move(patterns));
        for (auto &band : targetBands)
          (void)applyOpPatternsAndFold(band.back(), loopPattern);

        // Create dataflow to the function itself.
        patterns.clear();
        patterns.add<DataflowNodeCreatePattern<func::FuncOp>>(context);
        FrozenRewritePatternSet funcPattern(std::move(patterns));
        (void)applyOpPatternsAndFold(func, funcPattern);
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowPass() {
  return std::make_unique<CreateDataflow>();
}
