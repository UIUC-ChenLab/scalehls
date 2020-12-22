//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "mlir/Analysis/AffineAnalysis.h"

using namespace mlir;
using namespace scalehls;

// Check if the lhsOp and rhsOp is at the same scheduling level. In this check,
// AffineIfOp is transparent.
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

// Get the innermost surrounding operation, either an AffineForOp or a FuncOp.
// In this method, AffineIfOp is transparent as well.
Operation *scalehls::getSurroundingOp(Operation *op) {
  auto currentOp = op;
  while (true) {
    if (auto parentIfOp = currentOp->getParentOfType<AffineIfOp>())
      currentOp = parentIfOp;
    else if (auto parentForOp = currentOp->getParentOfType<AffineForOp>())
      return parentForOp;
    else if (auto parentFuncOp = currentOp->getParentOfType<FuncOp>())
      return parentFuncOp;
    else
      return nullptr;
  }
}

// Get the pointer of the scrOp's parent loop, which should locate at the same
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

/// Collect all load and store operations in the block.
void scalehls::getMemAccessesMap(Block &block, MemAccessesMap &map,
                                 bool includeCalls) {
  for (auto &op : block) {
    if (isa<AffineReadOpInterface, AffineWriteOpInterface>(op))
      map[MemRefAccess(&op).memref].push_back(&op);

    else if (includeCalls && isa<CallOp>(op)) {
      // All CallOps accessing the memory will be pushed back to the map.
      for (auto operand : op.getOperands())
        if (operand.getType().isa<MemRefType>()) {
          map[operand].push_back(&op);
          break;
        }

    } else if (op.getNumRegions()) {
      // Recursively collect memory access operations in each block.
      for (auto &region : op.getRegions())
        for (auto &block : region)
          getMemAccessesMap(block, map);
    }
  }
}
