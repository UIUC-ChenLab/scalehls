//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_ANALYSIS_H
#define SCALEHLS_DIALECT_HLS_ANALYSIS_H

#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Dialect/HLS/Utils.h"

namespace mlir {
namespace scalehls {

using namespace hls;

/// Node and Schedule complexity analysis.
class ComplexityAnalysis {
public:
  ComplexityAnalysis(func::FuncOp func);

  Optional<unsigned long> getScheduleComplexity(ScheduleOp schedule) const;
  Optional<unsigned long> getNodeComplexity(NodeOp node) const;

private:
  Optional<unsigned long> calculateBlockComplexity(Block *block) const;
  llvm::SmallDenseMap<NodeOp, unsigned long> nodeComplexityMap;
};

/// TODO: Support dataflow node with multiple loops.
/// Record a pair of correlated node.
class Correlation {
public:
  Correlation(NodeOp sourceNode, NodeOp targetNode,
              hls::BufferLikeInterface buffer,
              SmallVector<int64_t> sourceToTargetMap,
              SmallVector<int64_t> targetToSourceMap)
      : sourceNode(sourceNode), targetNode(targetNode), buffer(buffer),
        sourceToTargetMap(sourceToTargetMap),
        targetToSourceMap(targetToSourceMap) {
    // Make sure the source-to-target and target-to-source map is valid.
    if (!sourceToTargetMap.empty()) {
      assert(getNodeLoopBand(targetNode).size() == sourceToTargetMap.size() &&
             "invalid source-to-target map size");

      for (auto i : llvm::enumerate(sourceToTargetMap))
        if (i.value() >= 0 && i.value() < (int64_t)targetToSourceMap.size())
          assert((int64_t)i.index() == targetToSourceMap[i.value()] &&
                 "mismatched source-to-target map");
        else if (i.value() != -1)
          assert("invalid source-to-target map");
    }

    if (!targetToSourceMap.empty()) {
      assert(getNodeLoopBand(sourceNode).size() == targetToSourceMap.size() &&
             "invalid target-to-source map size");

      for (auto i : llvm::enumerate(targetToSourceMap))
        if (i.value() >= 0 && i.value() < (int64_t)sourceToTargetMap.size())
          assert((int64_t)i.index() == sourceToTargetMap[i.value()] &&
                 "mismatched target-to-source map");
        else if (i.value() != -1)
          assert("invalid target-to-source map");
    }
  }

  /// Get the shared buffer.
  hls::BufferLikeInterface getBuffer() const { return buffer; }

  /// Check whether a node is source node.
  bool isSourceNode(NodeOp currentNode) const {
    assert(currentNode == sourceNode ||
           currentNode == targetNode && "invalid input node");
    return currentNode == sourceNode;
  }

  // Get the correlated node of the current node.
  NodeOp getCorrelatedNode(NodeOp currentNode) const {
    return isSourceNode(currentNode) ? sourceNode : targetNode;
  }

  // Permute factors of the current node to the correlated node.
  SmallVector<unsigned> permuteFactors(NodeOp currentNode,
                                       SmallVector<unsigned> factors) {
    assert(factors.size() == getNodeLoopBand(currentNode).size() &&
           "invalid permutation factors");
    if (isSourceNode(currentNode))
      return permuteFactorsWithMap(factors, sourceToTargetMap);
    else
      return permuteFactorsWithMap(factors, targetToSourceMap);
  }

private:
  /// Permute "factors" with "map" and return the permuted factors. Note that
  /// "-1" in the permutation map indicates the output factor on the
  /// corresponding position is one.
  SmallVector<unsigned> permuteFactorsWithMap(SmallVector<unsigned> factors,
                                              SmallVector<int64_t> map) const {
    SmallVector<unsigned> permutedFactors;
    for (auto i : map) {
      if (i >= 0 && i < (int64_t)factors.size())
        permutedFactors.push_back(factors[i]);
      else if (i == -1)
        permutedFactors.push_back(1);
      else
        llvm_unreachable("invalid factors or map");
    }
    return permutedFactors;
  }

  NodeOp sourceNode;
  NodeOp targetNode;
  hls::BufferLikeInterface buffer;
  SmallVector<int64_t> sourceToTargetMap;
  SmallVector<int64_t> targetToSourceMap;
};

/// Correlations analysis between dataflow nodes.
class CorrelationAnalysis {
  using CorrelationList = SmallVector<Correlation *, 4>;

public:
  CorrelationAnalysis(func::FuncOp func);

  CorrelationList getCorrelations(NodeOp node) const {
    return nodeCorrelationMap.lookup(node);
  }

  auto begin() { return nodeCorrelationMap.begin(); }
  auto end() { return nodeCorrelationMap.end(); }

private:
  SmallVector<Correlation> correlations;
  llvm::SmallDenseMap<NodeOp, CorrelationList> nodeCorrelationMap;
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLS_ANALYSIS_H
