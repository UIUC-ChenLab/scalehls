//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Utils/Matchers.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "scalehls-matchers"

using namespace mlir;
using namespace scalehls;

//===----------------------------------------------------------------------===//
// BlockMatcher
//===----------------------------------------------------------------------===//

/// A helper that recursively check the equivalence between two values and
/// record the checking result in "map". For now, we don't consider
/// associativity in the current implementation.
bool BlockMatcher::checkEquivalence(Value a, Value b) {
  // If a and b are both block argument, they may be equivalent. If only one of
  // a and b is block argument, they cannot be equivalent.
  if (a.isa<BlockArgument>() && b.isa<BlockArgument>())
    return map[a].insert(b), true;
  else if ((a.isa<BlockArgument>() && !b.isa<BlockArgument>()) ||
           (!a.isa<BlockArgument>() && b.isa<BlockArgument>()))
    return false;

  // Otherwise, both a and b must have defining operations.
  auto opA = a.getDefiningOp();
  auto opB = b.getDefiningOp();

  // If a and b are both constant and have the same value, they are equivalent.
  // If only one of a and b is constant, they cannot be equivalent.
  if (isa<arith::ConstantOp>(opA) && isa<arith::ConstantOp>(opB)) {
    auto constA = cast<arith::ConstantOp>(opA).getValue();
    auto constB = cast<arith::ConstantOp>(opB).getValue();
    if (constA == constB)
      return map[a].insert(b), true;
    return false;
  } else if ((isa<arith::ConstantOp>(opA) && !isa<arith::ConstantOp>(opB)) ||
             (!isa<arith::ConstantOp>(opA) && isa<arith::ConstantOp>(opB)))
    return false;

  // If the defining operation of a and b has the same name and same predicate
  // (for comparison operations), we recursively check the equivalence of their
  // operands. Otherwise, they cannot be equivalent.
  if (opA->getName() == opB->getName()) {
    // TODO: Consider the reversed semantics of comparison operations.
    if (isa<arith::CmpIOp>(opA))
      if (cast<arith::CmpIOp>(opA).getPredicate() !=
          cast<arith::CmpIOp>(opB).getPredicate())
        return false;
    if (isa<arith::CmpFOp>(opA))
      if (cast<arith::CmpFOp>(opA).getPredicate() !=
          cast<arith::CmpFOp>(opB).getPredicate())
        return false;

    // We have checked the equivalence of the semantics of the defining ops of a
    // and b. Now we can recursively check the equivalence of their operands.
    if (opA->getNumOperands() == 1) {
      if (checkEquivalence(opA->getOperand(0), opB->getOperand(0)))
        return map[a].insert(b), true;
      return false;
    } else if (opA->getNumOperands() == 2) {
      // Here, we take communitivity into consideration.
      auto isEq = checkEquivalence(opA->getOperand(0), opB->getOperand(0)) &&
                  checkEquivalence(opA->getOperand(1), opB->getOperand(1));
      auto isCommEq =
          opA->hasTrait<OpTrait::IsCommutative>() &&
          checkEquivalence(opA->getOperand(0), opB->getOperand(1)) &&
          checkEquivalence(opA->getOperand(1), opB->getOperand(0));

      if (isEq || isCommEq)
        return map[a].insert(b), true;
      return false;
    }

    // The only operation with no operand and we can handle is constant op.
    return llvm::llvm_unreachable_internal("unknown op type"), false;
  }
  return false;
}

//===----------------------------------------------------------------------===//
// LinalgMatcher
//===----------------------------------------------------------------------===//

/// Match linalg operations "a" and "b". Return the matching results if the
/// matching is successful. Otherwise, return a failure.
FailureOr<LinalgMatchingResult> LinalgMatcher::match() {
  LLVM_DEBUG(llvm::dbgs() << "\n----- match begin -----\n");
  LLVM_DEBUG(llvm::dbgs() << "linalg a: " << a << "\n");
  LLVM_DEBUG(llvm::dbgs() << "linalg b: " << b << "\n");

  LLVM_DEBUG(llvm::dbgs() << "\ninitial status:\n");
  status.debug();

  if (!matchPayloadBlock()) {
    LLVM_DEBUG(llvm::dbgs() << "failed: payload block mismatch\n");
    return failure();
  }

  if (!matchLoopType()) {
    LLVM_DEBUG(llvm::dbgs() << "failed: loop type mismatch\n");
    return failure();
  }

  if (!matchPortType()) {
    LLVM_DEBUG(llvm::dbgs() << "failed: port type mismatch\n");
    return failure();
  }

  if (!matchPortMap()) {
    LLVM_DEBUG(llvm::dbgs() << "failed: port map mismatch\n");
    return failure();
  }

  if (!status.isConverged()) {
    LLVM_DEBUG(llvm::dbgs() << "failed: matching is not converged\n");
    return failure();
  }
  LLVM_DEBUG(llvm::dbgs() << "succeeded: ip matched!\n");
  return status.getConvergedMaps();
}

