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
    auto loc = b.getUnknownLoc();

    func.walk([&](ScheduleOp schedule) {
      if (!schedule.getIsLegal())
        return WalkResult::advance();

      SmallVector<Value> buffers;
      for (auto arg : schedule.getBody().getArguments())
        if (isExternalBuffer(arg))
          buffers.push_back(arg);
      for (auto bufferOp : schedule.getOps<BufferOp>())
        if (isExternalBuffer(bufferOp))
          buffers.push_back(bufferOp);

      for (auto buffer : buffers) {
        auto producers = getProducers(buffer);
        if (!llvm::hasSingleElement(producers))
          continue;

        auto producer = producers.front();
        auto outputIdx = llvm::find(producer.getOutputs(), buffer) -
                         producer.getOutputs().begin();
        SmallVector<Value, 8> outputs(producer.getOutputs());
        SmallVector<StreamOp, 4> tokens;

        auto consumers = getDependentConsumers(buffer, producer);
        if (consumers.empty())
          continue;

        for (auto consumer : consumers) {
          if (consumer == producer)
            continue;
          // Create new stream channel.
          auto levelDiff =
              producer.getLevel().value() - consumer.getLevel().value();
          b.setInsertionPointAfterValue(buffer);
          auto token = b.create<StreamOp>(
              loc, StreamType::get(b.getContext(), b.getI1Type(), levelDiff),
              levelDiff);
          tokens.push_back(token);

          // Add the stream channel as a new output argument of the producer.
          outputs.insert(std::next(outputs.begin(), outputIdx),
                         token.getChannel());
          auto tokenArg = producer.getBody().insertArgument(
              outputIdx++ + producer.getNumInputs(), token.getType(),
              token.getLoc());

          // Construct stream write on the producer side.
          b.setInsertionPointToEnd(&producer.getBody().front());
          auto value = b.create<arith::ConstantOp>(loc, b.getBoolAttr(true));
          b.create<StreamWriteOp>(loc, tokenArg, value);
        }

        // Construct a new producer node.
        b.setInsertionPoint(producer);
        auto newProducer =
            b.create<NodeOp>(producer.getLoc(), producer.getInputs(), outputs,
                             producer.getParams(), producer.getInputTapsAttr(),
                             producer.getLevelAttr());
        newProducer.getBody().getBlocks().splice(
            newProducer.getBody().end(), producer.getBody().getBlocks());
        producer.erase();

        for (auto t : llvm::zip(tokens, consumers)) {
          auto token = std::get<0>(t);
          auto consumer = std::get<1>(t);

          // Add the stream channel as a new input argument of the consumer.
          auto inputIdx = llvm::find(consumer.getInputs(), buffer) -
                          consumer.getInputs().begin();
          SmallVector<Value, 8> inputs(consumer.getInputs());
          SmallVector<unsigned> inputTaps(consumer.getInputTapsAsInt());

          inputs.insert(std::next(inputs.begin(), inputIdx),
                        token.getChannel());
          inputTaps.insert(std::next(inputTaps.begin(), inputIdx),
                           token.getType().getDepth() - 1);
          auto tokenArg = consumer.getBody().insertArgument(
              inputIdx, token.getType(), token.getLoc());

          // Construct stream write on the producer side.
          b.setInsertionPointToStart(&consumer.getBody().front());
          b.create<StreamReadOp>(loc, Type(), tokenArg);

          // Construct a new consumer node.
          b.setInsertionPoint(consumer);
          auto newConsumer = b.create<NodeOp>(
              consumer.getLoc(), inputs, consumer.getOutputs(),
              consumer.getParams(), inputTaps, consumer.getLevelAttr());
          newConsumer.getBody().getBlocks().splice(
              newConsumer.getBody().end(), consumer.getBody().getBlocks());
          consumer.erase();
        }
      }
      return WalkResult::advance();
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateTokenStreamPass() {
  return std::make_unique<CreateTokenStream>();
}
