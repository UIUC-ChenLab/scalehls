//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/CallGraph.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SCCIterator.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

// static NodeOp fuseOps(ArrayRef<Operation *> ops, PatternRewriter &rewriter) {
//   assert(!ops.empty() && "must fuse at least two nodes");
//   llvm::SmallDenseSet<Operation *, 16> opSet(ops.begin(), ops.end());

//   // Collect inputs and outputs of the new node.
//   llvm::SmallDenseSet<Value, 8> inputs;
//   llvm::SmallDenseSet<Value, 8> outputs;
//   llvm::SmallDenseSet<Operation *, 8> streamReads;
//   SmallVector<Operation *, 8> streamWrites;
//   for (auto op : ops) {
//     op->walk([&](Operation *op) {
//       // Handle memory inputs and outputs.
//       if (auto store = dyn_cast<mlir::AffineWriteOpInterface>(op))
//         outputs.insert(store.getMemRef());
//       else if (auto store = dyn_cast<memref::StoreOp>(op))
//         outputs.insert(store.memref());
//       else if (auto copy = dyn_cast<memref::CopyOp>(op)) {
//         outputs.insert(copy.target());
//         inputs.insert(copy.source());
//       } else {
//         // TODO: Is this safe in general?
//         for (auto operand : op->getOperands())
//           if (operand.getType().isa<MemRefType>())
//             inputs.insert(operand);
//       }

//       // Handle normal SSA operands.
//       for (auto operand : op->getOperands()) {
//         if (opSet.count(operand.getDefiningOp()))
//           continue;
//         else if (auto read = operand.getDefiningOp<StreamReadOp>())
//           streamReads.insert(read);
//         else
//           op->emitOpError("operand has illegal defining op");
//       }

//       // Handle normal SSA results.
//       for (auto result : op->getResults()) {

//       }
//     });
//   }

//   // Construct the new node after the last node.
//   rewriter.setInsertionPointAfter(nodes.back());
//   auto newNode =
//       rewriter.create<NodeOp>(rewriter.getUnknownLoc(), inputs, outputs);
//   auto block = rewriter.createBlock(&newNode.body());
//   block->addArguments(ValueRange(inputs), inputLocs);
//   block->addArguments(ValueRange(outputs), outputLocs);

//   for (auto node : nodes)
//     node->moveBefore(block, block->end());
//   for (auto t : llvm::zip(newNode.getOperands(), block->getArguments()))
//     std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
//       return newNode->isProperAncestor(use.getOwner());
//     });
//   return newNode;
// }

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
      if (isa<linalg::LinalgDialect, tosa::TosaDialect, tensor::TensorDialect,
              bufferization::BufferizationDialect>(op.getDialect()) ||
          isa<func::CallOp, NodeOp>(op)) {
        return op.emitOpError(
            "linalg/tosa/tensor/bufferization operations are not supported, "
            "function call should have been inlined");

      } else if (isa<BufferOp, ConstBufferOp, arith::ConstantOp,
                     memref::AllocOp, memref::AllocaOp>(op)) {
        // Constant or memory operations are moved to the begining and skipped.
        op.moveBefore(&block, block.begin());

      } else if (&op == block.getTerminator()) {
        // If the block is empty, directly return.
        if (opsToFuse.empty())
          return failure();
        // fuseOpsIntoNewNode(opsToFuse, rewriter);
        opsToFuse.clear();

      } else if (isa<AffineForOp, scf::ForOp>(op)) {
        // We always take loop as root operation and fuse all the collected
        // operations so far.
        opsToFuse.push_back(&op);
        // fuseOpsIntoNewNode(opsToFuse, rewriter);
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
struct CreateDataflowFromAffine
    : public CreateDataflowFromAffineBase<CreateDataflowFromAffine> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<DataflowNodeCreatePattern<func::FuncOp>>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));

    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);

    // Create loop dataflow to each innermost loop.
    patterns.clear();
    patterns.add<DataflowNodeCreatePattern<mlir::AffineForOp>>(context);
    FrozenRewritePatternSet frozenPatterns(std::move(patterns));
    for (auto &band : targetBands)
      (void)applyOpPatternsAndFold(band.back(), frozenPatterns);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateDataflowFromAffinePass() {
  return std::make_unique<CreateDataflowFromAffine>();
}
