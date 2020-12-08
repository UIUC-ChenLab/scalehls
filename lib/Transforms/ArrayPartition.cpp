//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Transforms/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/IR/Builders.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Transforms/LoopUtils.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct ArrayPartition : public ArrayPartitionBase<ArrayPartition> {
  void runOnOperation() override;
};
} // namespace

void ArrayPartition::runOnOperation() {
  auto module = getOperation();
  auto builder = OpBuilder(module);

  // Extract all static parameters and current pragma configurations.
  HLSCppAnalyzer analyzer(builder);
  analyzer.analyzeModule(getOperation());

  // Canonicalize the analyzed IR.
  OwningRewritePatternList patterns;

  auto *context = &getContext();
  for (auto *op : context->getRegisteredOperations())
    op->getCanonicalizationPatterns(patterns, context);

  Operation *op = getOperation();
  applyPatternsAndFoldGreedily(op->getRegions(), std::move(patterns));

  // Estimate performance and resource utilization.
  for (auto func : module.getOps<FuncOp>()) {
    for (auto forOp : func.getOps<mlir::AffineForOp>()) {
      // TODO: support imperfect loop nests.
      SmallVector<mlir::AffineForOp, 4> nestedLoops;
      getPerfectlyNestedLoops(nestedLoops, forOp);
      auto innermost = nestedLoops.back();

      // Collect memory access information.
      MemAccessDict loadDict;
      innermost.walk([&](mlir::AffineLoadOp loadOp) {
        auto arrayOp = cast<ArrayOp>(loadOp.getMemRef().getDefiningOp());
        loadDict[arrayOp].push_back(loadOp);
      });

      MemAccessDict storeDict;
      innermost.walk([&](mlir::AffineStoreOp storeOp) {
        auto arrayOp = cast<ArrayOp>(storeOp.getMemRef().getDefiningOp());
        storeDict[arrayOp].push_back(storeOp);
      });

      // Apply array partition pragma.
      for (auto pair : loadDict) {
        auto arrayOp = cast<ArrayOp>(pair.first);
        auto arrayType = arrayOp.getType().cast<MemRefType>();
        auto arrayAccesses = pair.second;

        // Walk through each dimension of the targeted array.
        SmallVector<Attribute, 4> partitionFactor;
        SmallVector<StringRef, 4> partitionType;

        for (size_t dim = 0, e = arrayType.getShape().size(); dim < e; ++dim) {
          unsigned dimSize = arrayType.getShape()[dim];

          // Collect all array access indices of the current dimension.
          SmallVector<AffineExpr, 4> indices;
          for (auto accessOp : arrayAccesses) {
            auto concreteOp = cast<mlir::AffineLoadOp>(accessOp);
            auto index = concreteOp.getAffineMap().getResult(dim);
            // Only add unique index.
            if (std::find(indices.begin(), indices.end(), index) ==
                indices.end())
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
                // The array partition mechanism will fail if the distance is
                // not a constant number.
                // failFlag = true;
                // break;
              }
            }
            // if (failFlag)
            //  break;
          }

          // Determine array partition strategy.
          maxDistance += 1;
          if (failFlag || maxDistance == 1) {
            // This means all accesses have the same index, and this dimension
            // should not be partitioned.
            partitionType.push_back("none");
            partitionFactor.push_back(builder.getUI32IntegerAttr(1));

          } else if (accessNum == dimSize) {
            // Apply complete array partition.
            partitionType.push_back("complete");
            partitionFactor.push_back(builder.getUI32IntegerAttr(1));

          } else if (accessNum >= maxDistance) {
            // This means some elements are accessed more than once or exactly
            // once, and successive elements are accessed. In most cases, apply
            // "cyclic" partition should be the best solution.
            partitionType.push_back("cyclic");
            partitionFactor.push_back(builder.getUI32IntegerAttr(maxDistance));

          } else {
            // This means discrete elements are accessed. Typically, "block"
            // partition will be most benefit for this occasion.
            partitionType.push_back("block");
            partitionFactor.push_back(builder.getUI32IntegerAttr(accessNum));
          }
        }

        arrayOp.setAttr("partition", builder.getBoolAttr(true));
        arrayOp.setAttr("partition_type",
                        builder.getStrArrayAttr(partitionType));
        arrayOp.setAttr("partition_factor",
                        builder.getArrayAttr(partitionFactor));
      }
    }
  }
}

std::unique_ptr<mlir::Pass> scalehls::createArrayPartitionPass() {
  return std::make_unique<ArrayPartition>();
}
