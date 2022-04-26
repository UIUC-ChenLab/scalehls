//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Utils.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static void addMemoryOptsPipeline(PassManager &pm) {
  // To factor out the redundant affine operations.
  pm.addPass(createAffineLoopNormalizePass());
  pm.addPass(createSimplifyAffineStructuresPass());
  pm.addPass(createCanonicalizerPass());
  pm.addPass(createSimplifyAffineIfPass());

  // To simplify the memory accessing. Note that the store forwarding is
  // non-trivial and has a worst case complexity of O(n^2).
  pm.addPass(createAffineStoreForwardPass());
  pm.addPass(createSimplifyMemrefAccessPass());

  // Generic common sub expression elimination.
  pm.addPass(createCSEPass());
  pm.addPass(createReduceInitialIntervalPass());
}

/// Apply memory optimizations.
bool scalehls::applyMemoryOpts(FuncOp func) {
  PassManager optPM(func.getContext(), "func.func");
  addMemoryOptsPipeline(optPM);
  if (failed(optPM.run(func)))
    return false;
  return true;
}

/// Apply optimization strategy to a loop band. The ancestor function is also
/// passed in because the post-tiling optimizations have to take function as
/// target, e.g. canonicalizer and array partition.
bool scalehls::applyOptStrategy(AffineLoopBand &band, FuncOp func,
                                TileList tileList, unsigned targetII) {
  // By design the input function must be the ancestor of the input loop band.
  if (!func->isProperAncestor(band.front()))
    return false;

  // Apply loop tiling.
  if (!applyLoopTiling(band, tileList))
    return false;

  // Apply loop pipelining.
  if (!applyLoopPipelining(band, band.size() - 1, targetII))
    return false;

  // Apply memory access optimizations and the best suitable array partition
  // strategy to the function.
  applyMemoryOpts(func);
  applyAutoArrayPartition(func);
  return true;
}

/// Apply optimization strategy to a function.
bool scalehls::applyOptStrategy(FuncOp func, ArrayRef<TileList> tileLists,
                                ArrayRef<unsigned> targetIIs) {
  AffineLoopBands bands;
  getLoopBands(func.front(), bands);
  assert(bands.size() == tileLists.size() && bands.size() == targetIIs.size() &&
         "unexpected size of tile lists or target IIs");

  // Apply loop tiling to all loop bands.
  for (unsigned i = 0, e = bands.size(); i < e; ++i)
    if (!applyLoopTiling(bands[i], tileLists[i]))
      return false;

  for (unsigned i = 0, e = bands.size(); i < e; ++i)
    if (!applyLoopPipelining(bands[i], bands[i].size() - 1, targetIIs[i]))
      return false;

  // Apply memory access optimizations and the best suitable array partition
  // strategy to the function.
  applyMemoryOpts(func);
  applyAutoArrayPartition(func);
  return true;
}

static DataflowNodeOp generateNodeOutputs(DataflowNodeOp node,
                                          PatternRewriter &rewriter) {
  // Create output operation.
  auto outputValues = node.getOutputValues();
  rewriter.setInsertionPointToEnd(node.getBody());
  rewriter.create<DataflowOutputOp>(rewriter.getUnknownLoc(), outputValues);

  // Create a new node with outputs.
  rewriter.setInsertionPoint(node);
  auto newNode =
      rewriter.create<DataflowNodeOp>(node.getLoc(), ValueRange(outputValues));

  // Inline all ops of the original node.
  rewriter.inlineRegionBefore(node.body(), newNode.body(),
                              newNode.body().end());
  rewriter.eraseOp(node);

  // Replace external uses with the node results if the user is dominated by the
  // current dataflow node.
  DominanceInfo DT;
  for (auto t : llvm::zip(outputValues, newNode.getResults()))
    std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
      return !newNode->isProperAncestor(use.getOwner()) &&
             DT.properlyDominates(newNode, use.getOwner());
    });
  return newNode;
}

/// Fuse the given operations into a new dataflow node. The fused node will be
/// created before the first operation and each operation will be inserted in
/// order. All the child nodes and functions are inlined afterward. Such that
/// this method must be applied AFTER all functions are duplicated. This method
/// always succeeds.
DataflowNodeOp scalehls::fuseOpsIntoNewNode(ArrayRef<Operation *> ops,
                                            PatternRewriter &rewriter) {
  assert(!ops.empty() && "must fuse at least one op");

  // Create new dataflow node.
  auto loc = rewriter.getUnknownLoc();
  rewriter.setInsertionPoint(ops.front());
  auto node = rewriter.create<DataflowNodeOp>(loc, TypeRange());

  // Create a node block and move each targeted op into it.
  auto nodeBlock = rewriter.createBlock(&node.body());
  for (auto op : ops)
    op->moveBefore(nodeBlock, nodeBlock->end());

  // Inline all child nodes or functions. Note that the inlining will not be
  // applied recursively.
  auto &nodeOps = nodeBlock->getOperations();
  for (auto &child : llvm::make_early_inc_range(*nodeBlock)) {
    if (auto childNode = dyn_cast<DataflowNodeOp>(child)) {
      auto &childNodeOps = childNode.getBody()->getOperations();
      nodeOps.splice(childNode->getIterator(), childNodeOps,
                     childNodeOps.begin(), std::prev(childNodeOps.end()));
      rewriter.replaceOp(childNode, childNode.getOutputOp().getOperands());

    } else if (auto call = dyn_cast<func::CallOp>(child)) {
      auto func = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
          call, call.getCalleeAttr());
      assert(func && llvm::hasSingleElement(func) &&
             "failed to find legal function definition");

      auto &funcOps = func.front().getOperations();
      nodeOps.splice(call->getIterator(), funcOps, funcOps.begin(),
                     std::prev(funcOps.end()));

      for (auto t : llvm::zip(func.getArguments(), call.getOperands()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      rewriter.replaceOp(call, func.front().getTerminator()->getOperands());
      rewriter.eraseOp(func);
    }
  }

  // Create outputs for the dataflow node.
  return generateNodeOutputs(node, rewriter);
}
