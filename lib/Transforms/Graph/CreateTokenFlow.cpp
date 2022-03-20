//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct CreateTokenFlow : public CreateTokenFlowBase<CreateTokenFlow> {
  void runOnOperation() override {
    auto module = getOperation();
    auto builder = OpBuilder(module);
    auto context = module.getContext();
    auto loc = builder.getUnknownLoc();

    // Token is boolean stream typed.
    auto tokenType = hlscpp::StreamType::get(context, builder.getI1Type(), 1);

    // Mapping from each consumer to all of its input streams. The key here must
    // be func::CallOp.
    llvm::SmallDenseMap<Operation *, SmallVector<Value, 4>, 32> streamsMap;

    SmallVector<func::CallOp, 4> callsToErase;
    auto walkResult = module.walk([&](func::CallOp call) {
      auto func = module.lookupSymbol<FuncOp>(call.getCallee());
      auto returnOp = func.back().getTerminator();

      SmallVector<Value, 4> inputs(call.getOperands());
      SmallVector<Type, 4> inputTypes(call.getOperandTypes());
      for (auto stream : streamsMap.lookup(call)) {
        auto arg = func.front().addArgument(stream.getType(), loc);
        builder.setInsertionPointToStart(&func.front());
        builder.create<hlscpp::StreamReadOp>(loc, Type(), arg);

        inputs.push_back(stream);
        inputTypes.push_back(stream.getType());
      }

      SmallVector<std::pair<Operation *, unsigned>> consumerAndChannels;
      SmallVector<Value, 4> outputs(returnOp->getOperands());
      SmallVector<Type, 4> outputTypes(returnOp->getOperandTypes());
      for (auto result : call.getResults()) {
        if (!result.getType().isa<TensorType>() || result.use_empty())
          continue;

        // Create a new token stream channel.
        builder.setInsertionPoint(returnOp);
        auto channel = builder.create<hlscpp::StreamChannelOp>(loc, tokenType);
        auto tokenValue =
            builder.create<arith::ConstantOp>(loc, builder.getBoolAttr(false));
        builder.create<hlscpp::StreamWriteOp>(loc, channel, tokenValue);

        // Collect the users of the stream channel.
        for (auto user : result.getUsers()) {
          if (isa<func::CallOp>(user))
            consumerAndChannels.push_back({user, outputs.size()});
          else if (!isa<func::ReturnOp>(user))
            return user->emitOpError("only support call user"),
                   WalkResult::interrupt();
        }
        outputs.push_back(channel);
        outputTypes.push_back(tokenType);
      }

      // First, update the function type.
      func.setType(builder.getFunctionType(inputTypes, outputTypes));

      // Then, update the return op with new outputs.
      builder.setInsertionPoint(returnOp);
      builder.create<func::ReturnOp>(loc, outputs);
      returnOp->erase();

      // Thirdly, update the call op with inputs and callee type.
      builder.setInsertionPoint(call);
      auto newCall = builder.create<func::CallOp>(loc, func, inputs);
      for (auto zip : llvm::zip(call.getResults(), newCall.getResults()))
        std::get<0>(zip).replaceAllUsesWith(std::get<1>(zip));
      callsToErase.push_back(call);

      // Finally, collect the information of new streams produced by the current
      // function call.
      for (auto pair : consumerAndChannels)
        streamsMap[pair.first].push_back(newCall.getResults()[pair.second]);

      return WalkResult::advance();
    });

    for (auto call : callsToErase)
      call.erase();

    if (walkResult.wasInterrupted())
      signalPassFailure();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateTokenFlowPass() {
  return std::make_unique<CreateTokenFlow>();
}
