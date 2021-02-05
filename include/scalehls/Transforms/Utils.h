//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_UTILS_H
#define SCALEHLS_TRANSFORMS_UTILS_H

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Analysis/Utils.h"

namespace mlir {
namespace scalehls {

using TileSizes = SmallVector<unsigned, 8>;

bool applyLoopTilingStrategy(FuncOp targetFunc,
                             ArrayRef<TileSizes> tileSizesList,
                             ArrayRef<int64_t> targetIIList,
                             FrozenRewritePatternList &patterns,
                             OpBuilder &builder);

/// Apply loop perfection to all outer loops of the input loop until the outer
/// operation is no longer a loop, or contains more than one child loop.
bool applyAffineLoopPerfection(AffineForOp loop, OpBuilder &builder);

/// Apply remove variable bound to all inner loops of the input loop.
bool applyRemoveVariableBound(AffineForOp loop, OpBuilder &builder);

bool applyAffineLoopOrderOpt(AffineLoopBand &band, bool reverse = false);

/// Apply loop tiling and return the new loop that should be pipelined.
AffineForOp applyPartialAffineLoopTiling(AffineLoopBand &band,
                                         ArrayRef<unsigned> tileSizes,
                                         OpBuilder &builder);

/// Fully unroll all loops insides of a block.
bool applyFullyLoopUnrolling(Block &block);

/// Apply loop pipelining to the input loop, all inner loops are automatically
/// fully unrolled.
bool applyLoopPipelining(AffineForOp loop, int64_t targetII,
                         OpBuilder &builder);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_UTILS_H
