//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLSCpp/HLSCpp.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct CreateTokenFlow : public CreateTokenFlowBase<CreateTokenFlow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);
    auto loc = builder.getUnknownLoc();

    for (auto node :
         llvm::make_early_inc_range(func.getOps<DataflowNodeOp>())) {
      auto output = node.getOutputOp();
      SmallVector<Value, 4> outputValues(output.getOperands());
      SmallVector<Value, 4> resultsToReplace(node.getResults());

      // Create token sources.
      for (auto result : node.getResults()) {
        if (!result.getType().isa<TensorType>())
          continue;
        builder.setInsertionPoint(output);
        auto token = builder.create<DataflowSourceOp>(loc, builder.getI1Type());
        outputValues.push_back(token);

        for (auto user : result.getUsers()) {
          builder.setInsertionPoint(user);
          builder.create<DataflowSinkOp>(loc, token);
        }
        resultsToReplace.push_back(token);
      }

      // Generate new output op.
      builder.setInsertionPoint(output);
      auto newOutput =
          builder.create<DataflowOutputOp>(output.getLoc(), outputValues);
      output.erase();

      // Generate new node op.
      builder.setInsertionPoint(node);
      auto newNode = builder.create<DataflowNodeOp>(
          node.getLoc(), newOutput.getOperandTypes());

      // Inline the body of the original node into the new node and replace used
      // if applicable.
      newNode.body().getBlocks().splice(newNode.body().end(),
                                        node.body().getBlocks());
      for (auto t : llvm::zip(resultsToReplace, newNode.getResults()))
        std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
          return !newNode->isProperAncestor(use.getOwner());
        });
      node.erase();
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateTokenFlowPass() {
  return std::make_unique<CreateTokenFlow>();
}
