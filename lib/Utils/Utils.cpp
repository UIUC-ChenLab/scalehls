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
#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;
using namespace affine;

//===----------------------------------------------------------------------===//
// Linalg Analysis Utils
//===----------------------------------------------------------------------===//

bool scalehls::isElementwiseGenericOp(linalg::GenericOp op) {
  // All loops must be parallel loop.
  if (op.getNumParallelLoops() != op.getNumLoops())
    return false;

  for (auto valueMap : llvm::zip(op.getOperands(), op.getIndexingMapsArray())) {
    auto type = std::get<0>(valueMap).getType().dyn_cast<ShapedType>();
    auto map = std::get<1>(valueMap);

    // If the operand doens't have static shape, the index map must be identity.
    if (!type || !type.hasStaticShape()) {
      if (!map.isIdentity())
        return false;
      continue;
    }

    // Otherwise, each dimension must either have a size of one or have identity
    // access index.
    unsigned index = map.getNumDims() - type.getRank();
    for (auto shapeExpr : llvm::zip(type.getShape(), map.getResults())) {
      auto dimSize = std::get<0>(shapeExpr);
      auto expr = std::get<1>(shapeExpr);
      if (expr != getAffineDimExpr(index++, expr.getContext()) && dimSize != 1)
        return false;
    }
  }
  return true;
}

//===----------------------------------------------------------------------===//
// Memory and Loop Analysis Utils
//===----------------------------------------------------------------------===//

/// The current op or contained ops have effect on external buffers.
bool scalehls::hasEffectOnExternalBuffer(Operation *op) {
  auto result = op->walk([](MemoryEffectOpInterface effectOp) {
    SmallVector<MemoryEffects::EffectInstance> effects;
    effectOp.getEffects(effects);
    for (auto effect : effects)
      if (isExtBuffer(effect.getValue()))
        return WalkResult::interrupt();
    return WalkResult::advance();
  });
  return result.wasInterrupted();
}

/// Distribute the given factor from the innermost loop of the given loop band,
/// so that we can apply vectorize, unroll and jam, etc.
FactorList
scalehls::getDistributedFactors(unsigned factor,
                                const SmallVectorImpl<AffineForOp> &band) {
  FactorList factors;
  unsigned remainFactor = factor;

  for (auto it = band.rbegin(), e = band.rend(); it != e; ++it) {
    if (auto optionalTripCount = getConstantTripCount(*it)) {
      auto tripCount = optionalTripCount.value();
      auto size = tripCount;

      if (remainFactor >= tripCount)
        remainFactor = (remainFactor + tripCount - 1) / tripCount;
      else if (remainFactor > 1) {
        size = 1;
        while (size < remainFactor || tripCount % size != 0)
          ++size;
        remainFactor = 1;
      } else
        size = 1;

      factors.push_back(size);
    } else
      factors.push_back(1);
  }
  std::reverse(factors.begin(), factors.end());
  return factors;
}

