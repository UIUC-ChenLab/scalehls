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
    auto dse = solutionObj->getBoolean("dse").getValueOr(true);

    for (auto func : module.getOps<func::FuncOp>()) {
      if (func->getAttr("shared")) {
        SmallVector<TileList> tileLists;
        SmallVector<unsigned> targetIIs;

        if (dse) {
          auto funcObj = solutionObj->getObject(func.getSymName());
          auto strategy = *funcObj->getArray("strategy");

          AffineLoopBands bands;
          getLoopBands(func.front(), bands);
          unsigned idx = 0;
          for (unsigned i = 0, e = bands.size(); i < e; ++i) {
            TileList tileList;
            for (unsigned j = 0; j < bands[i].size(); j++) {
              tileList.push_back(strategy[idx++].getAsUINT64().getValueOr(1));
            }
            tileLists.push_back(tileList);
            targetIIs.push_back(strategy[idx++].getAsUINT64().getValueOr(1));
          }
        } else {
          // Apply base optimizations for loops
          AffineLoopBands bands;
          getLoopBands(func.front(), bands);
          for (auto band : bands) {
            applyAffineLoopPerfection(band);
            applyAffineLoopOrderOpt(band);
            applyRemoveVariableBound(band);
          }

          getLoopBands(func.front(), bands);
          // Follow the tiling strategy set by ReplaceTensorOperation
          for (unsigned i = 0, e = bands.size(); i < e; ++i) {
            TileList tileList;
            for (unsigned j = 0; j < bands[i].size(); j++) {
              if (bands[i][j]->hasAttr("unroll"))
                tileList.push_back(bands[i][j]
                                       ->getAttr("unroll")
                                       .dyn_cast<IntegerAttr>()
                                       .getInt());
              else
                tileList.push_back(1);
            }
            tileLists.push_back(tileList);
            targetIIs.push_back(1);
          }
        }
        applyOptStrategy(func, tileLists, targetIIs);
      }
    }

    // Array partition to runtime main
    applyAutoArrayPartition(getRuntimeFunc(module));
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createApplyILPSolutionPass(std::string dseILPSolution) {
  return std::make_unique<ApplyILPSolution>(dseILPSolution);
}
