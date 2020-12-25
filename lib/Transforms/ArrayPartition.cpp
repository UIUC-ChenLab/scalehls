//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Utils.h"
#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct ArrayPartition : public ArrayPartitionBase<ArrayPartition> {
  void runOnOperation() override;
};
} // namespace

static mlir::AffineForOp getPipelineLoop(mlir::AffineForOp root) {
  SmallVector<mlir::AffineForOp, 4> nestedLoops;
  root.walk([&](mlir::AffineForOp loop) {
    if (auto attr = loop.getAttrOfType<BoolAttr>("pipeline")) {
      if (attr.getValue())
        nestedLoops.push_back(loop);
    }
  });
  if (nestedLoops.empty())
    return nullptr;
  else
    return nestedLoops.back();
}

template <typename OpType>
static void applyArrayPartition(MemAccessesMap &map, OpBuilder &builder) {
  for (auto pair : map) {
    auto arrayOp = getArrayOp(pair.first);
    auto arrayShape = arrayOp.getShapedType().getShape();
    auto arrayAccesses = pair.second;

    // Walk through each dimension of the targeted array.
    SmallVector<Attribute, 4> partitionFactor;
    SmallVector<StringRef, 4> partitionType;
    unsigned partitionNum = 1;

    for (size_t dim = 0, e = arrayShape.size(); dim < e; ++dim) {
      // Collect all array access indices of the current dimension.
      SmallVector<AffineExpr, 4> indices;
      for (auto accessOp : arrayAccesses) {
        auto concreteOp = cast<OpType>(accessOp);
        auto index = concreteOp.getAffineMap().getResult(dim);
        // Only add unique index.
        if (std::find(indices.begin(), indices.end(), index) == indices.end())
          indices.push_back(index);
      }
      auto accessNum = indices.size();

      // Find the max array access distance in the current block.
      unsigned maxDistance = 0;
      bool failFlag = false;

      for (unsigned i = 0; i < accessNum; ++i) {
        for (unsigned j = i + 1; j < accessNum; ++j) {
          // TODO: this expression can't be simplified.
          auto expr = indices[j] - indices[i];

          if (auto constDistance = expr.dyn_cast<AffineConstantExpr>()) {
            unsigned distance = abs(constDistance.getValue());
            maxDistance = max(maxDistance, distance);
          } else {
            // failFlag = true;
            // break;
          }
        }
        // if (failFlag)
        //  break;
      }

      // Determine array partition strategy.
      maxDistance += 1;
      unsigned factor = 1;
      if (failFlag || maxDistance == 1) {
        // This means all accesses have the same index, and this dimension
        // should not be partitioned.
        partitionType.push_back("none");

      } else if (accessNum >= maxDistance) {
        // This means some elements are accessed more than once or exactly
        // once, and successive elements are accessed. In most cases,
        // apply "cyclic" partition should be the best solution.
        partitionType.push_back("cyclic");
        factor = maxDistance;

      } else {
        // This means discrete elements are accessed. Typically, "block"
        // partition will be most benefit for this occasion.
        partitionType.push_back("block");
        factor = accessNum;
      }

      partitionFactor.push_back(builder.getI64IntegerAttr(factor));
      partitionNum *= factor;
    }

    arrayOp.setAttr("partition", builder.getBoolAttr(true));
    arrayOp.setAttr("partition_type", builder.getStrArrayAttr(partitionType));
    arrayOp.setAttr("partition_factor", builder.getArrayAttr(partitionFactor));
    arrayOp.setAttr("partition_num", builder.getI64IntegerAttr(partitionNum));
  }
}

void ArrayPartition::runOnOperation() {
  auto func = getOperation();
  auto builder = OpBuilder(func);

  // Apply array partition.
  for (auto forOp : func.getOps<mlir::AffineForOp>()) {
    // TODO: support imperfect loop.
    if (auto outermost = getPipelineLoop(forOp)) {
      // Collect memory access information.
      MemAccessesMap loadMap;
      outermost.walk([&](mlir::AffineLoadOp loadOp) {
        loadMap[loadOp.getMemRef()].push_back(loadOp);
      });

      MemAccessesMap storeMap;
      outermost.walk([&](mlir::AffineStoreOp storeOp) {
        storeMap[storeOp.getMemRef()].push_back(storeOp);
      });

      // Apply array partition pragma.
      applyArrayPartition<mlir::AffineLoadOp>(loadMap, builder);
      applyArrayPartition<mlir::AffineStoreOp>(storeMap, builder);
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createArrayPartitionPass() {
  return std::make_unique<ArrayPartition>();
}