/// Distribute the given factor evenly on all loop levels. The generated factors
/// are garanteed to be divisors of the factors in given "costrFactorsList".
/// This method can fail due to non-constant loop trip counts.
LogicalResult scalehls::getEvenlyDistributedFactors(
    unsigned maxFactor, FactorList &factors,
    const SmallVectorImpl<AffineForOp> &band,
    const SmallVectorImpl<FactorList> &constrFactorsList, bool powerOf2Constr) {

  // auto emitFactors = [&](const FactorList &factors) {
  //   llvm::errs() << "factors: ";
  //   for (auto factor : factors)
  //     llvm::errs() << factor << " ";
  //   llvm::errs() << "\n";
  // };

  // llvm::errs() << "\n==========\n";

  // llvm::errs() << "Init ";
  // emitFactors(factors);

  // for (auto &constrFactors : constrFactorsList) {
  //   llvm::errs() << "Constr ";
  //   emitFactors(constrFactors);
  // }

  // llvm::errs() << band.front() << "\n";

  // Traverse each loop in the given loop band.
  SmallVector<FactorList> constrs;
  SmallVector<bool> reductionFlags;
  FactorList tripCounts;
  for (auto loop : llvm::enumerate(band)) {
    // Collect the loop trip counts. If any trip count cannot be resolved, we
    // return failure.
    auto tripCount = getConstantTripCount(loop.value());
    if (!tripCount.has_value())
      return failure();
    tripCounts.push_back(tripCount.value());

    // Collect the constraints at each loop level. Basically, this transposes
    // the two-dimension argument "constrFactorsList".
    FactorList constr;
    for (auto &constrFactors : constrFactorsList) {
      assert(tripCount.value() % constrFactors[loop.index()] == 0 &&
             "contraint factor isn't divisor of corresponding trip count");
      constr.push_back(constrFactors[loop.index()]);
    }
    constrs.push_back(constr);

    // Collect the reduction loop flags.
    reductionFlags.push_back(!hasParallelAttr(loop.value()) &&
                             !isLoopParallel(loop.value()));
  }

  // A helper to increase the factor until all contraints are met.
  auto increaseFactor = [&](unsigned &factor, unsigned loopDepth) {
    auto tripCount = tripCounts[loopDepth];
    auto constr = constrs[loopDepth];

    // The constraints include: 1) factor must be a divisor of trip count; 2)
    // factor must be a divisor or divisible by all constraints. If applicable,
    // factor must be a power of 2.
    auto factorMeetConstr = [&]() {
      auto result =
          tripCount % factor == 0 && llvm::all_of(constr, [&](unsigned v) {
            return v % factor == 0 || factor % v == 0;
          });
      if (powerOf2Constr)
        result &= llvm::isPowerOf2_64(factor);
      return result;
    };
    assert(factorMeetConstr() && "initial factor doesn't meet constraints");

    auto initFactor = factor;
    if (factor < tripCount) {
      if (powerOf2Constr)
        factor *= 2;
      else
        factor++;
    }

    while (!factorMeetConstr() && factor < tripCount) {
      // If we have the power of 2 constraint, then there's no chance to get a
      // higher factor than the initial one.
      if (powerOf2Constr) {
        factor = initFactor;
        break;
      } else
        factor++;
    }
  };

  // A helper to calculate the overall factors of the given factors.
  auto canReturn = [&](FactorList factors) {
    // Check whether the current overall factor is larger equal to the max
    // factor to achieve.
    unsigned overallFactor = 1;
    for (auto factor : factors)
      overallFactor *= factor;
    if (maxFactor > overallFactor)
      return false;

    // Check whether the current factors meet all constraints.
    for (auto t : llvm::zip(factors, constrs)) {
      auto factor = std::get<0>(t);
      auto constr = std::get<1>(t);
      if (llvm::any_of(constr, [&](unsigned v) {
            return v % factor != 0 && factor % v != 0;
          }))
        return false;
    }
    return true;
  };

  // Increase the unroll factors until reach the overall factor.
  while (!canReturn(factors)) {
    // Candidates list holding the reduction flag, increasing rate, current
    // factor, and the loop depth.
    SmallVector<std::tuple<bool, float, unsigned, unsigned>> candidates;
    for (auto t : llvm::enumerate(llvm::zip(reductionFlags, factors))) {
      auto flag = std::get<0>(t.value());
      auto factor = std::get<1>(t.value());
      auto newFactor = factor;

      increaseFactor(newFactor, t.index());
      if (newFactor != factor)
        candidates.push_back(
            {flag, (float)newFactor / factor, factor, t.index()});
    }

    // Break the while loop if there's no candidates available.
    if (candidates.empty())
      break;

    // Sort the candidate factors. The rationale is: 1) Parallel loop can help
    // to best parallelize the band. 2) Smaller increasing rate can help to
    // match the overall parallel factor as much as possible. 3) Smaller current
    // factor can help to distribute the overall parallel evenly. 4) Always
    // choose inner loop can help to achieve deterministic transformation result
    // of the pass.
    llvm::sort(candidates, [](auto a, auto b) {
      // Parallel loop is preferred.
      if (std::get<0>(a) != std::get<0>(b))
        return std::get<0>(a) < std::get<0>(b);

      // Smaller increasing rate is preferred.
      if (std::get<1>(a) != std::get<1>(b))
        return std::get<1>(a) < std::get<1>(b);

      // Smaller current factor is preferred.
      if (std::get<2>(a) != std::get<2>(b))
        return std::get<2>(a) < std::get<2>(b);

      // Inner loop is preferred.
      return std::get<3>(a) > std::get<3>(b);
    });

    auto depth = std::get<3>(candidates.front());
    increaseFactor(factors[depth], depth);
  }

  // llvm::errs() << "Final ";
  // emitFactors(factors);
  return success();
}

