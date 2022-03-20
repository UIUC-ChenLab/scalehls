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

// Updates the func op and entry block. Any args appended to the entry block are
// added to `appendedEntryArgs`.
static void updateFuncOp(FuncOp func,
                         SmallVectorImpl<BlockArgument> &appendedEntryArgs) {
  auto functionType = func.getType();

  // Collect information about the results will become appended arguments.
  SmallVector<Type, 6> erasedResultTypes;
  BitVector erasedResultIndices(functionType.getNumResults());
  for (const auto &resultType : llvm::enumerate(functionType.getResults())) {
    if (resultType.value().isa<hlscpp::StreamType>()) {
      erasedResultIndices.set(resultType.index());
      erasedResultTypes.push_back(resultType.value());
    }
  }

  // Add the new arguments to the function type.
  auto newArgTypes = llvm::to_vector<6>(
      llvm::concat<const Type>(functionType.getInputs(), erasedResultTypes));
  auto newFunctionType = FunctionType::get(func.getContext(), newArgTypes,
                                           functionType.getResults());
  func.setType(newFunctionType);

  // Transfer the result attributes to arg attributes.
  auto erasedIndicesIt = erasedResultIndices.set_bits_begin();
  for (int i = 0, e = erasedResultTypes.size(); i < e; ++i, ++erasedIndicesIt) {
    func.setArgAttrs(functionType.getNumInputs() + i,
                     func.getResultAttrs(*erasedIndicesIt));
  }

  // Erase the results.
  func.eraseResults(erasedResultIndices);

  // Add the new arguments to the entry block if the function is not external.
  if (func.isExternal())
    return;
  Location loc = func.getLoc();
  for (Type type : erasedResultTypes)
    appendedEntryArgs.push_back(func.front().addArgument(type, loc));
}

// Updates all ReturnOps in the scope of the given FuncOp by either keeping them
// as return values or copying the associated buffer contents into the given
// out-params.
static void updateReturnOps(FuncOp func,
                            ArrayRef<BlockArgument> appendedEntryArgs) {
  func.walk([&](func::ReturnOp op) {
    SmallVector<Value, 6> copyIntoOutParams;
    SmallVector<Value, 6> keepAsReturnOperands;
    for (Value operand : op.getOperands()) {
      if (operand.getType().isa<StreamType>())
        copyIntoOutParams.push_back(operand);
      else
        keepAsReturnOperands.push_back(operand);
    }
    OpBuilder builder(op);
    for (auto t : llvm::zip(copyIntoOutParams, appendedEntryArgs)) {
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      if (auto stream = std::get<0>(t).getDefiningOp<hlscpp::StreamChannelOp>())
        stream.erase();
    }
    builder.create<func::ReturnOp>(op.getLoc(), keepAsReturnOperands);
    op.erase();
  });
}

// Updates all CallOps in the scope of the given ModuleOp by allocating
// temporary buffers for newly introduced out params.
static void updateCalls(ModuleOp module) {
  module.walk([&](func::CallOp op) {
    SmallVector<Value, 6> replaceWithNewCallResults;
    SmallVector<Value, 6> replaceWithOutParams;
    for (OpResult result : op.getResults()) {
      if (result.getType().isa<hlscpp::StreamType>())
        replaceWithOutParams.push_back(result);
      else
        replaceWithNewCallResults.push_back(result);
    }
    SmallVector<Value, 6> outParams;
    OpBuilder builder(op);
    for (Value stream : replaceWithOutParams) {
      Value outParam = builder.create<hlscpp::StreamChannelOp>(
          op.getLoc(), stream.getType().cast<StreamType>());
      stream.replaceAllUsesWith(outParam);
      outParams.push_back(outParam);
    }

    auto newOperands = llvm::to_vector<6>(op.getOperands());
    newOperands.append(outParams.begin(), outParams.end());
    auto newResultTypes = llvm::to_vector<6>(llvm::map_range(
        replaceWithNewCallResults, [](Value v) { return v.getType(); }));
    auto newCall = builder.create<func::CallOp>(op.getLoc(), op.getCalleeAttr(),
                                                newResultTypes, newOperands);
    for (auto t : llvm::zip(replaceWithNewCallResults, newCall.getResults()))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
    op.erase();
  });
}

namespace {
struct LowerStreamBufferOpRewritePattern
    : public OpRewritePattern<hlscpp::StreamBufferOp> {
  using OpRewritePattern<hlscpp::StreamBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hlscpp::StreamBufferOp buffer,
                                PatternRewriter &rewriter) const override {
    auto loc = buffer.getLoc();
    auto block = buffer->getBlock();

    rewriter.setInsertionPointToStart(block);
    if (llvm::all_of(buffer.input().getUsers(), [](Operation *op) {
          return isa<hlscpp::StreamWriteOp>(op);
        }))
      rewriter.create<hlscpp::StreamReadOp>(loc, Type(), buffer.input());
    auto channel = rewriter.replaceOpWithNewOp<hlscpp::StreamChannelOp>(
        buffer, buffer.getType());

    rewriter.setInsertionPoint(block->getTerminator());
    rewriter.create<hlscpp::StreamWriteOp>(loc, channel, Value());
    return success();
  }
};
} // namespace

namespace {
struct HoistStreamChannel : HoistStreamChannelBase<HoistStreamChannel> {
  void runOnOperation() override {
    ModuleOp module = getOperation();
    auto context = module.getContext();

    // Lowering stream buffers. TODO: Maybe this should be factored out.
    mlir::RewritePatternSet patterns(context);
    patterns.add<LowerStreamBufferOpRewritePattern>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));

    // Get the top function of the module.
    auto func = getTopFunc(module);
    if (!func) {
      emitError(module.getLoc(), "fail to find the top function");
      return signalPassFailure();
    }

    // Hoist stream channels to the top-function.
    SmallVector<BlockArgument, 6> appendedEntryArgs;
    updateFuncOp(func, appendedEntryArgs);
    updateReturnOps(func, appendedEntryArgs);
    updateCalls(module);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createHoistStreamChannelPass() {
  return std::make_unique<HoistStreamChannel>();
}
