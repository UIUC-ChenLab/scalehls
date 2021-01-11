//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Transforms/Passes.h"
#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct ArrayPartition : public ArrayPartitionBase<ArrayPartition> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    applyArrayPartition(func, builder);
  }
};
} // namespace

bool scalehls::applyArrayPartition(FuncOp func, OpBuilder &builder) {
  // Check whether the input function is pipelined.
  bool funcPipeline = false;
  if (auto attr = func.getAttrOfType<BoolAttr>("pipeline"))
    if (attr.getValue())
      funcPipeline = true;

  // Only memory accesses in pipelined loops or function will be executed in
  // parallel and required to partition.
  SmallVector<Block *, 4> pipelinedBlocks;
  if (funcPipeline)
    pipelinedBlocks.push_back(&func.front());
  else
    func.walk([&](AffineForOp loop) {
      if (auto attr = loop.getAttrOfType<BoolAttr>("pipeline"))
        if (attr.getValue())
          pipelinedBlocks.push_back(&loop.getLoopBody().front());
    });

  // Storing the partition information of each memref.
  using PartitionInfo = std::pair<PartitionKind, int64_t>;
  DenseMap<Value, SmallVector<PartitionInfo, 4>> partitionsMap;

  // Traverse all pipelined loops.
  for (auto block : pipelinedBlocks) {
    MemAccessesMap accessesMap;
    getMemAccessesMap(*block, accessesMap);

    for (auto pair : accessesMap) {
      auto memref = pair.first;
      auto memrefType = memref.getType().cast<MemRefType>();
      auto loadStores = pair.second;
      auto &partitions = partitionsMap[memref];

      // If the current partitionsMap is empty, initialize it with no partition
      // and factor of 1.
      if (partitions.empty()) {
        for (int64_t dim = 0; dim < memrefType.getRank(); ++dim)
          partitions.push_back(PartitionInfo(PartitionKind::NONE, 1));
      }

      // Find the best partition solution for each dimensions of the memref.
      for (int64_t dim = 0; dim < memrefType.getRank(); ++dim) {
        // Collect all array access indices of the current dimension.
        SmallVector<AffineExpr, 4> indices;
        for (auto accessOp : loadStores) {
          // Get memory access map.
          AffineValueMap accessMap;
          MemRefAccess(accessOp).getAccessMap(&accessMap);

          // Get index expression.
          auto index = accessMap.getResult(dim);

          // Only add unique index.
          if (std::find(indices.begin(), indices.end(), index) == indices.end())
            indices.push_back(index);
        }
        auto accessNum = indices.size();

        // Find the max array access distance in the current block.
        unsigned maxDistance = 0;

        for (unsigned i = 0; i < accessNum; ++i) {
          for (unsigned j = i + 1; j < accessNum; ++j) {
            // TODO: this expression can't be simplified in some cases.
            auto expr = indices[j] - indices[i];

            if (auto constDistance = expr.dyn_cast<AffineConstantExpr>()) {
              unsigned distance = abs(constDistance.getValue());
              maxDistance = max(maxDistance, distance);
            }
          }
        }

        // Determine array partition strategy.
        // TODO: take storage type into consideration.
        maxDistance += 1;
        if (maxDistance == 1) {
          // This means all accesses have the same index, and this dimension
          // should not be partitioned.
          continue;

        } else if (accessNum >= maxDistance) {
          // This means some elements are accessed more than once or exactly
          // once, and successive elements are accessed. In most cases, apply
          // "cyclic" partition should be the best solution.
          unsigned factor = maxDistance;
          if (factor > partitions[dim].second)
            partitions[dim] = PartitionInfo(PartitionKind::CYCLIC, factor);

        } else {
          // This means discrete elements are accessed. Typically, "block"
          // partition will be most benefit for this occasion.
          unsigned factor = accessNum;
          if (factor > partitions[dim].second)
            partitions[dim] = PartitionInfo(PartitionKind::BLOCK, factor);
        }
      }
    }
  }

  // Constuct and set new type to each partitioned MemRefType.
  for (auto pair : partitionsMap) {
    auto memref = pair.first;
    auto memrefType = memref.getType().cast<MemRefType>();
    auto partitions = pair.second;

    // Walk through each dimension of the current memory.
    SmallVector<AffineExpr, 4> partitionIndices;
    SmallVector<AffineExpr, 4> addressIndices;

    for (int64_t dim = 0; dim < memrefType.getRank(); ++dim) {
      auto partition = partitions[dim];
      auto kind = partition.first;
      auto factor = partition.second;

      if (kind == PartitionKind::CYCLIC) {
        partitionIndices.push_back(builder.getAffineDimExpr(dim) % factor);
        addressIndices.push_back(
            builder.getAffineDimExpr(dim).floorDiv(factor));

      } else if (kind == PartitionKind::BLOCK) {
        auto blockFactor = (memrefType.getShape()[dim] + factor - 1) / factor;
        partitionIndices.push_back(
            builder.getAffineDimExpr(dim).floorDiv(blockFactor));
        addressIndices.push_back(builder.getAffineDimExpr(dim) % blockFactor);

      } else {
        partitionIndices.push_back(builder.getAffineConstantExpr(0));
        addressIndices.push_back(builder.getAffineDimExpr(dim));
      }
    }

    // Construct new layout map.
    partitionIndices.append(addressIndices.begin(), addressIndices.end());
    auto layoutMap = AffineMap::get(memrefType.getRank(), 0, partitionIndices,
                                    builder.getContext());

    // Construct new memref type.
    auto newType =
        MemRefType::get(memrefType.getShape(), memrefType.getElementType(),
                        layoutMap, memrefType.getMemorySpace());

    // Set new type.
    memref.setType(newType);
  }

  // Align function type with entry block argument types.
  auto resultTypes = func.front().getTerminator()->getOperandTypes();
  auto inputTypes = func.front().getArgumentTypes();
  func.setType(builder.getFunctionType(inputTypes, resultTypes));

  // TODO: how to handle the case when different sub-functions have different
  // array partition strategy selected?
  return true;
}

std::unique_ptr<mlir::Pass> scalehls::createArrayPartitionPass() {
  return std::make_unique<ArrayPartition>();
}
