//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H
#define SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Analysis/QoREstimation.h"
#include "scalehls/Transforms/Utils.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// ScaleHLSOptimizer Class Declaration
//===----------------------------------------------------------------------===//

class ScaleHLSOptimizer : public ScaleHLSAnalysisBase {
public:
  explicit ScaleHLSOptimizer(Builder &builder, ScaleHLSEstimator &estimator,
                             int64_t numDSP)
      : ScaleHLSAnalysisBase(builder), estimator(estimator), numDSP(numDSP) {
    // TODO: only insert affine-related patterns.
    OwningRewritePatternList owningPatterns;
    for (auto *op : builder.getContext()->getRegisteredOperations())
      op->getCanonicalizationPatterns(owningPatterns, builder.getContext());
    patterns = std::move(owningPatterns);
  }

  enum LoopState { HOT = 0, COLD = 1, FROZEN = 2 };
  using BandState = SmallVector<LoopState, 8>;

  bool loopBandIsFrozen(BandState bandState) {
    for (auto loopState : bandState)
      if (loopState != LoopState::FROZEN)
        return false;
    return true;
  }

  bool loopBandIsColdOrFrozen(BandState bandState) {
    for (auto loopState : bandState)
      if (loopState == LoopState::HOT)
        return false;
    return true;
  }

  bool loopBandIsOneHot(BandState bandState) {
    unsigned hotNum = 0;
    for (auto loopState : bandState)
      if (loopState == LoopState::HOT)
        hotNum++;

    if (hotNum == 1)
      return true;
    else
      return false;
  }

  void emitDebugInfo(FuncOp targetFunc, StringRef message);
  void emitTilingInfo(FuncOp targetFunc, ArrayRef<TileSizes> tileSizesList);

  bool incrTileSizeAtLoc(TileSizes &tileSizes, TileSizes &tripCounts,
                         unsigned &loc);

  /// This is a temporary approach that does not scale.
  void applyMultipleLevelDSE(FuncOp func);

  ScaleHLSEstimator &estimator;
  int64_t numDSP;
  FrozenRewritePatternList patterns;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H