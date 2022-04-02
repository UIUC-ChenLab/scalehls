//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Transforms/Dataflower.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct DataflowGraph {
  DataflowGraph(Block &block);

  /// A dataflow use includes the intermediate value and the user operation,
  /// which is similar to the concept of OpOperand in the SSA graph.
  using DataflowUse = std::pair<Value, Operation *>;
  using DataflowUses = SmallVector<DataflowUse, 4>;

  /// A mapping from an operation to all its dataflow uses.
  using DataflowUsesMap = llvm::SmallDenseMap<Operation *, DataflowUses, 64>;

  bool hasNode(Operation *node) const { return nodes.count(node); }
  DataflowUses getNodeUses(Operation *node) const {
    return usesMap.lookup(node);
  }

private:
  // Hold all nodes in the dataflow graph.
  llvm::SmallDenseSet<Operation *, 64> nodes;

  // Hold the uses mapping.
  DataflowUsesMap usesMap;
};
} // namespace

DataflowGraph::DataflowGraph(Block &block) {
  // Results map of each operation.
  DenseMap<Operation *, llvm::SmallDenseSet<Value, 2>> resultsMap;

  for (auto &op : block) {
    // Handle copy operations.
    if (auto copy = dyn_cast<memref::CopyOp>(op))
      resultsMap[&op].insert(copy.getTarget());

    // Handle memory stores. Child regions are recursively traversed, such that
    // for and if operations are considered as a node of the dataflow.
    op.walk([&](Operation *child) {
      // TODO: Support transfer write?
      if (auto affineStore = dyn_cast<mlir::AffineWriteOpInterface>(child)) {
        resultsMap[&op].insert(affineStore.getMemRef());
      } else if (auto store = dyn_cast<memref::StoreOp>(child))
        resultsMap[&op].insert(store.getMemRef());
    });

    // Handle normal SSA results.
    for (auto result : op.getResults())
      resultsMap[&op].insert(result);
  }

  // Get the dominace tree for later use.
  DominanceInfo DT(block.getParentOp());

  // Find successors of all operations.
  for (auto &op : block) {
    // Some operations are dataflow source/sink nodes, which will not be
    // scheduled. TODO: Any other operations should appear here?
    if (isa<tosa::ConstOp, arith::ConstantOp, func::ReturnOp, AffineYieldOp,
            scf::YieldOp>(op) ||
        (op.getNumResults() == 1 &&
         op.getResult(0).getType().isa<MemRefType>()))
      continue;
    nodes.insert(&op);

    for (auto result : resultsMap.lookup(&op)) {
      for (auto user : result.getUsers()) {
        // If the same block user doesn't exist, or is a return operation, or is
        // not properly dominated, continue. Meanwhile, if the same block user
        // is another updater of the result, continue. The rationale is we want
        // to make sure all the updaters of a memory are scheduled into the same
        // dataflow level.
        auto sameBlockUser = block.findAncestorOpInBlock(*user);
        if (!sameBlockUser || isa<func::ReturnOp>(sameBlockUser) ||
            !DT.properlyDominates(&op, sameBlockUser) ||
            resultsMap.lookup(sameBlockUser).count(result))
          continue;

        // Only push back non-exist uses.
        // TODO: Create a DenseMapInfo struct to make use SmallDenseSet.
        auto &uses = usesMap[&op];
        auto newUse = DataflowUse({result, sameBlockUser});
        if (llvm::find(uses, newUse) == uses.end())
          uses.push_back(newUse);
      }
    }
  }
}

namespace {
struct Dataflower {
  Dataflower(Block &block, StringRef prefix)
      : block(block), graph(block), prefix(prefix) {}

  /// Legalize the dataflow of "block", whose parent operation must be a
  /// function or affine loop. Return false if the legalization failed, for
  /// example, the dataflow has cycles.
  bool applyLegalizeDataflow(int64_t gran, bool balance);

  /// Split each dataflow stage of "block" into a separate sub-function.
  bool applySplitFunction();

private:
  Block &block;
  DataflowGraph graph;
  StringRef prefix;
};
} // namespace

