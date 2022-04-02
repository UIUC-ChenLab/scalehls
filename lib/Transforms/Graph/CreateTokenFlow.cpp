//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "scalehls/Transforms/Dataflower.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct CreateTokenFlow : public CreateTokenFlowBase<CreateTokenFlow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto rewriter = ScaleHLSDataflower(func.front());
    auto loc = rewriter.getUnknownLoc();

    for (auto node :
         llvm::make_early_inc_range(func.getOps<DataflowNodeOp>())) {
      // Collect consumers of the current node. For each consumer, we only need
      // to create one token flow.
      llvm::SmallDenseSet<Operation *, 4> consumers;
      for (auto &use : llvm::make_early_inc_range(node->getUses())) {
        // Skip non-tensor and terminator users.
        if (isa<DataflowBufferOp>(use.getOwner()) ||
            !use.get().getType().isa<TensorType>() ||
            use.getOwner() == use.getOwner()->getBlock()->getTerminator())
          continue;

        auto consumer = use.getOwner()->getParentOfType<DataflowNodeOp>();
        assert(consumer && "must have dataflow node parent");
        consumers.insert(consumer);
      }

      // Create token source and sink operations.
      SmallVector<Operation *, 4> opsToFuse({node});
      for (auto consumer : consumers) {
        rewriter.setInsertionPointAfter(node);
        auto token =
            rewriter.create<DataflowSourceOp>(loc, rewriter.getI1Type());
        opsToFuse.push_back(token);

        rewriter.setInsertionPointToStart(
            &cast<DataflowNodeOp>(consumer).body().front());
        rewriter.create<DataflowSinkOp>(loc, token);
      }

      // Fuse the source operations and original dataflow node.
      fuseOpsIntoNewNode(opsToFuse, rewriter);
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateTokenFlowPass() {
  return std::make_unique<CreateTokenFlow>();
}
