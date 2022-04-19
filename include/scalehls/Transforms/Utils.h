//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_UTILS_H
#define SCALEHLS_TRANSFORMS_UTILS_H

#include "scalehls/Support/Utils.h"

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
using TileList = SmallVector<unsigned, 8>;
bool applyLoopTiling(AffineLoopBand &band, TileList tileList,
                     bool loopNormalize = true, bool annotatePointLoop = true);

/// Apply loop pipelining to the pipelineLoc of the input loop band, all inner
/// loops are automatically fully unrolled.
bool applyLoopPipelining(AffineLoopBand &band, unsigned pipelineLoc,
                         unsigned targetII);

/// Fully unroll all loops insides of a loop block.
bool applyFullyLoopUnrolling(Block &block, unsigned maxIterNum = 10);

/// Apply dataflow (coarse-grained pipeline) to the block. "gran" determines the
/// minimum granularity of dataflowing while "balance" indicates whether buffers
/// are inserted to balance the dataflow pipeline.
bool applyDataflow(Block &block, unsigned gran, bool balance);

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
                      TileList tileList, unsigned targetII);

/// Apply optimization strategy to a function.
bool applyOptStrategy(func::FuncOp func, ArrayRef<TileList> tileLists,
                      ArrayRef<unsigned> targetIIs);

/// Apply tensor operation optimization.
bool applyShareTensorOperation(ModuleOp module, unsigned numTargets);

/// Fuse the given operations into a new dataflow node. The fused node will be
/// created before the first operation and each operation will be inserted in
/// order. This method always succeeds.
DataflowNodeOp fuseOpsIntoNewNode(ArrayRef<Operation *> ops,
                                  PatternRewriter &rewriter);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_UTILS_H
