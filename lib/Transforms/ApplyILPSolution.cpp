//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Support/FileUtilities.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Support/Utils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"

#define DEBUG_TYPE "scalehls"

using namespace mlir;
using namespace scalehls;

namespace {
struct ApplyILPSolution : public ApplyILPSolutionBase<ApplyILPSolution> {
  ApplyILPSolution() = default;
  ApplyILPSolution(std::string dseILPSolution) { ILPSolution = dseILPSolution; }

  void runOnOperation() override {
    auto module = getOperation();
    auto builder = OpBuilder(module);

    std::string errorMessage;
    auto solutionFile = mlir::openInputFile(ILPSolution, &errorMessage);
    if (!solutionFile) {
      llvm::errs() << errorMessage << "\n";
      return signalPassFailure();
    }

    // Parse JSON File into memory.
    auto solution = llvm::json::parse(solutionFile->getBuffer());
    if (!solution) {
      llvm::errs() << "failed to parse the ILP strategy json file\n";
      return signalPassFailure();
    }
    auto solutionObj = solution.get().getAsObject();
    if (!solutionObj) {
      llvm::errs() << "support an object in the ILP strategy json file, found "
                      "something else\n";
      return signalPassFailure();
    }
    for (auto func : module.getOps<func::FuncOp>()) {
      if (func->getAttr("shared")) {
        auto funcObj = solutionObj->getObject(func.getSymName());
        auto strategy = *funcObj->getArray("strategy");

        AffineLoopBands bands;
        getLoopBands(func.front(), bands);
        SmallVector<TileList> tileLists;
        SmallVector<unsigned> targetIIs;
        unsigned idx = 0;
        for (unsigned i = 0, e = bands.size(); i < e; ++i) {
          TileList tileList;
          for (unsigned j = 0; j < bands[i].size(); j++) {
            tileList.push_back(strategy[idx++].getAsUINT64().getValueOr(1));
          }
          tileLists.push_back(tileList);
          targetIIs.push_back(strategy[idx++].getAsUINT64().getValueOr(1));
        }
        applyOptStrategy(func, tileLists, targetIIs);
      }
    }

    // Pipeline top function
    auto topFunc = getTopFunc(module);
    AffineLoopBands targetBands;
    getLoopBands(topFunc.front(), targetBands);
    // Apply loop pipelining to corresponding level of each innermost loop.
    for (auto &band : targetBands) {
      auto currentLoop = band.back();
      unsigned loopLevel = 0;
      while (true) {
        auto parentLoop = currentLoop->getParentOfType<AffineForOp>();

        // If meet the outermost loop, pipeline the current loop.
        if (!parentLoop || 0 == loopLevel) {
          applyLoopPipelining(band, band.size() - loopLevel - 1, 1);
          break;
        }

        // Move to the next loop level.
        currentLoop = parentLoop;
        ++loopLevel;
      }
    }

    // Array partition top function
    applyAutoArrayPartition(topFunc);

    // Add copy when there is function output->input type mismatch
    for (auto op : getTopFunc(module).getOps<func::CallOp>()) {
      auto call = dyn_cast<func::CallOp>(*op);
      auto callee =
          SymbolTable::lookupNearestSymbolFrom(call, call.getCalleeAttr());
      auto subFunc = dyn_cast<FuncOp>(callee);

      for (unsigned i = 0; i < call.getOperands().size(); i++) {
        auto argumentType = subFunc.getFunctionType().getInputs()[i];
        auto operandType = call.getOperands()[i].getType();
        if (argumentType != operandType) {
          builder.setInsertionPoint(call);
          auto operand = call.getOperands()[i];
          auto buffer = builder.create<memref::AllocOp>(
              call.getLoc(), argumentType.dyn_cast<MemRefType>());
          builder.create<memref::CopyOp>(call.getLoc(), operand, buffer);
          call.operandsMutable().slice(i, 1).assign(buffer);
          builder.setInsertionPointAfter(call);
          builder.create<memref::CopyOp>(call.getLoc(), buffer, operand);
        }
      }
    }

    // Prevent generated CopyOps to be removed by ConvertCopyToAffineLoops
    // If removed, function argument type mismatch occurs
    auto DT = DominanceInfo(module);
    SmallVector<Operation *, 32> opToErase;
    for (auto op : getTopFunc(module).getOps<memref::AllocOp>()) {
      auto alloc = dyn_cast<memref::AllocOp>(*op);
      auto getCopyUser = [&]() {
        for (auto user : alloc->getUsers())
          if (auto copyUser = dyn_cast<memref::CopyOp>(user))
            return copyUser;
        return memref::CopyOp();
      };

      // If the current alloc is not used by any copy, return failure.
      auto copy = getCopyUser();
      if (!copy)
        continue;

      // If the current alloc dominates another alloc, return failure.
      auto anotherMemref = alloc.memref() == copy.getSource()
                               ? copy.getTarget()
                               : copy.getSource();
      if (auto anotherAlloc = anotherMemref.getDefiningOp())
        if (!isa<memref::AllocOp>(anotherAlloc) ||
            DT.dominates(alloc.getOperation(), anotherAlloc))
          continue;
      if (alloc.getType().getMemorySpaceAsInt() !=
          anotherMemref.getType().cast<MemRefType>().getMemorySpaceAsInt())
        continue;

      // If the source memory is used after the copy op, we cannot eliminate the
      // target memory. This is conservative?
      if (llvm::any_of(copy.getSource().getUsers(), [&](Operation *user) {
            return DT.properlyDominates(copy, user);
          }))
        continue;

      // If the target memory is used before the copy op, we cannot eliminate
      // the target memory. This is conservative?
      if (llvm::any_of(copy.getTarget().getUsers(), [&](Operation *user) {
            return DT.properlyDominates(user, copy);
          }))
        continue;

      bool callExists = false;
      for (auto user : copy.getSource().getUsers()) {
        if (auto callUser = dyn_cast<func::CallOp>(user)) {
          callExists = true;
        }
      }
      if (!callExists) {
        builder.setInsertionPoint(anotherMemref.getDefiningOp());
        auto newAlloc =
            dyn_cast<memref::AllocOp>(builder.insert(alloc.clone()));
        anotherMemref.replaceAllUsesWith(newAlloc.memref());
        alloc.replaceAllUsesWith(newAlloc.memref());
        opToErase.push_back(anotherMemref.getDefiningOp());
        opToErase.push_back(alloc);
        opToErase.push_back(copy);
      }
    }

    // Erase all ops on the list.
    for (auto op : opToErase)
      op->erase();
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createApplyILPSolutionPass(std::string dseILPSolution) {
  return std::make_unique<ApplyILPSolution>(dseILPSolution);
}
