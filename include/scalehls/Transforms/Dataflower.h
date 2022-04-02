//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_DATAFLOWER_H
#define SCALEHLS_TRANSFORMS_DATAFLOWER_H

#include "scalehls/Transforms/Utils.h"

namespace mlir {
namespace scalehls {

using namespace hls;

class ScaleHLSDataflower : public PatternRewriter {
public:
  ScaleHLSDataflower(Block &block)
      : PatternRewriter(block.getParentOp()->getContext()), block(block) {}

  /// Wrap operations in the block into dataflow nodes based on heuristic if
  /// they have not and identify the dependencies between dataflow nodes.
  LogicalResult initializeDataflow();

  /// Legalize the dataflow creating a one-way feed-forward dataflow path
  /// without bypass paths.
  LogicalResult legalizeDataflow();

private:
  Block &block;

  /// Mapping from dataflow node to its dataflow level.
  llvm::SmallDenseMap<Operation *, unsigned, 64> dataflowLevelMap;

  /// Get the dataflow level of an operation.
  unsigned getDataflowLevel(Operation *op) const;

  /// A dataflow use is similar to the concept of OpOperand in the SSA graph,
  /// which includes the intermediate value and the dataflow node user.
  using DataflowUse = std::pair<Value, DataflowNodeOp>;
  using DataflowUses = SmallVector<DataflowUse, 4>;

  /// A mapping from a dataflow node to all its uses.
  llvm::SmallDenseMap<Operation *, DataflowUses, 64> dataflowUsesMap;

  /// Update the dataflow uses map. Everytime the dataflow node ops in the block
  /// are manipulated, this method need to be called again.
  void updateDataflowUsesMap();

  DataflowUses getNodeUses(DataflowNodeOp node) const {
    return dataflowUsesMap.lookup(node);
  }
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_DATAFLOWER_H