/// Apply dataflow (coarse-grained pipeline) to the block. "gran" determines the
/// minimum granularity of dataflowing while "balance" indicates whether buffers
/// are inserted to balance the dataflow pipeline.
bool scalehls::applyDataflow(Block &block, StringRef prefix, unsigned gran,
                             bool balance) {
  auto rewriter = ScaleHLSDataflower(block.getParentOp()->getContext());
  auto loc = rewriter.getUnknownLoc();

  // Make sure all operations except the terminator are fused into dataflow
  // nodes. TODO: Support affine loop nest?
  localizeConstants(block);
  SmallVector<Operation *, 4> opsToFuse;
  for (auto &op : block) {
    if (isa<DataflowNodeOp>(op) || &op == block.getTerminator()) {
      if (!opsToFuse.empty())
        fuseOpsIntoNewNode(opsToFuse, rewriter);
      opsToFuse.clear();
    } else
      opsToFuse.push_back(&op);
  }

  // A helper to get the scheduled dataflow level.
  llvm::SmallDenseMap<Operation *, unsigned> dataflowLevelMap;
  auto getDataflowLevel = [&](Operation *op) {
    if (op == block.getTerminator())
      return (unsigned)0;
    if (!isa<DataflowNodeOp>(op))
      op = op->getParentOfType<DataflowNodeOp>();
    assert(op && dataflowLevelMap.count(op) && "unexpected dataflow op");
    return dataflowLevelMap.lookup(op);
  };

  // Schedule all dataflow nodes in an ALAP manner.
  llvm::SmallDenseMap<unsigned, SmallVector<Operation *>> dataflowOpsList;
  for (auto &node : llvm::drop_begin(llvm::reverse(block))) {
    unsigned level = 0;
    for (auto userLevel : llvm::map_range(node.getUsers(), getDataflowLevel))
      level = std::max(level, userLevel + 1);

    dataflowLevelMap[&node] = level;
    dataflowOpsList[level].push_back(&node);
  }

  // Fuse ops of each dataflow level into the same node.
  dataflowLevelMap.clear();
  for (const auto &p : dataflowOpsList) {
    auto node = fuseOpsIntoNewNode(p.second, rewriter);
    dataflowLevelMap[node] = p.first;
  }

  // Now, we have legalized the dataflow into a feed-forward path and we can
  // handle the bypass uses through inserting dataflow buffers.
  for (auto node : llvm::make_early_inc_range(block.getOps<DataflowNodeOp>())) {
    auto level = getDataflowLevel(node);

    // TODO: For now, we always create a new buffer for each bypass use. To be
    // more efficient, we should reuse buffers as much as possible.
    for (auto &use : llvm::make_early_inc_range(node->getUses())) {
      auto levelDiff = level - getDataflowLevel(use.getOwner());
      if (levelDiff > 1) {
        rewriter.setInsertionPointAfter(node);
        auto buffer = rewriter.create<DataflowBufferOp>(
            loc, use.get().getType(), use.get(), /*depth=*/levelDiff - 1);
        use.set(buffer.output());
      }
    }
  }

  // auto parentOp = block.getParentOp();
  // if (isa<FuncOp>(parentOp))
  //   setFuncDirective(parentOp, false, 1, true);
  // else if (isa<AffineForOp, scf::ForOp>(parentOp))
  //   setLoopDirective(parentOp, false, 1, true, false);
  // else
  //   return false;
  return true;
}

namespace {
struct FuncDataflow : public FuncDataflowBase<FuncDataflow> {
  FuncDataflow() = default;
  FuncDataflow(std::string dataflowTargetFunc, unsigned dataflowGran,
               bool dataflowBalance) {
    targetFunc = dataflowTargetFunc;
    gran = dataflowGran;
    balance = dataflowBalance;
  }

  void runOnOperation() override {
    auto module = getOperation();

    // Dataflow each functions in the module.
    for (auto func : llvm::make_early_inc_range(module.getOps<FuncOp>()))
      if (func.getName() == targetFunc)
        applyDataflow(func.front(), func.getName(), gran, balance);
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createFuncDataflowPass(std::string dataflowTargetFunc,
                                 unsigned dataflowGran, bool dataflowBalance) {
  return std::make_unique<FuncDataflow>(dataflowTargetFunc, dataflowGran,
                                        dataflowBalance);
}
