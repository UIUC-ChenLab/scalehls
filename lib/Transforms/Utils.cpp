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

bool scalehls::applyLoopTilingStrategy(FuncOp targetFunc,
                                       ArrayRef<TileSizes> tileSizesList,
                                       ArrayRef<int64_t> targetIIList,
                                       FrozenRewritePatternList &patterns,
                                       OpBuilder &builder) {
  AffineLoopBands targetBands;
  getLoopBands(targetFunc.front(), targetBands);

  // Apply loop tiling.
  SmallVector<AffineForOp, 4> targetLoops;
  unsigned idx = 0;
  for (auto &band : targetBands)
    if (auto loop =
            applyPartialAffineLoopTiling(band, tileSizesList[idx++], builder))
      targetLoops.push_back(loop);
    else
      return false;
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  // Apply loop pipelining.
  for (auto loop : targetLoops)
    if (!applyLoopPipelining(loop, 1, builder))
      return false;
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  // Apply general optimizations and array partition.
  PassManager passManager(targetFunc.getContext(), "func");
  passManager.addPass(createSimplifyAffineIfPass());
  passManager.addPass(createAffineStoreForwardPass());
  passManager.addPass(createSimplifyMemrefAccessPass());
  passManager.addPass(createCSEPass());
  passManager.addPass(createArrayPartitionPass());

  if (failed(passManager.run(targetFunc)))
    return false;
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  return true;
}
