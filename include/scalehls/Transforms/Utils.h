//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_UTILS_H
#define SCALEHLS_TRANSFORMS_UTILS_H

#include "scalehls/Dialect/HLS/Utils.h"

namespace mlir {
namespace scalehls {

using namespace hls;

/// Apply loop perfection. Try to sink all operations between loop statements
/// into the innermost loop of the input loop band.
bool applyAffineLoopPerfection(AffineLoopBand &band);

/// Optimize loop order. Loops associated with memory access dependencies are
/// moved to an as outer as possible location of the input loop band. If
/// "reverse" is true, as inner as possible.
bool applyAffineLoopOrderOpt(AffineLoopBand &band,
                             ArrayRef<unsigned> permMap = {},
                             bool reverse = false);

/// Try to rectangularize the input band.
bool applyRemoveVariableBound(AffineLoopBand &band);

/// Apply loop tiling to the input loop band and sink all intra-tile loops to
/// the innermost loop with the original loop order.
bool applyLoopTiling(AffineLoopBand &band, FactorList tileList,
                     bool loopNormalize = true, bool annotatePointLoop = true);

/// Apply loop pipelining to the pipelineLoc of the input loop band, all inner
/// loops are automatically fully unrolled.
bool applyLoopPipelining(AffineLoopBand &band, unsigned pipelineLoc,
                         unsigned targetII);

/// Apply unroll and jam to the loop band with the given overall unroll factor.
bool applyLoopUnrollJam(AffineLoopBand &band, unsigned unrollFactor);

/// Apply unroll and jam to the loop band with the given unroll factors.
bool applyLoopUnrollJam(AffineLoopBand &band, FactorList unrollFactors);

/// Fully unroll all loops insides of a loop block.
bool applyFullyLoopUnrolling(Block &block, unsigned maxIterNum = 10);

/// Apply the specified array partition factors and kinds.
bool applyArrayPartition(Value array, ArrayRef<unsigned> factors,
                         ArrayRef<hls::PartitionKind> kinds,
                         bool updateFuncSignature = true);

/// Find the suitable array partition factors and kinds for all arrays in the
/// targeted function.
bool applyAutoArrayPartition(func::FuncOp func);

bool applyFuncPreprocess(func::FuncOp func, bool topFunc);

/// Apply memory optimizations.
bool applyMemoryOpts(func::FuncOp func);

/// Apply optimization strategy to a loop band. The ancestor function is also
/// passed in because the post-tiling optimizations have to take function as
/// target, e.g. canonicalizer and array partition.
bool applyOptStrategy(AffineLoopBand &band, func::FuncOp func,
                      FactorList tileList, unsigned targetII);

/// Apply optimization strategy to a function.
bool applyOptStrategy(func::FuncOp func, ArrayRef<FactorList> tileLists,
                      ArrayRef<unsigned> targetIIs);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_UTILS_H
