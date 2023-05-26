//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_UTILS_MATCHERS_H
#define SCALEHLS_UTILS_MATCHERS_H

#include "scalehls/Utils/Utils.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "scalehls-matchers"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// BlockMatcher
//===----------------------------------------------------------------------===//

/// Map from a value of a dataflow to a set of possible equivalent values of
/// another dataflow.
using EquivalentValuesMap =
    llvm::SmallDenseMap<Value, llvm::SmallDenseSet<Value>>;

struct BlockMatcher {
  BlockMatcher(Block *blockA, Block *blockB) : blockA(blockA), blockB(blockB) {
    // We traverse the "blockA" and "blockB" in post order to initialize a "map"
    // from a value in "blockA" to a set of maybe equivalent values in "blockB".
    for (auto resA : blockA->getTerminator()->getOperands())
      for (auto resB : blockB->getTerminator()->getOperands())
        checkEquivalence(resA, resB);

    // Argument may not be used at all. In this case, the post order traverse
    // will not identify the possible equivalences. We need to check them
    // manually.
    for (auto argA : blockA->getArguments())
      for (auto argB : blockB->getArguments())
        if (argA.use_empty() && argB.use_empty())
          checkEquivalence(argA, argB);
  }

  /// Check whether value a and b may be equivalent.
  bool maybeEquivalent(Value a, Value b) const {
    assert(a.getParentBlock() == blockA && b.getParentBlock() == blockB &&
           "invalid value a and b");
    return map.lookup(a).count(b);
  }

private:
  /// A helper that recursively check the equivalence between two values and
  /// record the checking result in "map". For now, we don't consider
  /// associativity in the current implementation.
  bool checkEquivalence(Value a, Value b);

  Block *blockA;
  Block *blockB;

  /// Hold the equivalent value mapping between the two blocks.
  EquivalentValuesMap map;
};

//===----------------------------------------------------------------------===//
// LinalgMatcher
//===----------------------------------------------------------------------===//

/// Permuatation map from an index (input/output/index) of a LinalgOp to the
/// equivalent index of another LinalgOp.
using PermuteMap = SmallVector<unsigned>;
using PermuteMapList = SmallVector<PermuteMap>;
using LinalgMatchingResult = std::tuple<PermuteMap, PermuteMap, PermuteMap>;

/// Status of LinalgOp matching that records the equivalent indices maps of
/// arguments, results, and loops.
struct LinalgMatchingStatus {
  /// Initialize the lists with all possible permutations.
  LinalgMatchingStatus(linalg::LinalgOp a, linalg::LinalgOp b) {
    assert(a.getNumDpsInputs() == b.getNumDpsInputs() &&
           a.getNumDpsInits() == b.getNumDpsInits() &&
           a.getNumLoops() == b.getNumLoops() && "invalid linalg op a and b");

    auto argMap = llvm::to_vector(llvm::seq<unsigned>(0, a.getNumDpsInputs()));
    do {
      argMapList.push_back(argMap);
    } while (std::next_permutation(argMap.begin(), argMap.end()));

    auto resMap = llvm::to_vector(llvm::seq<unsigned>(0, a.getNumDpsInits()));
    do {
      resMapList.push_back(resMap);
    } while (std::next_permutation(resMap.begin(), resMap.end()));

    auto loopMap = llvm::to_vector(llvm::seq<unsigned>(0, a.getNumLoops()));
    do {
      loopMapList.push_back(loopMap);
    } while (std::next_permutation(loopMap.begin(), loopMap.end()));
  }

  /// Check whether the matching status is valid.
  bool isEmpty() const {
    return argMapList.empty() || resMapList.empty() || loopMapList.empty();
  }

  /// Check whether the matching status is converged.
  bool isConverged() const {
    return argMapList.size() == 1 && resMapList.size() == 1 &&
           loopMapList.size() == 1;
  }

  /// Erase the argument permutation maps from the matching status if the given
  /// predicate is true.
  void eraseArgMapIf(llvm::function_ref<bool(PermuteMap)> pred) {
    llvm::erase_if(argMapList, [&](PermuteMap argMap) { return pred(argMap); });
  }

  /// Erase the result permutation maps from the matching status if the given
  /// predicate is true.
  void eraseResMapIf(llvm::function_ref<bool(PermuteMap)> pred) {
    llvm::erase_if(resMapList, [&](PermuteMap resMap) { return pred(resMap); });
  }

  /// Erase the loop permutation maps from the matching status if the given
  /// predicate is true.
  void eraseLoopMapIf(llvm::function_ref<bool(PermuteMap)> pred) {
    llvm::erase_if(loopMapList,
                   [&](PermuteMap loopMap) { return pred(loopMap); });
  }

  PermuteMapList getArgMapList() const { return argMapList; }
  PermuteMapList getResMapList() const { return resMapList; }
  PermuteMapList getLoopMapList() const { return loopMapList; }

  /// Get the permutation maps from the matching status. Return failure if the
  /// matching status is not converged.
  FailureOr<LinalgMatchingResult> getConvergedMaps() const {
    if (!isConverged())
      return failure();
    return std::make_tuple(argMapList.front(), resMapList.front(),
                           loopMapList.front());
  }

  /// Check whether the matching status is valid.
  void debug() const {
    LLVM_DEBUG(llvm::dbgs() << "Argument permutation maps:\n");
    for (auto argMap : argMapList) {
      for (auto index : argMap)
        LLVM_DEBUG(llvm::dbgs() << index << " ");
      LLVM_DEBUG(llvm::dbgs() << "\n");
    }
    LLVM_DEBUG(llvm::dbgs() << "Result permutation maps:\n");
    for (auto resMap : resMapList) {
      for (auto index : resMap)
        LLVM_DEBUG(llvm::dbgs() << index << " ");
      LLVM_DEBUG(llvm::dbgs() << "\n");
    }
    LLVM_DEBUG(llvm::dbgs() << "Loop permutation maps:\n");
    for (auto loopMap : loopMapList) {
      for (auto index : loopMap)
        LLVM_DEBUG(llvm::dbgs() << index << " ");
      LLVM_DEBUG(llvm::dbgs() << "\n");
    }
  }

private:
  PermuteMapList argMapList;
  PermuteMapList resMapList;
  PermuteMapList loopMapList;
};

struct LinalgMatcher {
  LinalgMatcher(linalg::LinalgOp a, linalg::LinalgOp b)
      : a(a), b(b), status(a, b) {}

  /// Match linalg operations "a" and "b". Return the matching results if the
  /// matching is successful. Otherwise, return a failure.
  FailureOr<LinalgMatchingResult> match();

private:
  /// Match the payload blocks of "a" and "b" and update the matching status.
  bool matchPayloadBlock();

  /// Match the loop types of "a" and "b" and update the matching status.
  bool matchLoopType();

  /// Match the port type of "a" and "b" and update the matching status.
  bool matchPortType();

  /// Match the port map of "a" and "b" and update the matching status.
  bool matchPortMap();

  linalg::LinalgOp a;
  linalg::LinalgOp b;
  LinalgMatchingStatus status;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_UTILS_MATCHERS_H
