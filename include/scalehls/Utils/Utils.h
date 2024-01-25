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

//===----------------------------------------------------------------------===//
// Linalg Analysis Utils
//===----------------------------------------------------------------------===//

Value getUntiledProducer(Value source);

SmallVector<scf::ForOp> getSurroundingLoops(Value source);

/// Check whether the given generic operation is elementwise.
bool isElementwiseGenericOp(linalg::GenericOp op);

//===----------------------------------------------------------------------===//
// Memory and Loop Analysis Utils
//===----------------------------------------------------------------------===//

using AffineLoopBand = SmallVector<affine::AffineForOp, 6>;
using AffineLoopBands = std::vector<AffineLoopBand>;
using FactorList = SmallVector<unsigned, 8>;

/// Reduces each tile size to the largest divisor of the corresponding trip
/// count (if the trip count is known).
void adjustToDivisorsOfTripCounts(ArrayRef<affine::AffineForOp> band,
                                  SmallVectorImpl<unsigned> *tileSizes);

/// The current op or contained ops have effect on external buffers.
bool hasEffectOnExternalBuffer(Operation *op);

/// Distribute the given factor from the innermost loop of the given loop band,
/// so that we can apply vectorize, unroll and jam, etc.
FactorList
getDistributedFactors(unsigned factor,
                      const SmallVectorImpl<affine::AffineForOp> &band);

/// Distribute the given factor evenly on all loop levels. The generated factors
/// are garanteed to be divisors of the factors in given "costrFactorsList".
/// This method can fail due to non-constant loop bounds.
LogicalResult
getEvenlyDistributedFactors(unsigned maxFactor, FactorList &factors,
                            const SmallVectorImpl<affine::AffineForOp> &band,
                            const SmallVectorImpl<FactorList> &constrFactors,
                            bool powerOf2Constr = false);

/// Compose any affine.apply ops feeding into `operands` of the integer set
/// `set` by composing the maps of such affine.apply ops with the integer
/// set constraints.
void composeSetAndOperands(IntegerSet &set, SmallVectorImpl<Value> &operands);

/// Return a pair which indicates whether the if statement is always true or
/// false, respectively. The returned result is one-hot.
std::pair<bool, bool> ifAlwaysTrueOrFalse(affine::AffineIfOp ifOp);

/// Check whether the two given if statements have the same condition.
bool checkSameIfStatement(affine::AffineIfOp lhsOp, affine::AffineIfOp rhsOp);

/// Parse array attributes.
SmallVector<int64_t, 8> getIntArrayAttrValue(Operation *op, StringRef name);

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

/// Calculate partition factors through analyzing the "memrefType" and return
/// them in "factors". Meanwhile, the overall partition number is calculated and
/// returned as well.
int64_t getPartitionFactors(MemRefType memrefType,
                            SmallVectorImpl<int64_t> *factors = nullptr);

bool isFullyPartitioned(MemRefType memrefType);

/// This is method for finding the number of child loops which immediatedly
/// contained by the input operation.
unsigned getChildLoopNum(Operation *op);

/// Given a tiled loop band, return true and get the tile (tile-space) loop
/// band and the point (intra-tile) loop band. If failed, return false.
bool getTileAndPointLoopBand(const AffineLoopBand &band,
                             AffineLoopBand &tileBand,
                             AffineLoopBand &pointBand);

bool getParallelAndReductionLoopBand(const AffineLoopBand &band,
                                     AffineLoopBand &parallelBand,
                                     AffineLoopBand &reductionBand);

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

std::optional<unsigned> getAverageTripCount(affine::AffineForOp forOp);

bool checkDependence(Operation *A, Operation *B);

func::FuncOp getTopFunc(ModuleOp module, std::string topFuncName = "");

func::FuncOp getRuntimeFunc(ModuleOp module, std::string runtimeFuncName = "");

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_UTILS_UTILS_H
