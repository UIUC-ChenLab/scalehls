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
/// passed in because the post-tiling optimizations have to take function as
/// target, e.g. canonicalizer and array partition.
bool scalehls::applyOptStrategy(AffineLoopBand &band, FuncOp func,
                                TileList tileList, unsigned targetII) {
  // By design the input function must be the ancestor of the input loop band.
  if (!func->isProperAncestor(band.front()))
    return false;

  // Apply loop tiling.
  auto pipelineLoc = applyLoopTiling(band, tileList);
  if (!pipelineLoc)
    return false;

  // Apply loop pipelining.
  if (!applyLoopPipelining(band, pipelineLoc.getValue(), targetII))
    return false;

  // Apply general optimizations and array partition.
  PassManager passManager(func.getContext(), "func");
  addPassPipeline(passManager);

  if (failed(passManager.run(func)))
    return false;

  return true;
}

/// Apply optimization strategy to a function.
bool scalehls::applyOptStrategy(FuncOp func, ArrayRef<TileList> tileLists,
                                ArrayRef<unsigned> targetIIs) {
  AffineLoopBands bands;
  getLoopBands(func.front(), bands);

  // Apply loop tiling and pipelining to all loop bands.
  for (unsigned i = 0, e = bands.size(); i < e; ++i) {
    auto pipelineLoc = applyLoopTiling(bands[i], tileLists[i]);
    if (!pipelineLoc)
      return false;

    if (!applyLoopPipelining(bands[i], pipelineLoc.getValue(), targetIIs[i]))
      return false;
  }

  // Apply general optimizations and array partition.
  PassManager passManager(func.getContext(), "func");
  addPassPipeline(passManager);

  if (failed(passManager.run(func)))
    return false;

  return true;
}
