//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

// For storing the intermediate memory and successor loops indexed by the
// predecessor loop.
using Successors = SmallVector<std::pair<Value, Operation *>, 2>;
using SuccessorsMap = DenseMap<Operation *, Successors>;

static void getSuccessorsMap(Block &block, SuccessorsMap &map) {
  DenseMap<Operation *, SmallPtrSet<Value, 2>> memsMap;
  DenseMap<Value, SmallPtrSet<Operation *, 2>> loopsMap;

  // TODO: for now we only consider store/load operations.
  for (auto loop : block.getOps<AffineForOp>())
    loop.walk([&](Operation *op) {
      if (auto affineStore = dyn_cast<AffineStoreOp>(op))
        memsMap[loop].insert(affineStore.getMemRef());

      else if (auto store = dyn_cast<memref::StoreOp>(op))
        memsMap[loop].insert(store.getMemRef());

      else if (auto affineLoad = dyn_cast<AffineLoadOp>(op))
        loopsMap[affineLoad.getMemRef()].insert(loop);

      else if (auto load = dyn_cast<memref::LoadOp>(op))
        loopsMap[load.getMemRef()].insert(loop);
    });

  // Find successors of all operations. Since this is a dataflow analysis, this
  // traverse will not enter any control flow operations.
  for (auto &op : block.getOperations()) {
    // TODO: Some operations are dataflow source, which will not be scheduled.
    if (isa<memref::AllocOp, memref::AllocaOp, arith::ConstantOp,
            bufferization::ToTensorOp, bufferization::ToMemrefOp>(op))
      continue;

    // Collect all memref results if the current operation is a loop.
    auto mems = memsMap.lookup(&op);
    SmallVector<Value, 2> results(mems.begin(), mems.end());

    // Collect all returned shaped type results.
    for (auto result : op.getResults())
      if (result.getType().isa<ShapedType>())
        results.push_back(result);

    // Traverse all produced results.
    for (auto result : results) {
      for (auto user : loopsMap.lookup(result)) {
        // If the successor loop not only loads from the memory, but also store
        // to the memory, it is not considered as a successor.
        if (user == &op || memsMap.lookup(user).count(result))
          continue;
        map[&op].push_back(std::pair<Value, Operation *>(result, user));
      }

      for (auto user : result.getUsers()) {
        // User must be an operation in the block.
        if (user != block.findAncestorOpInBlock(*user))
          continue;
        map[&op].push_back(std::pair<Value, Operation *>(result, user));
      }
    }
  }
}

static bool applyLegalizeDataflow(FuncOp func, int64_t minGran,
                                  bool insertCopy) {
  auto builder = OpBuilder(func);

  SuccessorsMap successorsMap;
  getSuccessorsMap(func.front(), successorsMap);

  llvm::SmallDenseMap<int64_t, int64_t, 16> dataflowToMerge;

  // Walk through all dataflow operations in a reversed order for establishing a
  // ALAP scheduling.
  for (auto i = func.front().rbegin(); i != func.front().rend(); ++i) {
    auto op = &*i;
    // TODO: Here, we assume all dataflow operations should have successor.
    if (successorsMap.count(op)) {
      int64_t dataflowLevel = 0;

      // Walk through all successor ops.
      for (auto pair : successorsMap[op]) {
        auto successor = pair.second;
        if (isa<ReturnOp>(successor))
          continue;

        if (auto attr = successor->getAttrOfType<IntegerAttr>("dataflow_level"))
          dataflowLevel = std::max(dataflowLevel, attr.getInt());
        else {
          op->emitError("has unexpected successor, legalization failed");
          return false;
        }
      }

      // Set an attribute for indicating the scheduled dataflow level.
      op->setAttr("dataflow_level", builder.getIntegerAttr(builder.getI64Type(),
                                                           dataflowLevel + 1));

      // Eliminate bypass paths if detected.
      for (auto pair : successorsMap[op]) {
        auto value = pair.first;
        auto successor = pair.second;
        if (isa<ReturnOp>(successor))
          continue;

        auto successorDataflowLevel =
            successor->getAttrOfType<IntegerAttr>("dataflow_level").getInt();

        // Bypass path does not exist.
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
            // Create CopyOp.
            Value newValue;
            Operation *copyOp;
            auto valueType = value.getType().dyn_cast<MemRefType>();
            assert(valueType && "only support memref type now, will introduce "
                                "TOSA dialect for tackling tensor operators");
            newValue = builder.create<memref::AllocOp>(op->getLoc(), valueType);
            copyOp = builder.create<linalg::CopyOp>(op->getLoc(), values.back(),
                                                    newValue);

            // Set CopyOp dataflow level.
            copyOp->setAttr("dataflow_level",
                            builder.getIntegerAttr(builder.getI64Type(), i));

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
          if (auto dst = dataflowToMerge.lookup(successorDataflowLevel))
            dataflowToMerge[successorDataflowLevel] =
                std::max(dst, dataflowLevel);
          else
            dataflowToMerge[successorDataflowLevel] = dataflowLevel;
        }
      }
    }
  }

  // Collect all operations in each dataflow level.
  DenseMap<int64_t, SmallVector<Operation *, 8>> dataflowOps;
  for (auto &op : func.front().getOperations())
    if (auto attr = op.getAttrOfType<IntegerAttr>("dataflow_level"))
      dataflowOps[attr.getInt()].push_back(&op);

  // Merge dataflow levels according to the bypasses and minimum granularity.
  if (minGran != 1 || !insertCopy) {
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
