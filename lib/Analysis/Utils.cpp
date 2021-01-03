//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "mlir/Analysis/AffineAnalysis.h"
#include "llvm/ADT/SmallPtrSet.h"

using namespace mlir;
using namespace scalehls;

/// Collect all load and store operations in the block.
void scalehls::getMemAccessesMap(Block &block, MemAccessesMap &map,
                                 bool includeCalls) {
  for (auto &op : block) {
    if (isa<AffineReadOpInterface, AffineWriteOpInterface>(op))
      map[MemRefAccess(&op).memref].push_back(&op);

    else if (includeCalls && isa<CallOp>(op)) {
      // All CallOps accessing the memory will be pushed back to the map.
      for (auto operand : op.getOperands())
        if (operand.getType().isa<MemRefType>())
          map[operand].push_back(&op);

    } else if (op.getNumRegions()) {
      // Recursively collect memory access operations in each block.
      for (auto &region : op.getRegions())
        for (auto &block : region)
          getMemAccessesMap(block, map);
    }
  }
}

Optional<std::pair<int64_t, int64_t>>
scalehls::getBoundOfAffineBound(AffineBound bound, MLIRContext *context) {
  // For now, we can only handle one result affine bound.
  if (bound.getMap().getNumResults() != 1)
    return Optional<std::pair<int64_t, int64_t>>();

  SmallVector<int64_t, 4> lbs;
  SmallVector<int64_t, 4> ubs;
  for (auto operand : bound.getOperands()) {
    // Only if the affine bound operands are induction variable, the calculation
    // is possible.
    if (!isForInductionVar(operand))
      return Optional<std::pair<int64_t, int64_t>>();

    // Only if the owner for op of the induction variable has constant bound,
    // the calculation is possible.
    auto ifOp = getForInductionVarOwner(operand);
    if (!ifOp.hasConstantBounds())
      return Optional<std::pair<int64_t, int64_t>>();

    auto lb = ifOp.getConstantLowerBound();
    auto ub = ifOp.getConstantUpperBound();
    auto step = ifOp.getStep();

    lbs.push_back(lb);
    ubs.push_back(ub - 1 - (ub - 1 - lb) % step);
  }

  // TODO: maybe a more efficient algorithm.
  auto operandNum = bound.getNumOperands();
  SmallVector<int64_t, 16> results;
  for (unsigned i = 0, e = pow(2, operandNum); i < e; ++i) {
    SmallVector<AffineExpr, 4> replacements;
    for (unsigned pos = 0; pos < operandNum; ++pos) {
      if (i >> pos % 2 == 0)
        replacements.push_back(getAffineConstantExpr(lbs[pos], context));
      else
        replacements.push_back(getAffineConstantExpr(ubs[pos], context));
    }
    auto newExpr =
        bound.getMap().getResult(0).replaceDimsAndSymbols(replacements, {});

    if (auto constExpr = newExpr.dyn_cast<AffineConstantExpr>())
      results.push_back(constExpr.getValue());
    else
      return Optional<std::pair<int64_t, int64_t>>();
  }

  auto minmax = std::minmax_element(results.begin(), results.end());
  return std::pair<int64_t, int64_t>(*minmax.first, *minmax.second);
}

// Check if the lhsOp and rhsOp is at the same scheduling level. In this
// check, AffineIfOp is transparent.
Optional<std::pair<Operation *, Operation *>>
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
          if (auto parentOp = currentOp->getParentOfType<AffineIfOp>()) {
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

  return Optional<std::pair<Operation *, Operation *>>();
}

// Get the pointer of the scrOp's parent loop, which should locat at the same
// level with dstOp's any parent loop.
Operation *scalehls::getSameLevelDstOp(Operation *srcOp, Operation *dstOp) {
  // If srcOp and dstOp are already at the same level, return the srcOp.
  if (checkSameLevel(srcOp, dstOp))
    return dstOp;

  // Helper to get all surrouding AffineForOps. AffineIfOps are skipped.
  auto getSurroundFors =
      ([&](Operation *op, SmallVector<Operation *, 4> &nests) {
        nests.push_back(op);
        auto currentOp = op;
        while (true) {
          if (auto parentOp = currentOp->getParentOfType<AffineForOp>()) {
            nests.push_back(parentOp);
            currentOp = parentOp;
          } else if (auto parentOp = currentOp->getParentOfType<AffineIfOp>())
            currentOp = parentOp;
          else
            break;
        }
      });

  SmallVector<Operation *, 4> srcNests;
  SmallVector<Operation *, 4> dstNests;

  getSurroundFors(srcOp, srcNests);
  getSurroundFors(dstOp, dstNests);

  // If any parent of srcOp (or itself) and any parent of dstOp (or itself) are
  // at the same level, return the pointer.
  for (auto src : srcNests)
    for (auto dst : dstNests)
      if (checkSameLevel(src, dst))
        return dst;

  return nullptr;
}

/// Get the definition ArrayOp given any memref or memory access operation.
hlscpp::ArrayOp scalehls::getArrayOp(Value memref) {
  assert(memref.getType().isa<MemRefType>() && "isn't a MemRef type value");

  auto defOp = memref.getDefiningOp();
  assert(defOp && "MemRef is block argument");

  auto arrayOp = dyn_cast<hlscpp::ArrayOp>(defOp);
  assert(arrayOp && "MemRef is not defined by ArrayOp");

  return arrayOp;
}

hlscpp::ArrayOp scalehls::getArrayOp(Operation *op) {
  return getArrayOp(MemRefAccess(op).memref);
}

void scalehls::getPartitionFactors(ArrayRef<int64_t> shape, AffineMap layoutMap,
                                   SmallVector<int64_t, 4> &factors) {
  for (unsigned dim = 0, e = shape.size(); dim < e; ++dim) {
    auto expr = layoutMap.getResult(dim);

    if (auto binaryExpr = expr.dyn_cast<AffineBinaryOpExpr>()) {
      if (auto factor = binaryExpr.getRHS().dyn_cast<AffineConstantExpr>()) {
        if (expr.getKind() == AffineExprKind::Mod)
          factors.push_back(factor.getValue());
        else if (expr.getKind() == AffineExprKind::FloorDiv) {
          auto blockFactor =
              (shape[dim] + factor.getValue() - 1) / factor.getValue();
          factors.push_back(blockFactor);
        }
      }
    } else if (auto constExpr = expr.dyn_cast<AffineConstantExpr>()) {
      if (constExpr.getValue() == 0)
        factors.push_back(1);
    }
  }
}