/// Match the payload blocks of "a" and "b" and update the matching status.
bool LinalgMatcher::matchPayloadBlock() {
  auto blockMatcher = BlockMatcher(a.getBlock(), b.getBlock());

  status.eraseArgMapIf([&](PermuteMap argMap) {
    for (auto i : llvm::enumerate(argMap))
      if (!blockMatcher.maybeEquivalent(a.getBlock()->getArgument(i.index()),
                                        b.getBlock()->getArgument(i.value())))
        return true;
    return false;
  });

  status.eraseResMapIf([&](PermuteMap resMap) {
    for (auto i : llvm::enumerate(resMap))
      if (!blockMatcher.maybeEquivalent(
              a.getBlock()->getTerminator()->getOperand(i.index()),
              b.getBlock()->getTerminator()->getOperand(i.value())))
        return true;
    return false;
  });

  LLVM_DEBUG(llvm::dbgs() << "\nstatus after payload block matching:\n");
  status.debug();
  return !status.isEmpty();
}

/// Match the loop types of "a" and "b" and update the matching status.
bool LinalgMatcher::matchLoopType() {
  status.eraseLoopMapIf([&](PermuteMap loopMap) {
    for (auto i : llvm::enumerate(loopMap))
      if (a.getIteratorTypesArray()[i.index()] !=
          b.getIteratorTypesArray()[i.value()])
        return true;
    return false;
  });

  LLVM_DEBUG(llvm::dbgs() << "\nstatus after loop type matching:\n");
  status.debug();
  return !status.isEmpty();
}

/// Match the port type of "a" and "b" and update the matching status.
bool LinalgMatcher::matchPortType() {
  status.eraseArgMapIf([&](PermuteMap argMap) {
    for (auto i : llvm::enumerate(argMap)) {
      auto typeA =
          a.getDpsInputOperand(i.index())->get().getType().cast<ShapedType>();
      auto typeB =
          b.getDpsInputOperand(i.value())->get().getType().cast<ShapedType>();
      if (!typeA.hasRank() || !typeB.hasRank() ||
          typeA.getRank() != typeB.getRank())
        return true;
    }
    return false;
  });

  status.eraseResMapIf([&](PermuteMap resMap) {
    for (auto i : llvm::enumerate(resMap)) {
      auto typeA =
          a.getDpsInitOperand(i.index())->get().getType().cast<ShapedType>();
      auto typeB =
          b.getDpsInitOperand(i.value())->get().getType().cast<ShapedType>();
      if (!typeA.hasRank() || !typeB.hasRank() ||
          typeA.getRank() != typeB.getRank())
        return true;
    }
    return false;
  });

  LLVM_DEBUG(llvm::dbgs() << "\nstatus after port type matching:\n");
  status.debug();
  return !status.isEmpty();
}

/// Match the port map of "a" and "b" and update the matching status.
bool LinalgMatcher::matchPortMap() {
  // A helper to check the equivalence of affine maps of linalg op "a" and "b".
  auto matchIndexingMaps = [&](PermuteMap loopMap, PermuteMap portMap,
                               unsigned portOffset) {
    // Permute the dimension order of the indexing maps of linalg op "a".
    auto affineMapsA = a.getIndexingMapsArray();
    for (auto &affineMapA : affineMapsA)
      affineMapA = affineMapA.compose(
          AffineMap::getPermutationMap(loopMap, a.getContext()));

    // Permute the result order of the indexing maps of linalg op "a".
    SmallVector<AffineMap> permutedAffineMapsA;
    SmallVector<AffineMap> affineMapsB;
    for (auto i : llvm::enumerate(portMap)) {
      permutedAffineMapsA.push_back(affineMapsA[i.value() + portOffset]);
      affineMapsB.push_back(b.getIndexingMapsArray()[i.index() + portOffset]);
    }
    return permutedAffineMapsA == affineMapsB;
  };

  // We first prune the invalid loop maps.
  status.eraseLoopMapIf([&](PermuteMap loopMap) {
    auto argMapListIsEmpty =
        llvm::all_of(status.getArgMapList(), [&](PermuteMap argMap) {
          return !matchIndexingMaps(loopMap, argMap, 0);
        });
    auto resMapListIsEmpty =
        llvm::all_of(status.getResMapList(), [&](PermuteMap resMap) {
          return !matchIndexingMaps(loopMap, resMap, a.getNumDpsInputs());
        });
    return argMapListIsEmpty || resMapListIsEmpty;
  });

  // Then, we prune the invalid argument and result maps.
  status.eraseArgMapIf([&](PermuteMap argMap) {
    return llvm::all_of(status.getLoopMapList(), [&](PermuteMap loopMap) {
      return !matchIndexingMaps(loopMap, argMap, 0);
    });
  });

  status.eraseResMapIf([&](PermuteMap resMap) {
    return llvm::all_of(status.getLoopMapList(), [&](PermuteMap loopMap) {
      return !matchIndexingMaps(loopMap, resMap, a.getNumDpsInputs());
    });
  });

  LLVM_DEBUG(llvm::dbgs() << "\nstatus after port map matching:\n");
  status.debug();
  return !status.isEmpty();
}
