//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H
#define SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H

#include "scalehls/Analysis/QoREstimation.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// ScaleHLSOptimizer Class Declaration
//===----------------------------------------------------------------------===//

class ScaleHLSOptimizer : public ScaleHLSAnalysisBase {
public:
  explicit ScaleHLSOptimizer(Builder &builder, ScaleHLSEstimator &estimator,
                             unsigned maxDspNum, unsigned maxInitParallel,
                             unsigned maxIterNum, float maxDistance)
      : ScaleHLSAnalysisBase(builder), estimator(estimator),
        maxDspNum(maxDspNum), maxInitParallel(maxInitParallel),
        maxIterNum(maxIterNum), maxDistance(maxDistance) {}

  /// This is a temporary approach that does not scale.
  void applyMultipleLevelDSE(FuncOp func, raw_ostream &os);

  ScaleHLSEstimator &estimator;
  unsigned maxDspNum;

  unsigned maxInitParallel;
  unsigned maxIterNum;
  float maxDistance;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H
