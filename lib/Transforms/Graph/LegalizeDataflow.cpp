//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

// A dataflow use includes the intermediate value and the user operation, which
// is similar to the concept of OpOperand in the SSA graph.
using DataflowUse = std::pair<Value, Operation *>;
using DataflowUses = SmallVector<DataflowUse, 4>;

// A mapping from an operation to all its dataflow uses.
using DataflowUsesMap = llvm::SmallDenseMap<Operation *, DataflowUses, 64>;

namespace {
struct DataflowGraph {
  DataflowGraph(FuncOp func);

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

DataflowGraph::DataflowGraph(FuncOp func) {
  // Results map of each operation.
  DenseMap<Operation *, llvm::SmallDenseSet<Value, 2>> resultsMap;

  for (auto &op : func.front()) {
    // Handle Linalg dialect operations.
    if (isa<linalg::LinalgDialect>(op.getDialect())) {
      auto generic = dyn_cast<linalg::GenericOp>(op);
      if (!generic || !generic.hasBufferSemantics()) {
        op.emitOpError("found ungeneralized or unbufferized linalg ops");
        return;
      }
      for (auto result : generic.getOutputOperands())
        resultsMap[&op].insert(result->get());
      continue;
    }

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
  DominanceInfo DT(func);

  // Find successors of all operations.
  for (auto &op : func.front()) {
    // TODO: Some operations are dataflow source/sink/call node, which will not
    // be scheduled. Any other operations should appear here?
    if (isa<memref::GetGlobalOp, memref::AllocOp, memref::AllocaOp,
            bufferization::ToMemrefOp, tosa::ConstOp, arith::ConstantOp,
            linalg::InitTensorOp, CallOp, ReturnOp>(op))
      continue;
    nodes.insert(&op);

    for (auto result : resultsMap.lookup(&op)) {
      for (auto user : result.getUsers()) {
        // If the same block user doesn't exist, or is not properly dominated,
        // or is also an updater of the result, continue.
        auto sameBlockUser = func.front().findAncestorOpInBlock(*user);
        if (!sameBlockUser || isa<ReturnOp>(sameBlockUser) ||
            !DT.properlyDominates(&op, sameBlockUser))
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

static bool applyLegalizeDataflow(FuncOp func, int64_t minGran,
                                  bool insertCopy) {
  auto builder = OpBuilder(func);
  DataflowGraph graph(func);

  llvm::SmallDenseMap<Operation *, int64_t, 32> map;
  llvm::SmallDenseMap<int64_t, int64_t, 16> dataflowToMerge;

  // Walk through all dataflow operations in a reversed order for establishing
  // a ALAP scheduling.
  for (auto it = func.front().rbegin(); it != func.front().rend(); ++it) {
    auto op = &*it;
    if (!graph.hasNode(op))
      continue;

    // Walk through all uses and schedule the dataflow level.
    int64_t dataflowLevel = 0;
    for (auto use : graph.getNodeUses(op)) {
      if (!map.count(use.second))
        return op->emitOpError("has unexpected use, legalize failed"), false;
      dataflowLevel = std::max(dataflowLevel, map.lookup(use.second));
    }
    map[op] = dataflowLevel + 1;

    // Eliminate bypass paths if detected.
    for (auto use : graph.getNodeUses(op)) {
      auto value = use.first;
      auto successor = use.second;

      // Continue if bypass path does not exist.
      auto successorDataflowLevel = map.lookup(successor);
      if (dataflowLevel == successorDataflowLevel)
        continue;

      // If insert-copy is set, insert CopyOp to the bypass path. Otherwise,
      // record all the bypass paths in dataflowToMerge.
      if (insertCopy) {
        // Insert CopyOps if required.
        SmallVector<Value, 4> values;
        values.push_back(value);

        builder.setInsertionPoint(successor);
        for (auto i = dataflowLevel; i > successorDataflowLevel; --i) {
          // Create and set the dataflow level of CopyOp.
          Value newValue;
          Operation *copyOp;
          if (auto type = value.getType().dyn_cast<MemRefType>()) {
            newValue = builder.create<memref::AllocOp>(op->getLoc(), type);
            copyOp = builder.create<memref::CopyOp>(op->getLoc(), values.back(),
                                                    newValue);
          } else {
            copyOp = builder.create<hlscpp::AssignOp>(
                op->getLoc(), value.getType(), values.back());
            newValue = copyOp->getResult(0);
          }
          map[copyOp] = i;

          // Chain created CopyOps.
          if (i == successorDataflowLevel + 1)
            value.replaceUsesWithIf(newValue, [&](OpOperand &use) {
              return successor->isAncestor(use.getOwner());
            });
          else
            values.push_back(newValue);
        }
      } else {
        // Always retain the longest merge path.
        auto dst = dataflowToMerge.lookup(successorDataflowLevel);
        dataflowToMerge[successorDataflowLevel] = std::max(dst, dataflowLevel);
      }
    }
  }

  // Merge dataflow levels according to the bypasses and minimum granularity.
  if (minGran != 1 || !insertCopy) {
    // Collect all operations in each dataflow level.
    DenseMap<int64_t, SmallVector<Operation *, 8>> dataflowOps;
    for (auto &op : func.front().getOperations())
      if (map.count(&op))
        dataflowOps[map.lookup(&op)].push_back(&op);

    unsigned newLevel = 1;
    unsigned toMerge = minGran;
    for (unsigned i = 1, e = dataflowOps.size(); i <= e; ++i) {
      // If the current level is the start point of a bypass, refresh toMerge.
      // Otherwise, decrease toMerge by 1.
      if (auto dst = dataflowToMerge.lookup(i))
        toMerge = dst - i;
      else
        toMerge--;

      // Annotate all ops in the current level to the new level.
      for (auto op : dataflowOps[i])
        op->setAttr("dataflow_level",
                    builder.getIntegerAttr(builder.getI64Type(), newLevel));

      // Update toMerge and newLevel if required.
      if (toMerge == 0) {
        toMerge = minGran;
        ++newLevel;
      }
    }
  } else {
    for (auto pair : map)
      pair.first->setAttr(
          "dataflow_level",
          builder.getIntegerAttr(builder.getI64Type(), pair.second));
  }

  // Set dataflow attribute.
  auto topFunc = false;
  if (auto funcDirect = getFuncDirective(func))
    topFunc = funcDirect.getTopFunc();

  setFuncDirective(func, false, 1, true, topFunc);
  return true;
}

namespace {
struct LegalizeDataflow : public LegalizeDataflowBase<LegalizeDataflow> {
  LegalizeDataflow() = default;
  LegalizeDataflow(unsigned dataflowGran) { minGran = dataflowGran; }

  void runOnOperation() override {
    applyLegalizeDataflow(getOperation(), minGran, insertCopy);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
std::unique_ptr<Pass>
scalehls::createLegalizeDataflowPass(unsigned dataflowGran) {
  return std::make_unique<LegalizeDataflow>(dataflowGran);
}
