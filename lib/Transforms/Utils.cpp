//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Utils.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
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

/// Localize each tosa/arith constant to right before its each use. Only
/// localize the constants whose size is below the bitsThreshold.
void scalehls::localizeConstants(Block &block, int64_t bitsThreshold) {
  auto builder = OpBuilder(block.getParentOp());

  // Collect all constants.
  SmallVector<Operation *, 16> constants;
  block.walk([&](Operation *constant) {
    if (isa<tosa::ConstOp, arith::ConstantOp>(constant)) {
      auto type = constant->getResult(0).getType();
      if (auto shapedType = type.dyn_cast<ShapedType>()) {
        if (shapedType.getSizeInBits() <= bitsThreshold)
          constants.push_back(constant);
      } else
        constants.push_back(constant);
    }
  });

  // Localize constants to each of its use.
  for (auto constant : constants) {
    for (auto &use : llvm::make_early_inc_range(constant->getUses())) {
      builder.setInsertionPoint(use.getOwner());
      auto cloneConstant = builder.clone(*constant);
      use.set(cloneConstant->getResult(0));
    }
    constant->erase();
  }
}

/// Inline all child nodes in the given node recursively.
static void inlineChildNodes(DataflowNodeOp node, PatternRewriter &rewriter) {
  auto &nodeOps = node.body().front().getOperations();
  for (auto childNode :
       llvm::make_early_inc_range(node.getOps<DataflowNodeOp>())) {
    inlineChildNodes(childNode, rewriter);
    auto &childNodeOps = childNode.body().front().getOperations();
    nodeOps.splice(childNode->getIterator(), childNodeOps, childNodeOps.begin(),
                   std::prev(childNodeOps.end()));
    rewriter.replaceOp(childNode, childNode.getOutputOp().getOperands());
  }
}

/// Fuse the given operations into a new dataflow node. The fused node will be
/// created before the first operation and each operation will be inserted in
/// order. This method always succeeds.
DataflowNodeOp scalehls::fuseOpsIntoNewNode(ArrayRef<Operation *> ops,
                                            PatternRewriter &rewriter) {
  assert(!ops.empty() && "must fuse at least one op");
  if (ops.size() == 1)
    if (auto node = dyn_cast<DataflowNodeOp>(ops.front()))
      return node;

  SmallVector<Value, 4> outputValues;
  SmallVector<Type, 4> outputTypes;
  for (auto op : ops)
    for (auto result : op->getResults()) {
      // Only if any user of the result is used outside of "ops", we need to
      // return it as a node output.
      if (llvm::any_of(result.getUsers(), [&](Operation *user) {
            return llvm::all_of(
                ops, [&](Operation *op) { return !op->isAncestor(user); });
          })) {
        outputValues.push_back(result);
        outputTypes.push_back(result.getType());
      }
    }

  // Create new dataflow node.
  auto loc = rewriter.getUnknownLoc();
  rewriter.setInsertionPoint(ops.front());
  auto node = rewriter.create<DataflowNodeOp>(loc, outputTypes);
  auto nodeBlock = rewriter.createBlock(&node.body());

  // Create new dataflow output and move each targeted op before the output.
  rewriter.setInsertionPointToEnd(nodeBlock);
  auto output = rewriter.create<DataflowOutputOp>(loc, outputValues);
  for (auto op : ops)
    op->moveBefore(output);

  // Replace external uses with the node results.
  for (auto t : llvm::zip(outputValues, node.getResults()))
    std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
      return !node->isProperAncestor(use.getOwner());
    });

  // Inline all child nodes.
  inlineChildNodes(node, rewriter);
  return node;
}
