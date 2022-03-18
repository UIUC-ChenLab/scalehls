//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLSCpp/HLSCpp.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// A dataflow use includes the intermediate value and the user operation, which
/// is similar to the concept of OpOperand in the SSA graph.
using DataflowUse = std::pair<Value, Operation *>;
using DataflowUses = SmallVector<DataflowUse, 4>;

/// A mapping from an operation to all its dataflow uses.
using DataflowUsesMap = llvm::SmallDenseMap<Operation *, DataflowUses, 64>;

namespace {
struct DataflowGraph {
  DataflowGraph(Block &block);

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
    // // Handle Linalg dialect operations.
    // if (isa<linalg::LinalgDialect>(op.getDialect())) {
    //   auto generic = dyn_cast<linalg::GenericOp>(op);
    //   if (!generic || !generic.hasBufferSemantics()) {
    //     op.emitOpError("found ungeneralized or unbufferized linalg ops");
    //     return;
    //   }
    //   for (auto result : generic.getOutputOperands())
    //     resultsMap[&op].insert(result->get());
    //   continue;
    // }

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
    // TODO: Some operations are dataflow source/sink/call node, which will not
    // be scheduled. Any other operations should appear here?
    if (isa<tosa::ConstOp, arith::ConstantOp, func::CallOp, func::ReturnOp,
            AffineYieldOp, scf::YieldOp>(op) ||
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

/// Legalize the dataflow of "block", whose parent operation must be a function
/// or affine loop. Return false if the legalization failed, for example, the
/// dataflow has cycles.
static bool applyLegalizeDataflow(Block &block, int64_t gran, bool balance) {
  auto builder = OpBuilder(block.getParentOp());
  DataflowGraph graph(block);

  llvm::SmallDenseMap<Operation *, int64_t, 32> map;
  llvm::SmallDenseMap<int64_t, int64_t, 16> dataflowToMerge;

  // Walk through all dataflow operations in a reversed order for establishing
  // a ALAP scheduling.
  for (auto it = block.rbegin(); it != block.rend(); ++it) {
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
      if (balance) {
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
  if (gran != 1 || !balance) {
    // Collect all operations in each dataflow level.
    DenseMap<int64_t, SmallVector<Operation *, 8>> dataflowOps;
    for (auto &op : block.getOperations())
      if (map.count(&op))
        dataflowOps[map.lookup(&op)].push_back(&op);

    unsigned newLevel = 1;
    unsigned toMerge = gran;
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
        toMerge = gran;
        ++newLevel;
      }
    }
  } else {
    for (auto pair : map)
      pair.first->setAttr(
          "dataflow_level",
          builder.getIntegerAttr(builder.getI64Type(), pair.second));
  }
  return true;
}

static bool createSubFunction(Block &block, ArrayRef<Operation *> ops,
                              StringRef name, OpBuilder &builder) {
  Liveness liveness(block.getParentOp());

  // A helper that checks whether a value is a liveout value.
  auto isLiveOut = [&](Value value) {
    return any_of(value.getUsers(), [&](auto user) {
      return all_of(ops, [&](auto op) { return !op->isAncestor(user); });
    });
  };

  // Output types and values of the sub-function.
  SmallVector<Type, 8> outputTypes;
  SmallVector<Value, 8> outputValues;

  // Internal values of the sub-function.
  llvm::SmallDenseSet<Value, 16> internalValues;

  for (auto op : ops) {
    for (auto result : op->getResults()) {
      internalValues.insert(result);
      if (isLiveOut(result)) {
        outputTypes.push_back(result.getType());
        outputValues.push_back(result);
      }
    }
    op->walk([&](AffineForOp loop) {
      internalValues.insert(loop.getInductionVar());
    });
  }

  // Input types and values of the sub-function.
  SmallVector<Type, 8> inputTypes;
  SmallVector<Value, 8> inputValues;

  // Local buffers of the sub-function.
  llvm::SmallDenseSet<Operation *, 8> localOps;

  for (auto op : ops) {
    // Push back all operands and liveins as candidates.
    SmallVector<Value, 8> inputCandidates(op->getOperands());
    for (auto &region : op->getRegions()) {
      auto entryBlock = &region.front();
      auto args = entryBlock->getArguments();

      for (auto liveIn : liveness.getLiveIn(entryBlock))
        if (llvm::find(args, liveIn) == args.end())
          inputCandidates.push_back(liveIn);
    }

    for (auto input : inputCandidates) {
      // If the current input is an internal value, it doesn't needs to be
      // passed in as argument.
      if (internalValues.count(input))
        continue;

      if (auto defOp = input.getDefiningOp()) {
        // If the current input is not a liveout and it's defined by an memref
        // alloc/alloca op, it is a local buffer and can be localized later.
        if (!isLiveOut(input) &&
            isa<memref::AllocOp, memref::AllocaOp>(defOp)) {
          localOps.insert(defOp);
          continue;
        }

        // Since we have localized all tosa constant operations, we can safely
        // insert a constant as a local op here.
        if (isa<tosa::ConstOp>(defOp)) {
          localOps.insert(defOp);
          continue;
        }
      }

      // Only unique inputs will be added.
      if (llvm::find(inputValues, input) != inputValues.end())
        continue;

      inputTypes.push_back(input.getType());
      inputValues.push_back(input);
    }
  }

  // Create a new function for the current dataflow level.
  auto loc = builder.getUnknownLoc();
  builder.setInsertionPoint(block.getParent()->getParentOfType<FuncOp>());
  auto subFunc = builder.create<FuncOp>(
      loc, name, builder.getFunctionType(inputTypes, outputTypes));

  // Create a function call and reconnect all inputs and outputs.
  builder.setInsertionPointAfter(ops.back());
  auto call = builder.create<func::CallOp>(loc, subFunc, inputValues);
  unsigned outputIdx = 0;
  for (auto result : call.getResults())
    outputValues[outputIdx++].replaceAllUsesWith(result);

  // Create new return operation in the new created function.
  auto entry = subFunc.addEntryBlock();
  builder.setInsertionPointToEnd(entry);
  auto returnOp = builder.create<func::ReturnOp>(loc, outputValues);

  // Move local buffers into the new created function.
  for (auto localOp : localOps)
    localOp->moveBefore(&subFunc.front().front());

  // Move same level operations into the new created function.
  for (auto op : ops) {
    op->moveBefore(returnOp);
    op->removeAttr("dataflow_level");
  }

  // Connect operands to the arguments of the new created function.
  for (unsigned i = 0, e = inputValues.size(); i < e; ++i)
    inputValues[i].replaceUsesWithIf(
        entry->getArgument(i),
        [&](OpOperand &use) { return subFunc->isAncestor(use.getOwner()); });

  return true;
}

/// Split each dataflow stage of "block" into a separate sub-function.
static bool applySplitFunction(Block &block) {
  auto builder = OpBuilder(block.getParentOp());
  localizeConstants(block);

  // Split sub-functions.
  DenseMap<int64_t, SmallVector<Operation *, 8>> dataflowOps;
  for (auto &op : block)
    if (auto attr = op.getAttrOfType<IntegerAttr>("dataflow_level"))
      dataflowOps[attr.getInt()].push_back(&op);

  for (auto pair : dataflowOps) {
    auto name = "dataflow" + std::to_string(pair.first);
    if (!createSubFunction(block, pair.second, name, builder))
      return false;
  }
  return true;
}

/// Apply dataflow (coarse-grained pipeline) to the block.
bool scalehls::applyDataflow(Block &block, unsigned gran, bool balance) {
  if (!applyLegalizeDataflow(block, gran, balance))
    return false;
  if (!applySplitFunction(block))
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
  FuncDataflow(unsigned dataflowGran, bool dataflowBalance) {
    gran = dataflowGran;
    balance = dataflowBalance;
  }

  void runOnOperation() override {
    auto module = getOperation();

    // Dataflow each functions in the module.
    for (auto func : llvm::make_early_inc_range(module.getOps<FuncOp>()))
      applyDataflow(func.front(), gran, balance);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createFuncDataflowPass() {
  return std::make_unique<FuncDataflow>();
}
std::unique_ptr<Pass> scalehls::createFuncDataflowPass(unsigned dataflowGran,
                                                       bool dataflowBalance) {
  return std::make_unique<FuncDataflow>(dataflowGran, dataflowBalance);
}
