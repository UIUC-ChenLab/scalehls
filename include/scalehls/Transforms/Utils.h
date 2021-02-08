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

bool applyOptStrategy(FuncOp targetFunc, ArrayRef<TileSizes> tileSizesList,
                      ArrayRef<int64_t> targetIIList);

/// Apply loop perfection to all outer loops of the input loop until the outer
/// operation is no longer a loop, or contains more than one child loop.
bool applyAffineLoopPerfection(AffineForOp loop);

bool applyAffineLoopOrderOpt(AffineLoopBand &band, bool reverse = false);

/// Apply remove variable bound to all inner loops of the input loop.
bool applyRemoveVariableBound(AffineForOp loop);

/// Apply loop tiling and return the new loop that should be pipelined.
AffineForOp applyLoopTiling(AffineLoopBand &band, TileSizes tileSizes);

/// Fully unroll all loops insides of a block.
bool applyFullyLoopUnrolling(Block &block);

/// Apply loop pipelining to the input loop, all inner loops are automatically
/// fully unrolled.
bool applyLoopPipelining(AffineForOp loop, int64_t targetII);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_UTILS_H
