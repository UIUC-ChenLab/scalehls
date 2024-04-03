//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_UTILS_UTILS_H
#define SCALEHLS_UTILS_UTILS_H

#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinOps.h"

namespace mlir {
namespace scalehls {

RankedTensorType getPackedType(RankedTensorType tensorType,
                               ArrayRef<int64_t> tileSizes);

RankedTensorType getUnpackedType(RankedTensorType tensorType,
                                 ArrayRef<int64_t> tileSizes);

std::tuple<Value, Value, Value> getLoopBoundsAndStep(int64_t tripCount,
                                                     int64_t step, Location loc,
                                                     PatternRewriter &rewriter);

/// Construct a loop with the given trip counts, steps, and an optional tensor
/// as the iteration argument. Return the loop induction variables, the result
/// of the outermost loop, and the iteration argument of the innermost loop.
std::tuple<SmallVector<Value>, Value, Value>
constructLoops(ArrayRef<int64_t> tripCounts, ArrayRef<int64_t> steps,
               Location loc, PatternRewriter &rewriter,
               Value iterArg = nullptr);

SmallVector<scf::ForOp> getSurroundingLoops(Operation *target,
                                            Block *sourceBlock);

std::optional<SmallVector<int64_t>>
getLoopSteps(const SmallVector<scf::ForOp> &loops);

std::optional<SmallVector<int64_t>>
getLoopTripCounts(const SmallVector<scf::ForOp> &loops);

bool crossRegionDominates(Operation *a, Operation *b);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_UTILS_UTILS_H