/// Replace all occurrences of AffineExpr at position `pos` in `map` by the
/// defining AffineApplyOp expression and operands.
/// When `dimOrSymbolPosition < dims.size()`, AffineDimExpr@[pos] is replaced.
/// When `dimOrSymbolPosition >= dims.size()`,
/// AffineSymbolExpr@[pos - dims.size()] is replaced.
/// Mutate `map`,`dims` and `syms` in place as follows:
///   1. `dims` and `syms` are only appended to.
///   2. `map` dim and symbols are gradually shifted to higher positions.
///   3. Old `dim` and `sym` entries are replaced by nullptr
/// This avoids the need for any bookkeeping.
static LogicalResult replaceDimOrSym(AffineMap *map,
                                     unsigned dimOrSymbolPosition,
                                     SmallVectorImpl<Value> &dims,
                                     SmallVectorImpl<Value> &syms) {
  MLIRContext *ctx = map->getContext();
  bool isDimReplacement = (dimOrSymbolPosition < dims.size());
  unsigned pos = isDimReplacement ? dimOrSymbolPosition
                                  : dimOrSymbolPosition - dims.size();
  Value &v = isDimReplacement ? dims[pos] : syms[pos];
  if (!v)
    return failure();

  auto affineApply = v.getDefiningOp<AffineApplyOp>();
  if (!affineApply)
    return failure();

  // At this point we will perform a replacement of `v`, set the entry in `dim`
  // or `sym` to nullptr immediately.
  v = nullptr;

  // Compute the map, dims and symbols coming from the AffineApplyOp.
  AffineMap composeMap = affineApply.getAffineMap();
  assert(composeMap.getNumResults() == 1 && "affine.apply with >1 results");
  SmallVector<Value> composeOperands(affineApply.getMapOperands().begin(),
                                     affineApply.getMapOperands().end());
  // Canonicalize the map to promote dims to symbols when possible. This is to
  // avoid generating invalid maps.
  canonicalizeMapAndOperands(&composeMap, &composeOperands);
  AffineExpr replacementExpr =
      composeMap.shiftDims(dims.size()).shiftSymbols(syms.size()).getResult(0);
  ValueRange composeDims =
      ArrayRef<Value>(composeOperands).take_front(composeMap.getNumDims());
  ValueRange composeSyms =
      ArrayRef<Value>(composeOperands).take_back(composeMap.getNumSymbols());
  AffineExpr toReplace = isDimReplacement ? getAffineDimExpr(pos, ctx)
                                          : getAffineSymbolExpr(pos, ctx);

  // Append the dims and symbols where relevant and perform the replacement.
  dims.append(composeDims.begin(), composeDims.end());
  syms.append(composeSyms.begin(), composeSyms.end());
  *map = map->replace(toReplace, replacementExpr, dims.size(), syms.size());

  return success();
}

