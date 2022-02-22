//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_UTILS_H
#define SCALEHLS_TRANSFORMS_UTILS_H

#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "scalehls/Support/Utils.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// HLSCpp transform utils
//===----------------------------------------------------------------------===//

using namespace hlscpp;

/// Set timing attribute.
void setTiming(Operation *op, TimingAttr timing);
void setTiming(Operation *op, int64_t begin, int64_t end, int64_t latency,
               int64_t interval);

/// Set resource attribute.
void setResource(Operation *op, ResourceAttr resource);
void setResource(Operation *op, int64_t lut, int64_t dsp, int64_t bram);

/// Set loop information attribute.
void setLoopInfo(Operation *op, LoopInfoAttr loopInfo);
void setLoopInfo(Operation *op, int64_t flattenTripCount, int64_t iterLatency,
                 int64_t minII);

/// Set loop directives.
void setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective);
void setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                      bool dataflow, bool flatten, bool parallel);

/// Set function directives.
void setFuncDirective(Operation *op, FuncDirectiveAttr FuncDirective);
void setFuncDirective(Operation *op, bool pipeline, int64_t targetInterval,
                      bool dataflow, bool topFunc);

//===----------------------------------------------------------------------===//
// Loop transform utils
//===----------------------------------------------------------------------===//

using TileList = SmallVector<unsigned, 8>;

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
/// the innermost loop with the original loop order. Return the location of the
/// innermost tile-space loop.
Optional<unsigned> applyLoopTiling(AffineLoopBand &band, TileList tileList,
                                   bool simplify = true);

bool applyLegalizeToHLSCpp(FuncOp func, bool topFunc);

/// Apply loop pipelining to the pipelineLoc of the input loop band, all inner
/// loops are automatically fully unrolled.
bool applyLoopPipelining(AffineLoopBand &band, unsigned pipelineLoc,
                         unsigned targetII);

/// Fully unroll all loops insides of a loop block.
bool applyFullyLoopUnrolling(Block &block);

bool applyFullyUnrollAndPartition(Block &block, FuncOp func);

bool applyMemoryAccessOpt(FuncOp func);

bool applyArrayPartition(Value array, ArrayRef<unsigned> factors,
                         ArrayRef<hlscpp::PartitionKind> kinds,
                         bool updateFuncSignature = true);

bool applyAutoArrayPartition(FuncOp func);

/// Apply optimization strategy to a loop band. The ancestor function is
/// also passed in because the post-tiling optimizations have to take
/// function as target, e.g. canonicalizer and array partition.
bool applyOptStrategy(AffineLoopBand &band, FuncOp func, TileList tileList,
                      unsigned targetII);

/// Apply optimization strategy to a function.
bool applyOptStrategy(FuncOp func, ArrayRef<TileList> tileLists,
                      ArrayRef<unsigned> targetIIs);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_UTILS_H
