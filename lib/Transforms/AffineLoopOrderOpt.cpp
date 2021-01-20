//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/Utils.h"
#include "mlir/Transforms/LoopUtils.h"
#include "scalehls/Analysis/Utils.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct AffineLoopOrderOpt : public AffineLoopOrderOptBase<AffineLoopOrderOpt> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    // Collect all target loop bands.
    AffineLoopBands targetBands;
    func.walk([&](AffineForOp loop) {
      if (getChildLoopNum(loop) == 0) {
        AffineLoopBand band;
        getLoopBandFromLeaf(loop, band);
        targetBands.push_back(band);
      }
    });

    // Apply loop order optimization to each loop band.
    for (auto band : targetBands)
      applyAffineLoopOrderOpt(band, builder);
  }
};
} // namespace

bool scalehls::applyAffineLoopOrderOpt(AffineLoopBand band,
                                       OpBuilder &builder) {
  auto &loopBlock = band.back().getLoopBody().front();
  auto bandDepth = band.size();

  // Collect all load and store operations for each memory in the loop block,
  // and calculate the number of common surrouding loops for later uses.
  MemAccessesMap loadStoresMap;
  getMemAccessesMap(loopBlock, loadStoresMap);
  auto commonLoopDepth = getNumCommonSurroundingLoops(
      *loopBlock.begin(), *std::next(loopBlock.begin()));

  // A map of dependency distances indexed by the loop in the band.
  llvm::SmallDenseMap<Operation *, unsigned, 4> distanceMap;

  // Traverse all memories in the loop block.
  for (auto pair : loadStoresMap) {
    auto loadStores = pair.second;

    // Find all dependencies associated to the current memory.
    int64_t dstIndex = 1;
    for (auto dstOp : loadStores) {
      for (auto srcOp : llvm::drop_begin(loadStores, dstIndex)) {
        MemRefAccess dstAccess(dstOp);
        MemRefAccess srcAccess(srcOp);

        FlatAffineConstraints depConstrs;
        SmallVector<DependenceComponent, 2> depComps;

        // Only the loops in the loop band will be checked.
        for (unsigned depth = commonLoopDepth - bandDepth + 1;
             depth <= commonLoopDepth + 1; ++depth) {

          DependenceResult result = checkMemrefAccessDependence(
              srcAccess, dstAccess, depth, &depConstrs, &depComps,
              /*allowRAR=*/false);

          if (hasDependence(result)) {
            auto depComp = depComps[depth - 1];

            auto targetLoop = depComp.op;
            unsigned minPosDistance =
                std::max(depComp.lb.getValue(), (int64_t)1);

            // Only positive distance will be considered, keep the minimum
            // distance in the distance map.
            if (depComp.ub.getValue() > 0) {
              if (distanceMap.count(targetLoop)) {
                auto currentDistance = distanceMap[targetLoop];
                distanceMap[targetLoop] =
                    std::min(currentDistance, minPosDistance);
              } else
                distanceMap[targetLoop] = minPosDistance;
            }
          }
        }
      }
      dstIndex++;
    }
  }

  // Permute the target loops one by one.
  for (unsigned i = 0, e = distanceMap.size(); i < e; ++i) {
    // Find the loop with the smallest dependency distance. The rationale is
    // small dependency distance tends to increase the achievable II when
    // applying loop pipelining.
    Operation *targetLoop = nullptr;
    unsigned count = 0;
    for (auto pair : distanceMap) {
      if (count == 0)
        targetLoop = pair.first;
      else if (pair.second < distanceMap[targetLoop])
        targetLoop = pair.first;
      count++;
    }

    // Remove the target loop from the distance map as it will be handled in
    // this iteration.
    distanceMap.erase(targetLoop);

    // Find the current location of the target loop in the loop band.
    unsigned targetLoopLoc =
        std::find(band.begin(), band.end(), targetLoop) - band.begin();

    // Permute the target loop to an as outer as possible position.
    for (unsigned dstLoc = 0; dstLoc < targetLoopLoc; ++dstLoc) {
      SmallVector<unsigned, 4> permMap;

      // Construct permutation map.
      for (unsigned loc = 0; loc < bandDepth; ++loc) {
        if (loc < dstLoc)
          permMap.push_back(loc);
        else if (loc < targetLoopLoc)
          permMap.push_back(loc + 1);
        else if (loc == targetLoopLoc)
          permMap.push_back(dstLoc);
        else
          permMap.push_back(loc);
      }

      // Check the validation of the current permutation.
      if (isValidLoopInterchangePermutation(band, permMap)) {
        permuteLoops(band, permMap);
        break;
      }
    }
  }
  return true;
}

std::unique_ptr<Pass> scalehls::createAffineLoopOrderOptPass() {
  return std::make_unique<AffineLoopOrderOpt>();
}