/// Iterate over `operands` and fold away all those produced by an AffineApplyOp
/// iteratively. Perform canonicalization of map and operands as well as
/// AffineMap simplification. `map` and `operands` are mutated in place.
static void composeAffineMapAndOperands(AffineMap *map,
                                        SmallVectorImpl<Value> *operands) {
  if (map->getNumResults() == 0) {
    canonicalizeMapAndOperands(map, operands);
    *map = simplifyAffineMap(*map);
    return;
  }

  MLIRContext *ctx = map->getContext();
  SmallVector<Value, 4> dims(operands->begin(),
                             operands->begin() + map->getNumDims());
  SmallVector<Value, 4> syms(operands->begin() + map->getNumDims(),
                             operands->end());

  // Iterate over dims and symbols coming from AffineApplyOp and replace until
  // exhaustion. This iteratively mutates `map`, `dims` and `syms`. Both `dims`
  // and `syms` can only increase by construction.
  // The implementation uses a `while` loop to support the case of symbols
  // that may be constructed from dims ;this may be overkill.
  while (true) {
    bool changed = false;
    for (unsigned pos = 0; pos != dims.size() + syms.size(); ++pos)
      if ((changed |= succeeded(replaceDimOrSym(map, pos, dims, syms))))
        break;
    if (!changed)
      break;
  }

  // Clear operands so we can fill them anew.
  operands->clear();

  // At this point we may have introduced null operands, prune them out before
  // canonicalizing map and operands.
  unsigned nDims = 0, nSyms = 0;
  SmallVector<AffineExpr, 4> dimReplacements, symReplacements;
  dimReplacements.reserve(dims.size());
  symReplacements.reserve(syms.size());
  for (auto *container : {&dims, &syms}) {
    bool isDim = (container == &dims);
    auto &repls = isDim ? dimReplacements : symReplacements;
    for (const auto &en : llvm::enumerate(*container)) {
      Value v = en.value();
      if (!v) {
        assert(isDim ? !map->isFunctionOfDim(en.index())
                     : !map->isFunctionOfSymbol(en.index()) &&
                           "map is function of unexpected expr@pos");
        repls.push_back(getAffineConstantExpr(0, ctx));
        continue;
      }
      repls.push_back(isDim ? getAffineDimExpr(nDims++, ctx)
                            : getAffineSymbolExpr(nSyms++, ctx));
      operands->push_back(v);
    }
  }
  *map = map->replaceDimsAndSymbols(dimReplacements, symReplacements, nDims,
                                    nSyms);

  // Canonicalize and simplify before returning.
  canonicalizeMapAndOperands(map, operands);
  *map = simplifyAffineMap(*map);
}

/// Compose any affine.apply ops feeding into `operands` of the integer set
/// `set` by composing the maps of such affine.apply ops with the integer
/// set constraints.
void scalehls::composeSetAndOperands(IntegerSet &set,
                                     SmallVectorImpl<Value> &operands) {
  // We will simply reuse the API of the map composition by viewing the LHSs of
  // the equalities and inequalities of `set` as the affine exprs of an affine
  // map. Convert to equivalent map, compose, and convert back to set.
  auto map = AffineMap::get(set.getNumDims(), set.getNumSymbols(),
                            set.getConstraints(), set.getContext());
  // Check if any composition is possible.
  if (llvm::none_of(operands,
                    [](Value v) { return v.getDefiningOp<AffineApplyOp>(); }))
    return;

  composeAffineMapAndOperands(&map, &operands);
  set = IntegerSet::get(map.getNumDims(), map.getNumSymbols(), map.getResults(),
                        set.getEqFlags());
}

/// Return a pair which indicates whether the if statement is always true or
/// false, respectively. The returned result is one-hot.
std::pair<bool, bool> scalehls::ifAlwaysTrueOrFalse(AffineIfOp ifOp) {
  auto set = ifOp.getIntegerSet();
  auto operands = SmallVector<Value, 4>(ifOp.getOperands().begin(),
                                        ifOp.getOperands().end());

  // Compose all associated AffineApplyOp into the current if operation.
  while (llvm::any_of(operands, [](Value v) {
    return isa_and_nonnull<AffineApplyOp>(v.getDefiningOp());
  })) {
    composeSetAndOperands(set, operands);
  }

  // Replace the original integer set and operands with the composed integer
  // set and operands.
  ifOp.setIntegerSet(set);
  ifOp->setOperands(operands);

  // Construct the constraints of the if statement. For now, we only add the
  // loop induction constraints and integer set constraint.
  FlatAffineValueConstraints constrs;
  constrs.addAffineIfOpDomain(ifOp);
  for (auto operand : operands)
    if (isAffineForInductionVar(operand)) {
      auto iv = getForInductionVarOwner(operand);
      if (failed(constrs.addAffineForOpDomain(iv)))
        continue;
    }

  bool alwaysTrue = false;
  bool alwaysFalse = false;

  if (set.getNumInputs() == 0) {
    // If the integer set is pure constant set, determine whether the
    // condition is always true or always false.
    SmallVector<bool, 4> flagList;
    unsigned idx = 0;
    for (auto expr : set.getConstraints()) {
      bool eqFlag = set.isEq(idx++);
      auto constValue = cast<AffineConstantExpr>(expr).getValue();

      if (eqFlag)
        flagList.push_back(constValue == 0);
      else
        flagList.push_back(constValue >= 0);
    }

    // Only when all sub-conditions are met, the if statement is always true.
    // Otherwise, the statement if always false.
    if (llvm::all_of(flagList, [&](bool flag) { return flag; }))
      alwaysTrue = true;
    else
      alwaysFalse = true;

  } else if (constrs.isEmpty()) {
    // If there is no solution for the constraints, the condition will always
    // be false.
    alwaysFalse = true;
  }

  // Assert only one of the two flags are true.
  assert((!alwaysTrue || !alwaysFalse) && "unexpected if condition");
  return {alwaysTrue, alwaysFalse};
}

