//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/Utils.h"
#include "scalehls/Analysis/Utils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct AffineLoopOrderOpt : public AffineLoopOrderOptBase<AffineLoopOrderOpt> {
  void runOnOperation() override {}
};
} // namespace

bool scalehls::applyAffineLoopOrderOpt(AffineLoopBand band,
                                       OpBuilder &builder) {
  auto &loopBlock = band.back().getLoopBody().front();
  auto depth = band.size();

  // Collect all load and store operations for each memory in the loop block,
  // and calculate the number of common surrouding loops for later uses.
  MemAccessesMap map;
  getMemAccessesMap(loopBlock, map);
  auto commonLoopDepth = getNumCommonSurroundingLoops(
      *loopBlock.begin(), *std::next(loopBlock.begin()));

  // Traverse all memories in the loop block.
  for (auto pair : map) {
    auto loadStores = pair.second;

    // Find all dependencies associated to the current memory.
    int64_t dstIndex = 1;
    for (auto dstOp : loadStores) {
      for (auto srcOp : llvm::drop_begin(loadStores, dstIndex)) {
        MemRefAccess dstAccess(dstOp);
        MemRefAccess srcAccess(srcOp);

        FlatAffineConstraints depConstrs;
        SmallVector<DependenceComponent, 2> depComps;

        for (unsigned loopDepth = commonLoopDepth - depth + 1;
             loopDepth <= commonLoopDepth + 1; ++loopDepth) {
          DependenceResult result = checkMemrefAccessDependence(
              srcAccess, dstAccess, loopDepth, &depConstrs, &depComps,
              /*allowRAR=*/false);

          if (hasDependence(result)) {
            // llvm::outs() << "\n----------\n";
            // llvm::outs() << *srcOp << " -> " << *dstOp << "\n";
            // llvm::outs() << "depth: " << loopDepth << ", distance: ";
            // for (auto dep : depComps)
            //   llvm::outs() << "(" << dep.lb.getValue() << ","
            //                << dep.ub.getValue() << "), ";
            // llvm::outs() << "\n";
          }
        }
      }
      dstIndex++;
    }
  }
  return true;
}

std::unique_ptr<Pass> scalehls::createAffineLoopOrderOptPass() {
  return std::make_unique<AffineLoopOrderOpt>();
}
