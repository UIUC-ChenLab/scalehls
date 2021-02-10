//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_UTILS_H
#define SCALEHLS_TRANSFORMS_UTILS_H

#include "scalehls/Analysis/Utils.h"

namespace mlir {
namespace scalehls {

using TileSizes = SmallVector<unsigned, 8>;

/// Apply loop perfection. Try to sink all operations between loop statements
/// into the innermost loop of the input loop band.
bool applyAffineLoopPerfection(AffineLoopBand &band);

/// Optimize loop order. Loops associated with memory access dependencies are
/// moved to an as outer as possible location of the input loop band. If
/// "reverse" is true, as inner as possible.
bool applyAffineLoopOrderOpt(AffineLoopBand &band, bool reverse = false);

/// Try to rectangularize the input band.
bool applyRemoveVariableBound(AffineLoopBand &band);

/// Apply optimization strategy to a loop band. The ancestor function is also
/// passed in because the post-tiling optimizations have to take function as
/// target, e.g. canonicalizer and array partition.
bool applyOptStrategy(AffineLoopBand &band, FuncOp func, TileSizes tileSizes,
                      int64_t targetII);

/// Apply optimization strategy to a function.
bool applyOptStrategy(FuncOp func, ArrayRef<TileSizes> tileSizesList,
                      ArrayRef<int64_t> targetIIList);

/// Apply loop tiling to the input loop band and return the original innermost
/// loop in the tiled loop band.
AffineForOp applyLoopTiling(AffineLoopBand &band, TileSizes tileSizes);

/// Fully unroll all loops insides of a loop block.
bool applyFullyLoopUnrolling(Block &block);

/// Apply loop pipelining to the input loop, all inner loops are automatically
/// fully unrolled.
bool applyLoopPipelining(AffineForOp loop, int64_t targetII);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_UTILS_H