/// Check whether the two given if statements have the same condition.
bool scalehls::checkSameIfStatement(AffineIfOp lhsOp, AffineIfOp rhsOp) {
  if (lhsOp == nullptr || rhsOp == nullptr)
    return false;

  auto lhsSet = lhsOp.getIntegerSet();
  auto rhsSet = rhsOp.getIntegerSet();

  // TODO: support if statement with return values.
  if (lhsOp.getNumResults() != 0 || rhsOp.getNumResults() != 0 ||
      lhsOp.getOperands() != rhsOp.getOperands() ||
      lhsSet.getConstraints() != rhsSet.getConstraints() ||
      lhsSet.getEqFlags() != rhsSet.getEqFlags())
    return false;
  return true;
}

/// Parse array attributes.
SmallVector<int64_t, 8> scalehls::getIntArrayAttrValue(Operation *op,
                                                       StringRef name) {
  SmallVector<int64_t, 8> array;
  if (auto arrayAttr = op->getAttrOfType<ArrayAttr>(name)) {
    for (auto attr : arrayAttr)
      if (auto intAttr = attr.dyn_cast<IntegerAttr>())
        array.push_back(intAttr.getInt());
      else
        return SmallVector<int64_t, 8>();
    return array;
  } else
    return SmallVector<int64_t, 8>();
}

