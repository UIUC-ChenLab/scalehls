//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Utils.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

static void addPassPipeline(PassManager &pm) {
  // To factor out the redundant AffineApply/AffineIf operations.
  pm.addPass(createCanonicalizerPass());
  pm.addPass(createSimplifyAffineIfPass());

  // To simplify the memory accessing. Note that the store forwarding is
  // non-trivial and has a worst case complexity of O(n^2).
  pm.addPass(createAffineStoreForwardPass());
  pm.addPass(createSimplifyMemrefAccessPass());

  // Generic common sub expression elimination.
  pm.addPass(createCSEPass());

  // Apply the best suitable array partition strategy to the function.
  pm.addPass(createArrayPartitionPass());
}

/// Apply optimization strategy to a loop band. The ancestor function is also
/// passed in because the post-tiling opts have to take function as target, e.g.
/// canonicalizer.
bool scalehls::applyOptStrategy(AffineLoopBand &band, FuncOp func,
                                TileSizes tileSizes, int64_t targetII) {
  // Apply loop tiling.
  auto loop = applyLoopTiling(band, tileSizes);
  if (!loop || func->isProperAncestor(loop))
    return false;

  // Apply loop pipelining.
  if (!applyLoopPipelining(loop, targetII))
    return false;

  // Apply general optimizations and array partition.
  PassManager passManager(func.getContext(), "func");
  addPassPipeline(passManager);

  if (failed(passManager.run(func)))
    return false;

  return true;
}

/// Apply optimization strategy to a function.
bool scalehls::applyOptStrategy(FuncOp func, ArrayRef<TileSizes> tileSizesList,
                                ArrayRef<int64_t> targetIIList) {
  AffineLoopBands bands;
  getLoopBands(func.front(), bands);

  // Apply loop tiling and pipelining to all loop bands.
  for (unsigned i = 0, e = bands.size(); i < e; ++i) {
    if (auto loop = applyLoopTiling(bands[i], tileSizesList[i]))
      if (applyLoopPipelining(loop, targetIIList[i]))
        continue;

    // If tiling or pipelining failed, return false.
    return false;
  }

  // Apply general optimizations and array partition.
  PassManager passManager(func.getContext(), "func");
  addPassPipeline(passManager);

  if (failed(passManager.run(func)))
    return false;

  return true;
}
