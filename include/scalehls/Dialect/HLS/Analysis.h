//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_ANALYSIS_H
#define SCALEHLS_DIALECT_HLS_ANALYSIS_H

#include "scalehls/Dialect/HLS/HLS.h"

namespace mlir {
namespace scalehls {

using namespace hls;

class ComplexityAnalysis {
public:
  ComplexityAnalysis(func::FuncOp func);

  Optional<unsigned long> getScheduleComplexity(ScheduleOp schedule) const;
  Optional<unsigned long> getNodeComplexity(NodeOp node) const;

private:
  Optional<unsigned long> calculateBlockComplexity(Block *block) const;
  llvm::SmallDenseMap<NodeOp, unsigned long> nodeComplexityMap;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLS_ANALYSIS_H
