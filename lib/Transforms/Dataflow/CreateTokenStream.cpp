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
    OpBuilder b(context);

    auto schedule = *func.getOps<ScheduleOp>().begin();
    auto loc = b.getUnknownLoc();

    for (auto buffer : schedule.getOps<BufferOp>()) {
      auto producers = getProducersInSchedule(buffer, schedule);
      auto consumers = getConsumersInSchedule(buffer, schedule);
      if (producers.empty() || consumers.empty())
        continue;

      b.setInsertionPointAfter(buffer);
      auto token = b.create<StreamOp>(
          loc, StreamType::get(b.getContext(), b.getI1Type(), 1));

      for (auto node : producers) {
        auto outputIdx = llvm::find(node.getOutputs(), buffer.getMemref()) -
                         node.getOutputs().begin();
        SmallVector<Value, 8> outputs(node.getOutputs());
        outputs.insert(std::next(outputs.begin(), outputIdx),
                       token.getChannel());

        b.setInsertionPoint(node);
        auto newNode =
            b.create<NodeOp>(node.getLoc(), node.getInputs(), outputs,
                             node.getParams(), node.getLevelAttr());
        newNode.getBody().getBlocks().splice(newNode.getBody().end(),
                                             node.getBody().getBlocks());
        node.erase();
        auto tokenArg =
            newNode.getBody().insertArgument(outputIdx + newNode.getNumInputs(),
                                             token.getType(), token.getLoc());

        b.setInsertionPointToEnd(&newNode.getBody().front());
        auto value = b.create<arith::ConstantOp>(loc, b.getBoolAttr(true));
        b.create<StreamWriteOp>(loc, tokenArg, value);
      }

      for (auto node : consumers) {
        auto inputIdx = llvm::find(node.getInputs(), buffer.getMemref()) -
                        node.getInputs().begin();
        SmallVector<Value, 8> inputs(node.getInputs());
        inputs.insert(std::next(inputs.begin(), inputIdx), token.getChannel());

        b.setInsertionPoint(node);
        auto newNode =
            b.create<NodeOp>(node.getLoc(), inputs, node.getOutputs(),
                             node.getParams(), node.getLevelAttr());
        newNode.getBody().getBlocks().splice(newNode.getBody().end(),
                                             node.getBody().getBlocks());
        node.erase();
        auto tokenArg = newNode.getBody().insertArgument(
            inputIdx, token.getType(), token.getLoc());

        b.setInsertionPointToStart(&newNode.getBody().front());
        b.create<StreamReadOp>(loc, Type(), tokenArg);
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateTokenStreamPass() {
  return std::make_unique<CreateTokenStream>();
}