/// Collect all load and store operations in the block and return them in "map".
void scalehls::getMemAccessesMap(Block &block, MemAccessesMap &map,
                                 bool includeVectorTransfer) {
  for (auto &op : block) {
    if (auto load = dyn_cast<AffineReadOpInterface>(op))
      map[load.getMemRef()].push_back(&op);

    else if (auto store = dyn_cast<AffineWriteOpInterface>(op))
      map[store.getMemRef()].push_back(&op);

    else if (auto read = dyn_cast<vector::TransferReadOp>(op)) {
      if (includeVectorTransfer)
        map[read.getSource()].push_back(&op);

    } else if (auto write = dyn_cast<vector::TransferWriteOp>(op)) {
      if (includeVectorTransfer)
        map[write.getSource()].push_back(&op);

    } else if (op.getNumRegions()) {
      // Recursively collect memory access operations in each block.
      for (auto &region : op.getRegions())
        for (auto &block : region)
          getMemAccessesMap(block, map);
    }
  }
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

// Check if the lhsOp and rhsOp are in the same block. If so, return their
// ancestors that are located at the same block. Note that in this check,
// AffineIfOp is transparent.
std::optional<std::pair<Operation *, Operation *>>
scalehls::checkSameLevel(Operation *lhsOp, Operation *rhsOp) {
  // If lhsOp and rhsOp are already at the same level, return true.
  if (lhsOp->getBlock() == rhsOp->getBlock())
    return std::pair<Operation *, Operation *>(lhsOp, rhsOp);

  // Helper to get all surrounding AffineIfOps.
  auto getSurroundIfs =
      ([&](Operation *op, SmallVector<Operation *, 4> &nests) {
        nests.push_back(op);
        auto currentOp = op;
        while (true) {
          auto parentOp = currentOp->getParentOp();
          if (isa<AffineIfOp, scf::IfOp>(parentOp)) {
            nests.push_back(parentOp);
            currentOp = parentOp;
          } else
            break;
        }
      });

  SmallVector<Operation *, 4> lhsNests;
  SmallVector<Operation *, 4> rhsNests;

  getSurroundIfs(lhsOp, lhsNests);
  getSurroundIfs(rhsOp, rhsNests);

  // If any parent of lhsOp and any parent of rhsOp are at the same level,
  // return true.
  for (auto lhs : lhsNests)
    for (auto rhs : rhsNests)
      if (lhs->getBlock() == rhs->getBlock())
        return std::pair<Operation *, Operation *>(lhs, rhs);

  return std::optional<std::pair<Operation *, Operation *>>();
}

/// Returns the number of surrounding loops common to 'loopsA' and 'loopsB',
/// where each lists loops from outer-most to inner-most in loop nest.
unsigned scalehls::getCommonSurroundingLoops(Operation *A, Operation *B,
                                             AffineLoopBand *band) {
  SmallVector<AffineForOp, 4> loopsA, loopsB;
  getAffineForIVs(*A, &loopsA);
  getAffineForIVs(*B, &loopsB);

  unsigned minNumLoops = std::min(loopsA.size(), loopsB.size());
  unsigned numCommonLoops = 0;
  for (unsigned i = 0; i < minNumLoops; ++i) {
    if (loopsA[i] != loopsB[i])
      break;
    ++numCommonLoops;
    if (band != nullptr)
      band->push_back(loopsB[i]);
  }
  return numCommonLoops;
}

/// Calculate the lower and upper bound of the affine map if possible.
std::optional<std::pair<int64_t, int64_t>>
scalehls::getBoundOfAffineMap(AffineMap map, ValueRange operands) {
  if (map.isSingleConstant()) {
    auto constBound = map.getSingleConstantResult();
    return std::pair<int64_t, int64_t>(constBound, constBound);
  }

  // For now, we can only handle one result value map.
  if (map.getNumResults() != 1)
    return std::optional<std::pair<int64_t, int64_t>>();

  auto context = map.getContext();
  SmallVector<int64_t, 4> lbs;
  SmallVector<int64_t, 4> ubs;
  for (auto operand : operands) {
    // Only if the affine map operands are induction variable, the calculation
    // is possible.
    if (!isAffineForInductionVar(operand))
      return std::optional<std::pair<int64_t, int64_t>>();

    // Only if the owner for op of the induction variable has constant bound,
    // the calculation is possible.
    auto forOp = getForInductionVarOwner(operand);
    if (!forOp.hasConstantBounds())
      return std::optional<std::pair<int64_t, int64_t>>();

    auto lb = forOp.getConstantLowerBound();
    auto ub = forOp.getConstantUpperBound();
    auto step = forOp.getStep().getSExtValue();

    lbs.push_back(lb);
    ubs.push_back(ub - 1 - (ub - 1 - lb) % step);
  }

  // TODO: maybe a more efficient algorithm.
  auto operandNum = operands.size();
  SmallVector<int64_t, 16> results;
  for (unsigned i = 0, e = pow(2, operandNum); i < e; ++i) {
    SmallVector<AffineExpr, 4> replacements;
    for (unsigned pos = 0; pos < operandNum; ++pos) {
      if (i >> pos % 2 == 0)
        replacements.push_back(getAffineConstantExpr(lbs[pos], context));
      else
        replacements.push_back(getAffineConstantExpr(ubs[pos], context));
    }
    auto newExpr = map.getResult(0).replaceDimsAndSymbols(replacements, {});

    if (auto constExpr = dyn_cast<AffineConstantExpr>(newExpr))
      results.push_back(constExpr.getValue());
    else
      return std::optional<std::pair<int64_t, int64_t>>();
  }

  auto minmax = std::minmax_element(results.begin(), results.end());
  return std::pair<int64_t, int64_t>(*minmax.first, *minmax.second);
}

bool scalehls::isFullyPartitioned(MemRefType memrefType) {
  if (memrefType.getRank() == 0)
    return true;

  bool fullyPartitioned = false;
  SmallVector<int64_t, 8> factors;
  getPartitionFactors(memrefType, &factors);

  auto shapes = memrefType.getShape();
  fullyPartitioned =
      factors == SmallVector<int64_t, 8>(shapes.begin(), shapes.end());

  return fullyPartitioned;
}

// Calculate partition factors through analyzing the "memrefType" and return
// them in "factors". Meanwhile, the overall partition number is calculated and
// returned as well.
int64_t scalehls::getPartitionFactors(MemRefType memrefType,
                                      SmallVectorImpl<int64_t> *factors) {
  int64_t accumFactor = 1;
  if (auto attr = memrefType.getLayout().dyn_cast<PartitionLayoutAttr>())
    for (auto factor : attr.getActualFactors(memrefType.getShape())) {
      accumFactor *= factor;
      if (factors)
        factors->push_back(factor);
    }
  else if (factors)
    factors->assign(memrefType.getRank(), 1);
  return accumFactor;
}

/// This is method for finding the number of child loops which immediatedly
/// contained by the input operation.
unsigned scalehls::getChildLoopNum(Operation *op) {
  unsigned childNum = 0;
  for (auto &region : op->getRegions())
    for (auto &block : region)
      for (auto &op : block)
        if (isa<AffineForOp>(op))
          ++childNum;

  return childNum;
}

/// Given a tiled loop band, return true and get the tile (tile-space) loop band
/// and the point (intra-tile) loop band. If failed, return false.
bool scalehls::getTileAndPointLoopBand(const AffineLoopBand &band,
                                       AffineLoopBand &tileBand,
                                       AffineLoopBand &pointBand) {
  tileBand.clear();
  pointBand.clear();
  bool isPointLoop = false;

  for (auto loop : band) {
    if (!isPointLoop && !hasPointAttr(loop))
      tileBand.push_back(loop);

    else if (isPointLoop && hasPointAttr(loop))
      pointBand.push_back(loop);

    else if (!isPointLoop && hasPointAttr(loop)) {
      isPointLoop = true;
      pointBand.push_back(loop);

    } else {
      tileBand.clear();
      pointBand.clear();
      return false;
    }
  }
  return true;
}

/// Given a loop band, return true and get the parallel loop band outsides and
/// the reduction loop band inside. If failed, return false.
bool scalehls::getParallelAndReductionLoopBand(const AffineLoopBand &band,
                                               AffineLoopBand &parallelBand,
                                               AffineLoopBand &reductionBand) {
  parallelBand.clear();
  reductionBand.clear();
  bool isReductionLoop = false;

  for (auto loop : band) {
    if (!isReductionLoop && (hasParallelAttr(loop) || isLoopParallel(loop)))
      parallelBand.push_back(loop);

    else if (isReductionLoop &&
             !(hasParallelAttr(loop) || isLoopParallel(loop)))
      reductionBand.push_back(loop);

    else if (!isReductionLoop &&
             !(hasParallelAttr(loop) || isLoopParallel(loop))) {
      isReductionLoop = true;
      reductionBand.push_back(loop);

    } else {
      parallelBand.clear();
      reductionBand.clear();
      return false;
    }
  }
  return true;
}

/// Get the whole loop band given the outermost loop and return it in "band".
/// Meanwhile, the return value is the innermost loop of this loop band.
AffineForOp scalehls::getLoopBandFromOutermost(AffineForOp forOp,
                                               AffineLoopBand &band) {
  band.clear();
  auto currentLoop = forOp;
  while (true) {
    band.push_back(currentLoop);

    if (getChildLoopNum(currentLoop) == 1)
      currentLoop = *currentLoop.getOps<AffineForOp>().begin();
    else
      break;
  }
  return band.back();
}
AffineForOp scalehls::getLoopBandFromInnermost(AffineForOp forOp,
                                               AffineLoopBand &band) {
  band.clear();
  AffineLoopBand reverseBand;

  auto currentLoop = forOp;
  while (true) {
    reverseBand.push_back(currentLoop);

    auto parentLoop = currentLoop->getParentOfType<AffineForOp>();
    if (!parentLoop)
      break;

    if (getChildLoopNum(parentLoop) == 1)
      currentLoop = parentLoop;
    else
      break;
  }

  band.append(reverseBand.rbegin(), reverseBand.rend());
  return band.front();
}

/// Collect all loop bands in the "block" and return them in "bands". If
/// "allowHavingChilds" is true, loop bands containing more than 1 other loop
/// bands are also collected. Otherwise, only loop bands that contains no child
/// loops are collected.
void scalehls::getLoopBands(Block &block, AffineLoopBands &bands,
                            bool allowHavingChilds) {
  bands.clear();
  block.walk([&](AffineForOp loop) {
    auto childNum = getChildLoopNum(loop);

    if (childNum == 0 || (childNum > 1 && allowHavingChilds)) {
      AffineLoopBand band;
      getLoopBandFromInnermost(loop, band);
      bands.push_back(band);
    }
  });
}

void scalehls::getArrays(Block &block, SmallVectorImpl<Value> &arrays,
                         bool allowArguments) {
  // Collect argument arrays.
  if (allowArguments)
    for (auto arg : block.getArguments()) {
      if (arg.getType().isa<MemRefType>())
        arrays.push_back(arg);
    }

  // Collect local arrays.
  for (auto &op : block.getOperations()) {
    if (isa<memref::AllocaOp, memref::AllocOp>(op))
      arrays.push_back(op.getResult(0));
  }
}

std::optional<unsigned> scalehls::getAverageTripCount(AffineForOp forOp) {
  if (auto optionalTripCount = getConstantTripCount(forOp))
    return optionalTripCount.value();
  else {
    // TODO: A temporary approach to estimate the trip count. For now, we take
    // the average of the upper bound and lower bound of trip count as the
    // estimated trip count.
    auto lowerBound = getBoundOfAffineMap(forOp.getLowerBoundMap(),
                                          forOp.getLowerBoundOperands());
    auto upperBound = getBoundOfAffineMap(forOp.getUpperBoundMap(),
                                          forOp.getUpperBoundOperands());

    if (lowerBound && upperBound) {
      auto lowerTripCount =
          upperBound.value().second - lowerBound.value().first;
      auto upperTripCount =
          upperBound.value().first - lowerBound.value().second;
      return (lowerTripCount + upperTripCount + 1) / 2;
    } else
      return std::optional<unsigned>();
  }
}

bool scalehls::checkDependence(Operation *A, Operation *B) {
  AffineLoopBand commonLoops;
  unsigned numCommonLoops = getCommonSurroundingLoops(A, B, &commonLoops);

  // Traverse each loop level to find dependencies.
  for (unsigned depth = numCommonLoops; depth > 0; depth--) {
    // Skip all parallel loop level.
    if (hasParallelAttr(commonLoops[depth - 1]))
      continue;

    FlatAffineValueConstraints depConstrs;
    DependenceResult result = checkMemrefAccessDependence(
        MemRefAccess(A), MemRefAccess(B), depth, &depConstrs,
        /*dependenceComponents=*/nullptr);
    if (hasDependence(result))
      return true;
  }

  return false;
}

func::FuncOp scalehls::getTopFunc(ModuleOp module, std::string topFuncName) {
  func::FuncOp topFunc;
  for (auto func : module.getOps<func::FuncOp>())
    if (hasTopFuncAttr(func) || func.getName() == topFuncName) {
      if (!topFunc)
        topFunc = func;
      else
        return func::FuncOp();
    }
  return topFunc;
}

func::FuncOp scalehls::getRuntimeFunc(ModuleOp module,
                                      std::string runtimeFuncName) {
  func::FuncOp runtimeFunc;
  for (auto func : module.getOps<func::FuncOp>())
    if (hasRuntimeAttr(func) || func.getName() == runtimeFuncName) {
      if (!runtimeFunc)
        runtimeFunc = func;
      else
        return func::FuncOp();
    }
  return runtimeFunc;
}
