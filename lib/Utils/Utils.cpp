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

Value scalehls::getUntiledOperand(Value value) {
  while (auto arg = dyn_cast<BlockArgument>(value)) {
    if (auto loop = dyn_cast<scf::ForOp>(arg.getOwner()->getParentOp()))
      value = loop.getTiedLoopInit(arg)->get();
    else
      break;
  }
  return value;
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
