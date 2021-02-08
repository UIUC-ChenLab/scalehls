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

  passManager.addPass(createCanonicalizerPass());
  passManager.addPass(createSimplifyAffineIfPass());
  passManager.addPass(createAffineStoreForwardPass());
  passManager.addPass(createSimplifyMemrefAccessPass());
  passManager.addPass(createCSEPass());
  passManager.addPass(createArrayPartitionPass());

  if (failed(passManager.run(func)))
    return false;

  return true;
}
