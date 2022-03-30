//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ConvertDataflowToFunc
    : public ConvertDataflowToFuncBase<ConvertDataflowToFunc> {
  void runOnOperation() override {
    auto module = getOperation();
    auto builder = OpBuilder(module);
    auto loc = builder.getUnknownLoc();
    // TODO: Here we set the threshold of constant localization to a magic
    // number, which is the size of a Xilinx BRAM instance.
    localizeConstants(*module.getBody(), /*bitsThreshold=*/1024 * 16);

    for (auto func :
         llvm::make_early_inc_range(module.getOps<func::FuncOp>())) {
      // Hoist the memrefs and stream channels outputed by each node.
      for (auto node :
           llvm::make_early_inc_range(func.getOps<DataflowNodeOp>())) {
        auto output = node.getOutputOp();
        for (auto &use : output->getOpOperands()) {
          if (!use.get().getType().isa<MemRefType, StreamType>()) {
            output.emitOpError("dataflow output has not been bufferized");
            return signalPassFailure();
          }

          if (auto defOp = use.get().getDefiningOp())
            if (node->isAncestor(defOp))
              defOp->moveBefore(node);
          node.getResult(use.getOperandNumber()).replaceAllUsesWith(use.get());
        }
      }

      auto liveness = Liveness(func);
      unsigned nodeIdx = 0;
      for (auto node :
           llvm::make_early_inc_range(func.getOps<DataflowNodeOp>())) {
        // Analyze the input values and types of the function to create.
        SmallVector<Value, 8> inputs;
        SmallVector<Type, 8> inputTypes;
        for (auto livein : liveness.getLiveIn(node.getBody())) {
          if (node->isAncestor(livein.getParentBlock()->getParentOp()))
            continue;
          inputs.push_back(livein);
          inputTypes.push_back(livein.getType());
        }

        // Create a new sub-function.
        builder.setInsertionPoint(func);
        auto subFunc = builder.create<func::FuncOp>(
            loc, func.getName().str() + "_node" + std::to_string(nodeIdx++),
            builder.getFunctionType(inputTypes, TypeRange()));

        // Create entry block and return operation.
        auto entry = subFunc.addEntryBlock();
        for (auto t : llvm::zip(inputs, entry->getArguments()))
          std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
            return node->isAncestor(use.getOwner());
          });
        builder.setInsertionPointToEnd(entry);
        builder.create<func::ReturnOp>(loc);

        // Inline the contents of the dataflow node.
        auto &subFuncOps = entry->getOperations();
        auto &nodeOps = node.getBody()->getOperations();
        subFuncOps.splice(subFuncOps.begin(), nodeOps, nodeOps.begin(),
                          std::prev(nodeOps.end()));

        // Create a function call to replace the original node.
        builder.setInsertionPoint(node);
        builder.create<func::CallOp>(node.getLoc(), subFunc, inputs);
        node.erase();
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createConvertDataflowToFuncPass() {
  return std::make_unique<ConvertDataflowToFunc>();
}
