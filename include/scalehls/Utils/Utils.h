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

SmallVector<scf::ForOp> getSurroundingLoops(Operation *target,
                                            Block *sourceBlock);

std::optional<SmallVector<int64_t>>
getLoopSteps(const SmallVector<scf::ForOp> &loops);

std::optional<SmallVector<int64_t>>
getLoopTripCounts(const SmallVector<scf::ForOp> &loops);

using AffineLoopBand = SmallVector<affine::AffineForOp, 6>;
using AffineLoopBands = std::vector<AffineLoopBand>;
using FactorList = SmallVector<unsigned, 8>;

/// Compose any affine.apply ops feeding into `operands` of the integer set
/// `set` by composing the maps of such affine.apply ops with the integer
/// set constraints.
void composeSetAndOperands(IntegerSet &set, SmallVectorImpl<Value> &operands);

/// Return a pair which indicates whether the if statement is always true or
/// false, respectively. The returned result is one-hot.
std::pair<bool, bool> ifAlwaysTrueOrFalse(affine::AffineIfOp ifOp);

/// Check whether the two given if statements have the same condition.
bool checkSameIfStatement(affine::AffineIfOp lhsOp, affine::AffineIfOp rhsOp);

/// For storing all affine memory access operations (including AffineLoadOp, and
/// AffineStoreOp) indexed by the corresponding memref.
using MemAccessesMap = DenseMap<Value, SmallVector<Operation *, 16>>;

/// Collect all load and store operations in the block and return them in "map".
void getMemAccessesMap(Block &block, MemAccessesMap &map,
                       bool includeVectorTransfer = false);

bool crossRegionDominates(Operation *a, Operation *b);

/// Check if the lhsOp and rhsOp are in the same block. If so, return their
/// ancestors that are located at the same block. Note that in this check,
/// AffineIfOp is transparent.
std::optional<std::pair<Operation *, Operation *>>
checkSameLevel(Operation *lhsOp, Operation *rhsOp);

unsigned getCommonSurroundingLoops(Operation *A, Operation *B,
                                   AffineLoopBand *band);

/// Calculate the upper and lower bound of the affine map if possible.
std::optional<std::pair<int64_t, int64_t>>
getBoundOfAffineMap(AffineMap map, ValueRange operands);

/// This is method for finding the number of child loops which immediatedly
/// contained by the input operation.
unsigned getChildLoopNum(Operation *op);

/// Get the whole loop band given the outermost or innermost loop and return it
/// in "band". Meanwhile, the return value is the innermost or outermost loop of
/// this loop band.
affine::AffineForOp getLoopBandFromOutermost(affine::AffineForOp forOp,
                                             AffineLoopBand &band);
affine::AffineForOp getLoopBandFromInnermost(affine::AffineForOp forOp,
                                             AffineLoopBand &band);

/// Collect all loop bands in the "block" and return them in "bands". If
/// "allowHavingChilds" is true, loop bands containing more than 1 other loop
/// bands are also collected. Otherwise, only loop bands that contains no child
/// loops are collected.
void getLoopBands(Block &block, AffineLoopBands &bands,
                  bool allowHavingChilds = false);

void getArrays(Block &block, SmallVectorImpl<Value> &arrays,
               bool allowArguments = true);

bool checkDependence(Operation *A, Operation *B);

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_UTILS_UTILS_H
