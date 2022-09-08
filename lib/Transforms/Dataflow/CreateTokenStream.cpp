//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct CreateTokenStream : public CreateTokenStreamBase<CreateTokenStream> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();
    auto b = OpBuilder(context);

    // TODO: Use pattern matcher.
    for (auto buffer : func.getOps<BufferOp>()) {
      if (buffer.getProducers().empty() || buffer.getConsumers().empty())
        continue;

      b.setInsertionPointAfter(buffer);
      auto token = b.create<StreamOp>(
          b.getUnknownLoc(),
          StreamType::get(b.getContext(), b.getI1Type(), /*depth=*/1),
          /*depth=*/1);

      for (auto node : buffer.getProducers()) {
        auto outputIdx = llvm::find(node.outputs(), buffer.memref()) -
                         node.outputs().begin();
        SmallVector<Value, 8> outputs(node.outputs());
        outputs.insert(std::next(outputs.begin(), outputIdx), token.channel());

        b.setInsertionPoint(node);
        auto newNode = b.create<NodeOp>(node.getLoc(), node.inputs(), outputs);
        newNode.body().getBlocks().splice(newNode.body().end(),
                                          node.body().getBlocks());
        node.erase();
        auto tokenArg = newNode.getBody()->insertArgument(
            outputIdx + newNode.getNumInputs(), token.getType(),
            token.getLoc());

        b.setInsertionPointToEnd(newNode.getBody());
        auto value =
            b.create<arith::ConstantOp>(b.getUnknownLoc(), b.getBoolAttr(true));
        b.create<StreamWriteOp>(b.getUnknownLoc(), tokenArg, value);
      }

      for (auto node : buffer.getConsumers()) {
        auto inputIdx =
            llvm::find(node.inputs(), buffer.memref()) - node.inputs().begin();
        SmallVector<Value, 8> inputs(node.inputs());
        inputs.insert(std::next(inputs.begin(), inputIdx), token.channel());

        b.setInsertionPoint(node);
        auto newNode = b.create<NodeOp>(node.getLoc(), inputs, node.outputs());
        newNode.body().getBlocks().splice(newNode.body().end(),
                                          node.body().getBlocks());
        node.erase();
        auto tokenArg = newNode.getBody()->insertArgument(
            inputIdx, token.getType(), token.getLoc());

        b.setInsertionPointToStart(newNode.getBody());
        b.create<StreamReadOp>(b.getUnknownLoc(), Type(), tokenArg);
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateTokenStreamPass() {
  return std::make_unique<CreateTokenStream>();
}
