//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Utils/Utils.h"
#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/IntegerSet.h"

using namespace mlir;
using namespace scalehls;
using namespace affine;

RankedTensorType scalehls::getPackedType(RankedTensorType tensorType,
                                         ArrayRef<int64_t> tileSizes) {
  auto packedShape =
      llvm::map_to_vector(llvm::zip(tensorType.getShape(), tileSizes),
                          [&](std::tuple<int64_t, int64_t> shape) {
                            return std::get<0>(shape) / std::get<1>(shape);
                          });
  packedShape.append(tileSizes.begin(), tileSizes.end());
  return RankedTensorType::get(packedShape, tensorType.getElementType());
}

RankedTensorType scalehls::getUnpackedType(RankedTensorType tensorType,
                                           ArrayRef<int64_t> tileSizes) {
  auto unpackedRank = tensorType.getRank() / 2;
  auto unpackedShape = llvm::map_to_vector(
      llvm::zip(tensorType.getShape().take_front(unpackedRank),
                tileSizes.take_back(unpackedRank)),
      [&](std::tuple<int64_t, int64_t> shape) {
        return std::get<0>(shape) * std::get<1>(shape);
      });
  return RankedTensorType::get(unpackedShape, tensorType.getElementType());
}

std::tuple<Value, Value, Value>
scalehls::getLoopBoundsAndStep(int64_t tripCount, int64_t step, Location loc,
                               PatternRewriter &rewriter) {
  auto lbCst = rewriter.create<arith::ConstantIndexOp>(loc, 0);
  auto ubCst = rewriter.create<arith::ConstantIndexOp>(loc, tripCount * step);
  auto stepCst = rewriter.create<arith::ConstantIndexOp>(loc, step);
  return std::make_tuple(lbCst, ubCst, stepCst);
}

/// Construct a loop with the given trip counts, steps, and an optional tensor
/// as the iteration argument. Return the loop induction variables, the result
/// of the outermost loop, and the iteration argument of the innermost loop.
std::tuple<SmallVector<Value>, Value, Value>
scalehls::constructLoops(ArrayRef<int64_t> tripCounts, ArrayRef<int64_t> steps,
                         Location loc, PatternRewriter &rewriter,
                         Value iterArg) {
  SmallVector<Value> ivs;
  Value result = iterArg;
  for (auto [tripCount, step] : llvm::zip(tripCounts, steps)) {
    // Construct loops with the given trip counts and steps.
    auto [lbCst, ubCst, stepCst] =
        getLoopBoundsAndStep(tripCount, step, loc, rewriter);
    auto iterArgs = iterArg ? ValueRange(iterArg) : std::nullopt;
    auto loop =
        rewriter.create<scf::ForOp>(loc, lbCst, ubCst, stepCst, iterArgs);

    // Handle the iteration argument if it is provided.
    if (iterArg) {
      iterArg = loop.getRegionIterArg(0);
      // For the outermost loop, we return the loop result. For the other loops,
      // we just yield the loop result and continue to the next loop.
      if (ivs.empty())
        result = loop.getResult(0);
      else
        rewriter.create<scf::YieldOp>(loc, loop.getResult(0));
    }

    // Set the insertion point to the start of the loop body.
    rewriter.setInsertionPointToStart(loop.getBody());
    ivs.push_back(loop.getInductionVar());
  }
  return std::make_tuple(ivs, result, iterArg);
}

SmallVector<scf::ForOp> scalehls::getSurroundingLoops(Operation *target,
                                                      Block *sourceBlock) {
  SmallVector<scf::ForOp> reversedLoops;
  while (auto parent = target->getParentOp()) {
    if (auto loop = dyn_cast<scf::ForOp>(parent))
      reversedLoops.push_back(loop);
    target = parent;
    if (sourceBlock == parent->getBlock())
      break;
  }
  return {reversedLoops.rbegin(), reversedLoops.rend()};
}

std::optional<SmallVector<int64_t>>
scalehls::getLoopSteps(const SmallVector<scf::ForOp> &loops) {
  SmallVector<int64_t> steps;
  for (auto loop : loops) {
    auto stepCstOp = getConstantIntValue(loop.getStep());
    if (!stepCstOp)
      return std::nullopt;

    int64_t stepCst = stepCstOp.value();
    assert(stepCst >= 0 && "expected positive loop step");
    steps.push_back(stepCst);
  }
  return steps;
}

std::optional<SmallVector<int64_t>>
scalehls::getLoopTripCounts(const SmallVector<scf::ForOp> &loops) {
  SmallVector<int64_t> tripCounts;
  for (auto loop : loops) {
    auto lbCstOp = getConstantIntValue(loop.getLowerBound());
    auto ubCstOp = getConstantIntValue(loop.getUpperBound());
    auto stepCstOp = getConstantIntValue(loop.getStep());
    if (!lbCstOp || !ubCstOp || !stepCstOp)
      return std::nullopt;

    int64_t lbCst = lbCstOp.value();
    int64_t ubCst = ubCstOp.value();
    int64_t stepCst = stepCstOp.value();
    assert(lbCst >= 0 && ubCst >= 0 && stepCst >= 0 &&
           "expected positive loop bounds and step");
    if ((ubCst - lbCst) % stepCst != 0)
      return std::nullopt;
    tripCounts.push_back((ubCst - lbCst) / stepCst);
  }
  return tripCounts;
}

bool scalehls::crossRegionDominates(Operation *a, Operation *b) {
  if (a == b)
    return true;
  if (b->isAncestor(a))
    return false;
  while (a->getParentOp() && !a->getParentOp()->isAncestor(b))
    a = a->getParentOp();
  assert(a->getParentOp() && "reach top-level module op");
  return DominanceInfo().dominates(a, b);
}
