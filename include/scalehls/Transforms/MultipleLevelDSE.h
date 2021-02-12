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
                             int64_t numDSP)
      : ScaleHLSAnalysisBase(builder), estimator(estimator), numDSP(numDSP) {}

  /// This is a temporary approach that does not scale.
  void applyMultipleLevelDSE(FuncOp func, raw_ostream &os,
                             unsigned maxInitializeParallel = 16);

  ScaleHLSEstimator &estimator;
  int64_t numDSP;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_MULTIPLELEVELDSE_H