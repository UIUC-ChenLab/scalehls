//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
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

/// Update
void ScaleHLSDataflower::updateDataflowUsesMap() {
  // Results map of each dataflow node.
  llvm::SmallDenseMap<Operation *, llvm::SmallDenseSet<Value, 2>> resultsMap;

  // We first need to identify the SSA and non-SSA dependencies between dataflow
  // nodes. For example, if a node updates the state of a memref, then all
  // dominated nodes that use the memref will depend on that node.
  for (auto node : block.getOps<DataflowNodeOp>()) {
    // Handle memory copy and store.
    node.walk([&](Operation *child) {
      if (auto copy = dyn_cast<memref::CopyOp>(child))
        resultsMap[node].insert(copy.getTarget());
      else if (auto affineStore = dyn_cast<mlir::AffineWriteOpInterface>(child))
        resultsMap[node].insert(affineStore.getMemRef());
    });

    // Handle normal SSA results.
    for (auto result : node.getResults())
      resultsMap[node].insert(result);
  }

  // Get the dominace tree for later use.
  DominanceInfo DT(block.getParentOp());

  // Find successors of all dataflow nodes.
  dataflowUsesMap.clear();
  for (auto node : block.getOps<DataflowNodeOp>())
    for (auto result : resultsMap.lookup(node))
      for (auto user : result.getUsers()) {
        // If the same block user doesn't exist, or is not a dataflow node, or
        // is not properly dominated, continue. Meanwhile, if the same block
        // user is another updater of the result, continue. The rationale is we
        // want to make sure all the updaters of a memory are scheduled into the
        // same dataflow level.
        auto sameBlockUser = block.findAncestorOpInBlock(*user);
        if (!sameBlockUser || !isa<DataflowNodeOp>(sameBlockUser) ||
            !DT.properlyDominates(node, sameBlockUser) ||
            resultsMap.lookup(sameBlockUser).count(result))
          continue;

        // Only push back non-exist uses.
        // TODO: Create a DenseMapInfo struct to make use SmallDenseSet.
        auto &uses = dataflowUsesMap[node];
        auto use = DataflowUse({result, cast<DataflowNodeOp>(sameBlockUser)});
        if (llvm::find(uses, use) == uses.end())
          uses.push_back(use);
      }
}

/// Wrap operations in the block into dataflow nodes based on heuristic if they
/// have not and identify the dependencies between dataflow nodes.
LogicalResult ScaleHLSDataflower::initializeDataflow() {
  localizeConstants(block);

  // Fuse operations into dataflow nodes.
  SmallVector<Operation *, 4> opsToFuse;
  for (auto &op : llvm::make_early_inc_range(block)) {
    // Linalg operations have unique consumer and producer semantics that cannot
    // be handled by normal SSA analysis. So we cannot support linalg ops.
    if (isa<linalg::LinalgDialect>(op.getDialect()))
      return op.emitOpError("linalg op is not supported in dataflowing");

    // Any constant operation or operation that generates memref is not wrapped
    // into dataflow node.
    if (isa<tosa::ConstOp, arith::ConstantOp>(op) ||
        llvm::any_of(op.getResultTypes(),
                     [](Type type) { return type.isa<MemRefType>(); }))
      continue;

    if (isa<DataflowNodeOp>(op) || &op == block.getTerminator()) {
      // Dataflow node op and block terminator doesn't need to be fused anymore.
      // So we just fuse the collected operations if any.
      if (!opsToFuse.empty())
        fuseOpsIntoNewNode(opsToFuse, *this);
      opsToFuse.clear();

    } else if (isa<AffineForOp, func::CallOp>(op) ||
               isa<tosa::TosaDialect>(op.getDialect())) {
      // We always fuse loop or function call with all the collected operations.
      opsToFuse.push_back(&op);
      fuseOpsIntoNewNode(opsToFuse, *this);
      opsToFuse.clear();

    } else {
      // Otherwise, we push back the current operation to the list.
      opsToFuse.push_back(&op);
    }
  }

  updateDataflowUsesMap();
  return success();
}

/// Get the dataflow level of an operation.
unsigned ScaleHLSDataflower::getDataflowLevel(Operation *op) const {
  if (op == block.getTerminator())
    return (unsigned)0;
  if (!isa<DataflowNodeOp>(op))
    op = op->getParentOfType<DataflowNodeOp>();
  assert(op && dataflowLevelMap.count(op) && "unexpected dataflow op");
  return dataflowLevelMap.lookup(op);
}

/// Legalize the dataflow creating a one-way feed-forward dataflow path
/// without bypass paths.
LogicalResult ScaleHLSDataflower::legalizeDataflow() {
  // Schedule all dataflow nodes in an ALAP manner.
  llvm::SmallDenseMap<unsigned, SmallVector<Operation *>> dataflowOpsList;
  for (auto &op : llvm::reverse(block))
    if (auto node = dyn_cast<DataflowNodeOp>(op)) {
      unsigned level = 0;
      for (auto userLevel : llvm::map_range(getNodeUses(node), [&](auto use) {
             return getDataflowLevel(use.second);
           }))
        level = std::max(level, userLevel + 1);

      dataflowLevelMap[node] = level;
      dataflowOpsList[level].push_back(node);
    }

  // Fuse ops of each dataflow level into the same node. After the fusion, we
  // need to update the dataflow uses map.
  dataflowLevelMap.clear();
  for (const auto &p : dataflowOpsList) {
    auto node = fuseOpsIntoNewNode(p.second, *this);
    dataflowLevelMap[node] = p.first;
  }
  updateDataflowUsesMap();

  // Now, we have legalized the dataflow into a feed-forward path and we can
  // handle the bypass uses through inserting dataflow buffers.
  for (auto node : llvm::make_early_inc_range(block.getOps<DataflowNodeOp>())) {
    auto level = getDataflowLevel(node);

    // TODO: For now, we always create a new buffer for each bypass use. To be
    // more efficient, we should reuse buffers as much as possible.
    for (auto use : getNodeUses(node)) {
      auto levelDiff = level - getDataflowLevel(use.second);
      if (levelDiff > 1) {
        setInsertionPointAfter(node);
        auto buffer = create<DataflowBufferOp>(
            getUnknownLoc(), use.first.getType(), use.first, levelDiff - 1);
        use.first.replaceUsesWithIf(buffer.output(), [&](OpOperand &operand) {
          return use.second->isAncestor(operand.getOwner());
        });
      }
    }
  }
  return success();
}

/// Apply dataflow (coarse-grained pipeline) to the block. "gran" determines the
/// minimum granularity of dataflowing while "balance" indicates whether buffers
/// are inserted to balance the dataflow pipeline.
bool scalehls::applyDataflow(Block &block, unsigned gran, bool balance) {
  auto dataflower = ScaleHLSDataflower(block);
  if (failed(dataflower.initializeDataflow()) ||
      failed(dataflower.legalizeDataflow()))
    return false;

  auto parentOp = block.getParentOp();
  if (isa<FuncOp>(parentOp))
    setFuncDirective(parentOp, false, 1, true);
  else if (isa<AffineForOp, scf::ForOp>(parentOp))
    setLoopDirective(parentOp, false, 1, true, false);
  else
    return false;
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
        applyDataflow(func.front(), gran, balance);
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createFuncDataflowPass(std::string dataflowTargetFunc,
                                 unsigned dataflowGran, bool dataflowBalance) {
  return std::make_unique<FuncDataflow>(dataflowTargetFunc, dataflowGran,
                                        dataflowBalance);
}
