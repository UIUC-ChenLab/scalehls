//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;
using namespace affine;

//===----------------------------------------------------------------------===//
// DispatchOp
//===----------------------------------------------------------------------===//

namespace {
template <typename OpType>
struct SimplifyDispatchOrTaskOutputs : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    auto yield = op.getYieldOp();
    bool hasUnusedPort = false;

    // Identify output values that are used.
    SmallVector<Value, 4> usedOutputs;
    SmallVector<Value, 4> usedResults;
    for (auto result : op.getResults())
      if (result.use_empty()) {
        hasUnusedPort = true;
      } else {
        usedOutputs.push_back(yield.getOperand(result.getResultNumber()));
        usedResults.push_back(result);
      }

    // Construct new op with only used outputs.
    if (hasUnusedPort) {
      rewriter.setInsertionPoint(yield);
      rewriter.replaceOpWithNewOp<YieldOp>(yield, usedOutputs);

      rewriter.setInsertionPoint(op);
      auto newTask =
          rewriter.create<OpType>(op.getLoc(), ValueRange(usedOutputs));
      rewriter.inlineRegionBefore(op.getBody(), newTask.getBody(),
                                  newTask.getBody().end());
      for (auto t : llvm::zip(usedResults, newTask.getResults()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

      rewriter.eraseOp(op);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
template <typename OpType>
struct InlineDispatchOrTask : public OpRewritePattern<OpType> {
  InlineDispatchOrTask(MLIRContext *context,
                       llvm::function_ref<bool(OpType)> condition)
      : OpRewritePattern<OpType>(context), condition(condition) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (condition(op)) {
      auto &ops = op.getBody().front().getOperations();
      auto &parentOps = op->getBlock()->getOperations();
      parentOps.splice(op->getIterator(), ops, ops.begin(),
                       std::prev(ops.end()));
      rewriter.replaceOp(op, op.getYieldOp()->getOperands());
      return success();
    }
    return failure();
  }

private:
  llvm::function_ref<bool(OpType)> condition;
};
} // namespace

namespace {
template <typename OpType>
struct DemoteYieldedBuffer : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    auto yield = op.getYieldOp();
    bool hasChanged = false;

    // Eliminat each yielded buffer. It's always safe to move the buffer to
    // higher level hierarchy.
    for (auto [yieldedValue, result] :
         llvm::zip(yield.getOperands(), op.getResults()))
      if (auto buffer = yieldedValue.template getDefiningOp<BufferOp>()) {
        if (op->isAncestor(buffer))
          buffer->moveBefore(op);

        rewriter.replaceAllUsesWith(result, buffer);
        hasChanged = true;
      }
    return success(hasChanged);
  }
};
} // namespace

void DispatchOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                             MLIRContext *context) {
  results.add<SimplifyDispatchOrTaskOutputs<DispatchOp>>(context);
  results.add<InlineDispatchOrTask<DispatchOp>>(context, [](DispatchOp op) {
    return op.getOps<TaskOp>().empty() || llvm::hasSingleElement(op.getOps());
  });
  results.add<DemoteYieldedBuffer<DispatchOp>>(context);
}

LogicalResult DispatchOp::verify() {
  if (getResultTypes() != getYieldOp().getOperandTypes())
    return emitOpError("yield type doesn't align with result type");
  return success();
}

/// Get the terminator yield op.
YieldOp DispatchOp::getYieldOp() {
  return cast<YieldOp>(getBody().front().getTerminator());
}

//===----------------------------------------------------------------------===//
// TaskOp
//===----------------------------------------------------------------------===//

void TaskOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.add<SimplifyDispatchOrTaskOutputs<TaskOp>>(context);
  results.add<InlineDispatchOrTask<TaskOp>>(
      context, [](TaskOp op) { return llvm::hasSingleElement(op.getOps()); });
  results.add<DemoteYieldedBuffer<TaskOp>>(context);
}

LogicalResult TaskOp::verify() {
  if (getResultTypes() != getYieldOp().getOperandTypes())
    return emitOpError("yield type doesn't align with result type");
  return success();
}

/// Get the parent dispatch op.
DispatchOp TaskOp::getDispatchOp() {
  return (*this)->getParentOfType<DispatchOp>();
}

/// Get the terminator yield op.
YieldOp TaskOp::getYieldOp() {
  return cast<YieldOp>(getBody().front().getTerminator());
}

/// Get the immediate included linalg op. Will return nullptr if there is no
/// such linalg op or more than one linalg op.
linalg::LinalgOp TaskOp::getPayloadLinalgOp() {
  auto linalgOps = getOps<linalg::LinalgOp>();
  if (llvm::hasSingleElement(linalgOps))
    return *linalgOps.begin();
  return nullptr;
}

bool TaskOp::isLivein(Value value) {
  auto liveins = Liveness(*this).getLiveIn(&(*this).getBody().front());
  return liveins.count(value);
}

SmallVector<Value> TaskOp::getLiveins() {
  auto liveins = Liveness(*this).getLiveIn(&(*this).getBody().front());
  return {liveins.begin(), liveins.end()};
}

SmallVector<Operation *> TaskOp::getLiveinUsers(Value livein) {
  assert(isLivein(livein) && "invalid livein");
  auto users = llvm::make_filter_range(livein.getUsers(), [&](Operation *user) {
    return (*this)->isAncestor(user);
  });
  return {users.begin(), users.end()};
}

//===----------------------------------------------------------------------===//
// TensorInitOp
//===----------------------------------------------------------------------===//

LogicalResult TensorInitOp::verify() {
  if (auto initValue = getInitValue())
    if (initValue.getType() != getType().getElementType() &&
        initValue.getType() != getType())
      return emitOpError("initial value's type doesn't align with tensor type");
  return success();
}

//===----------------------------------------------------------------------===//
// TensorToStreamOp
//===----------------------------------------------------------------------===//

LogicalResult TensorToStreamOp::verify() {
  if (!getStream().getType().isConvertableWith(getTensor().getType()))
    return emitOpError() << "stream type is not convertable with tensor type, "
                            "stream type has an integral shape of ("
                         << getStream().getType().getShape() << ")";
  return success();
}

OpFoldResult TensorToStreamOp::fold(FoldAdaptor adaptor) {
  if (auto streamToTensor = getTensor().getDefiningOp<StreamToTensorOp>())
    if (streamToTensor.getStream().getType() == getStream().getType())
      return streamToTensor.getStream();
  return {};
}

//===----------------------------------------------------------------------===//
// StreamToTensorOp
//===----------------------------------------------------------------------===//

LogicalResult StreamToTensorOp::verify() {
  if (!getStream().getType().isConvertableWith(getTensor().getType()))
    return emitOpError() << "stream type is not convertable with tensor type, "
                            "stream type has an integral shape of ("
                         << getStream().getType().getShape() << ")";
  return success();
}

//===----------------------------------------------------------------------===//
// StreamOp
//===----------------------------------------------------------------------===//

LogicalResult StreamOp::verify() {
  unsigned numWrites = 0;
  for (auto user : (*this)->getUsers())
    if (isa<StreamWriteOp>(user))
      numWrites++;
  if (numWrites > 1)
    return emitOpError() << "stream is written more than once";
  return success();
}

void StreamOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Allocate::get(), getChannel(),
                       SideEffects::DefaultResource::get());
}

//===----------------------------------------------------------------------===//
// StreamReadOp
//===----------------------------------------------------------------------===//

static LogicalResult verifyTripCountsAndSteps(Operation *op, Value channel) {
  auto loops = getSurroundingLoops(op, channel.getParentBlock());
  auto tripCounts = getLoopTripCounts(loops);
  auto steps = getLoopSteps(loops);
  if (!tripCounts || !steps)
    return op->emitOpError("iteration trip counts or steps not available");

  auto stripedLoopInfo =
      llvm::make_filter_range(llvm::zip(*tripCounts, *steps), [](auto tuple) {
        return std::get<0>(tuple) != 1;
      });

  auto channelType = channel.getType().cast<StreamType>();
  auto stripedIterInfo = llvm::make_filter_range(
      llvm::zip(channelType.getIterTripCounts(), channelType.getIterSteps()),
      [](auto tuple) { return std::get<0>(tuple) != 1; });

  if (llvm::any_of(llvm::zip(stripedLoopInfo, stripedIterInfo), [](auto tuple) {
        return std::get<0>(tuple) != std::get<1>(tuple);
      })) {
    auto diag = op->emitOpError("loop trip counts or steps doesn't align with "
                                "stream iteration trip counts or steps\n");
    diag << "loop trip counts: " << *tripCounts << ", steps: " << *steps
         << "\n";
    diag << "stream iteration trip counts: " << channelType.getIterTripCounts()
         << ", steps: " << channelType.getIterSteps();
    return diag;
  }
  return success();
}

LogicalResult StreamReadOp::verify() {
  if (getResult())
    if (getChannel().getType().getElementType() != getResult().getType())
      return emitOpError("result type doesn't align with channel type");
  return verifyTripCountsAndSteps(*this, getChannel());
}

void StreamReadOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Read::get(), getChannel(),
                       SideEffects::DefaultResource::get());
}

//===----------------------------------------------------------------------===//
// StreamWriteOp
//===----------------------------------------------------------------------===//

LogicalResult StreamWriteOp::verify() {
  if (getChannel().getType().getElementType() != getValue().getType())
    return emitOpError("value type doesn't align with channel type");
  return verifyTripCountsAndSteps(*this, getChannel());
}

void StreamWriteOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Write::get(), getChannel(),
                       SideEffects::DefaultResource::get());
}

//===----------------------------------------------------------------------===//
// StreamSplitIterationOp
//===----------------------------------------------------------------------===//

static LogicalResult
verifyIterationReassociation(ArrayRef<ReassociationIndices> reassociation,
                             StreamType lowType, StreamType highType,
                             Operation *op) {
  if (reassociation.size() != lowType.getIterTripCounts().size())
    return op->emitOpError("reassociation size doesn't align with input type");

  for (auto [indices, lowTripCount, lowStep] :
       llvm::zip(reassociation, lowType.getIterTripCounts(),
                 lowType.getIterSteps())) {
    int64_t highTripCountProduct = 1;
    int64_t highStepProduct = 1;
    for (auto index : indices) {
      highTripCountProduct *= highType.getIterTripCounts()[index];
      highStepProduct *= highType.getIterSteps()[index];
    }
    if (lowTripCount != highTripCountProduct || lowStep != highStepProduct)
      return op->emitOpError("reassociation doesn't align with input/output "
                             "iteration trip counts or steps");
  }
  return success();
}

LogicalResult StreamSplitIterationOp::verify() {
  if (!getInputType().isCastableWith(getOutputType())) {
    auto diag = emitOpError("input and output are not castable");
    diag << "input shape: " << getInputType().getShape()
         << ", output shape: " << getOutputType().getShape();
    return diag;
  }
  return verifyIterationReassociation(getReassociationIndices(), getInputType(),
                                      getOutputType(), *this);
}

static OpFoldResult foldStreamViewLikeInterface(StreamViewLikeInterface op) {
  if (op.getInput().getType() == op.getOutput().getType())
    return op.getInput();
  if (auto prevView = op.getInput().getDefiningOp<StreamViewLikeInterface>())
    if (prevView.getInputType() == op.getOutput().getType())
      return prevView.getInput();
  return {};
}

OpFoldResult StreamSplitIterationOp::fold(FoldAdaptor adaptor) {
  return foldStreamViewLikeInterface(*this);
}

//===----------------------------------------------------------------------===//
// StreamMergeIterationOp
//===----------------------------------------------------------------------===//

LogicalResult StreamMergeIterationOp::verify() {
  if (!getInputType().isCastableWith(getOutputType())) {
    auto diag = emitOpError("input and output are not castable");
    diag << "input shape: " << getInputType().getShape()
         << ", output shape: " << getOutputType().getShape();
    return diag;
  }
  return verifyIterationReassociation(getReassociationIndices(),
                                      getOutputType(), getInputType(), *this);
}

OpFoldResult StreamMergeIterationOp::fold(FoldAdaptor adaptor) {
  return foldStreamViewLikeInterface(*this);
}

//===----------------------------------------------------------------------===//
// StreamExpandShapeOp
//===----------------------------------------------------------------------===//

static LogicalResult
verifyShapeReassociation(ArrayRef<ReassociationIndices> reassociation,
                         StreamType lowType, StreamType highType,
                         Operation *op) {
  if (lowType.getIterTripCounts() != lowType.getIterTripCounts() ||
      lowType.getIterSteps() != lowType.getIterSteps())
    return op->emitOpError("input and output iteration trip counts or steps "
                           "doesn't match");

  auto lowShape = lowType.getShape();
  auto highShape = highType.getShape();
  if (reassociation.size() != lowShape.size())
    return op->emitOpError("reassociation size doesn't align with input type");

  for (auto [indices, lowDimSize] : llvm::zip(reassociation, lowShape)) {
    int64_t highDimSizeProduct = 1;
    for (auto index : indices)
      highDimSizeProduct *= highShape[index];
    if (lowDimSize != highDimSizeProduct)
      return op->emitOpError("reassociation doesn't align with input/output "
                             "tensor shape");
  }
  return success();
}

LogicalResult StreamExpandShapeOp::verify() {
  if (getInputType().getDataType() != getOutputType().getDataType())
    return emitOpError("input and output data type doesn't match");
  return verifyShapeReassociation(getReassociationIndices(), getInputType(),
                                  getOutputType(), *this);
}

OpFoldResult StreamExpandShapeOp::fold(FoldAdaptor adaptor) {
  return foldStreamViewLikeInterface(*this);
}

//===----------------------------------------------------------------------===//
// StreamCollapseShapeOp
//===----------------------------------------------------------------------===//

LogicalResult StreamCollapseShapeOp::verify() {
  if (getInputType().getDataType() != getOutputType().getDataType())
    return emitOpError("input and output data type doesn't match");
  return verifyShapeReassociation(getReassociationIndices(), getOutputType(),
                                  getInputType(), *this);
}

OpFoldResult StreamCollapseShapeOp::fold(FoldAdaptor adaptor) {
  return foldStreamViewLikeInterface(*this);
}

//===----------------------------------------------------------------------===//
// StreamBufferOp
//===----------------------------------------------------------------------===//

LogicalResult StreamBufferOp::verify() {
  auto inputType = getInput().getType();
  auto outputType = getOutput().getType();
  if (!inputType.isCastableWith(outputType)) {
    auto diag = emitOpError("input and output are not castable");
    diag << "input shape: " << inputType.getShape()
         << ", output shape: " << outputType.getShape();
    return diag;
  }

  if (getLoopIndex() > inputType.getIterTripCounts().size())
    return emitOpError("buffer loop index is out of loop range");

  auto inputShape = inputType.getShape();
  for (auto [dim, bufferSize, dimSize, inputTileSize, outputTileSize] :
       llvm::zip(llvm::seq(inputShape.size()), getBufferShape(), inputShape,
                 inputType.getElementShape(), outputType.getElementShape())) {
    if (dim < getDimIndex()) {
      if (inputTileSize != outputTileSize || bufferSize < inputTileSize)
        return emitOpError(
            "buffer size is smaller than input/output tile size");
    } else if (bufferSize != dimSize)
      return emitOpError(
          "buffer size doesn't align with input/output tensor size");
  }
  return success();
}

OpFoldResult StreamBufferOp::fold(FoldAdaptor adaptor) {
  return foldStreamViewLikeInterface(*this);
}

//===----------------------------------------------------------------------===//
// StreamCastOp
//===----------------------------------------------------------------------===//

LogicalResult StreamCastOp::verify() {
  auto inputType = getInput().getType();
  auto outputType = getOutput().getType();
  if (!inputType.isCastableWith(outputType)) {
    auto diag = emitOpError("input and output are not castable");
    diag << "input shape: " << inputType.getShape()
         << ", output shape: " << outputType.getShape();
    return diag;
  }
  return success();
}

OpFoldResult StreamCastOp::fold(FoldAdaptor adaptor) {
  return foldStreamViewLikeInterface(*this);
}

//===----------------------------------------------------------------------===//
// ScheduleOp
//===----------------------------------------------------------------------===//

namespace {
struct SimplifyScheduleOperands : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    bool hasUnusedPort = false;

    // Identify input values that are used.
    llvm::SmallDenseSet<BlockArgument, 4> unusedArgs;
    SmallVector<Value, 4> usedOperands;
    for (auto arg : schedule.getBody().getArguments())
      if (arg.use_empty()) {
        hasUnusedPort = true;
        unusedArgs.insert(arg);
      } else {
        usedOperands.push_back(schedule.getOperand(arg.getArgNumber()));
      }
    schedule.getBody().front().eraseArguments(
        [&](BlockArgument arg) { return unusedArgs.count(arg); });

    // Construct new schedule.
    if (hasUnusedPort) {
      rewriter.setInsertionPoint(schedule);
      auto newSchedule =
          rewriter.create<ScheduleOp>(schedule.getLoc(), usedOperands);
      rewriter.inlineRegionBefore(schedule.getBody(), newSchedule.getBody(),
                                  newSchedule.getBody().end());
      rewriter.eraseOp(schedule);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
template <typename OpType>
struct InlineScheduleOrNode : public OpRewritePattern<OpType> {
  InlineScheduleOrNode(MLIRContext *context,
                       llvm::function_ref<bool(OpType)> condition)
      : OpRewritePattern<OpType>(context), condition(condition) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (condition(op)) {
      auto &ops = op.getBody().front().getOperations();
      auto &parentOps = op->getBlock()->getOperations();
      parentOps.splice(op->getIterator(), ops);

      for (auto t : llvm::zip(op.getBody().getArguments(), op.getOperands()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      rewriter.eraseOp(op);
      return success();
    }
    return failure();
  }

private:
  llvm::function_ref<bool(OpType)> condition;
};
} // namespace

void ScheduleOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                             MLIRContext *context) {
  results.add<SimplifyScheduleOperands>(context);
  results.add<InlineScheduleOrNode<ScheduleOp>>(
      context, [](ScheduleOp op) { return op.getOps<NodeOp>().empty(); });
}

LogicalResult ScheduleOp::verify() {
  if (getOperandTypes() != getBody().getArgumentTypes())
    return emitOpError("operand type doesn't align with argument type");

  if (getIsLegal())
    for (auto &op : getOps())
      if (!isa<NodeOp, BufferOp, ConstBufferOp, StreamOp>(op)) {
        auto diag = emitOpError("legal schedule has illegal ops:\n");
        diag.attachNote(op.getLoc())
            .append("see current op: ")
            .appendOp(op, OpPrintingFlags().printGenericOpForm());
        return diag;
      }
  return success();
}

void ScheduleOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  for (auto value : getOperands())
    if (value.getType().isa<MemRefType, StreamType>()) {
      effects.emplace_back(MemoryEffects::Read::get(), value,
                           SideEffects::DefaultResource::get());
      effects.emplace_back(MemoryEffects::Write::get(), value,
                           SideEffects::DefaultResource::get());
    }
}

/// FIXME: Check whether the schedule is dependence free.
bool ScheduleOp::isDependenceFree() {
  return isa<func::FuncOp>((*this)->getParentOp());
}

/// Update the signature of the schedule op recursively.
void ScheduleOp::updateSignatureRecursively() {
  for (auto [operand, arg] : llvm::zip(getOperands(), getBody().getArguments()))
    arg.setType(operand.getType());
  for (auto node : getOps<NodeOp>())
    node.updateSignatureRecursively();
}

//===----------------------------------------------------------------------===//
// NodeOp
//===----------------------------------------------------------------------===//

namespace {
struct SimplifyNodeIOs : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    bool hasUnusedPort = false;

    // Identify input values that are used.
    llvm::SmallDenseSet<BlockArgument, 4> unusedArgs;
    SmallVector<Value, 4> usedInputs;
    SmallVector<int32_t, 4> usedInputTaps;
    SmallVector<Value, 4> usedOutputs;
    SmallVector<Value, 4> usedParams;
    for (auto arg : node.getBody().getArguments())
      if (arg.use_empty()) {
        hasUnusedPort = true;
        unusedArgs.insert(arg);
      } else {
        auto idx = arg.getArgNumber();
        if (node.getPortKind(idx) == PortKind::INPUT) {
          usedInputs.push_back(node.getOperand(idx));
          usedInputTaps.push_back(node.getInputTap(idx));
        } else if (node.getPortKind(idx) == PortKind::OUTPUT)
          usedOutputs.push_back(node.getOperand(idx));
        else
          usedParams.push_back(node.getOperand(idx));
      }
    node.getBody().front().eraseArguments(
        [&](BlockArgument arg) { return unusedArgs.count(arg); });

    // Construct new dataflow node.
    if (hasUnusedPort) {
      rewriter.setInsertionPoint(node);
      auto newNode = rewriter.create<NodeOp>(
          node.getLoc(), usedInputs, usedOutputs, usedParams,
          rewriter.getI32ArrayAttr(usedInputTaps), node.getLevelAttr());
      rewriter.inlineRegionBefore(node.getBody(), newNode.getBody(),
                                  newNode.getBody().end());
      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

void NodeOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.add<SimplifyNodeIOs>(context);
  results.add<InlineScheduleOrNode<NodeOp>>(context, [](NodeOp op) {
    return false;
    // return llvm::hasSingleElement(op.getScheduleOp().getOps<NodeOp>());
  });
}

LogicalResult NodeOp::verify() {
  if (getOperandTypes() != getBody().getArgumentTypes())
    return emitOpError("operand type doesn't align with argument type");

  if (llvm::any_of(getParams(), [](Value param) {
        return param.getType().isa<MemRefType, StreamType>();
      }))
    return emitOpError("node params should not be memref or stream typed");

  if (getInputs().size() != getInputTaps().size())
    return emitOpError("number of node inputs and input taps are not aligned");
  for (auto t : llvm::zip(getInputs(), getInputTapsAsInt())) {
    auto depth = getBufferDepth(std::get<0>(t));
    auto inputTap = (unsigned)std::get<1>(t);
    if (depth <= inputTap) {
      auto diag = emitOpError("node input tap is larger than buffer depth, ");
      diag << "input tap: " << inputTap << ", depth: " << depth;
    }
  }

  for (auto inputArg : getInputArgs())
    if (llvm::any_of(inputArg.getUses(), isWritten)) {
      auto diag = emitOpError("input operand ");
      diag << inputArg << " is written";
      return diag;
    }

  for (auto outputArg : getOutputArgs())
    if (!llvm::any_of(outputArg.getUses(), isWritten)) {
      auto diag = emitOpError("output operand ");
      diag << outputArg << " is not written";
      return diag;
    }

  if (getScheduleOp().getIsLegal()) {
    if (!getLevel())
      return emitOpError("node is not scheduled");

    for (auto output : getOutputs()) {
      // DRAM buffer is not considered - the dependencies associated with them
      // are handled later by tokens.
      if (isExtBuffer(output))
        continue;

      if (getDependentConsumers(output, *this).size() > 1 ||
          getProducers(output).size() > 1) {
        auto diag = emitOpError(
            "legal schedule violates single-consumer or single-producer, ");
        diag << "see current buffer: " << output << "\n";
        for (auto user : output.getUsers())
          diag.attachNote(user->getLoc())
              .append("see current buffer user: ")
              .appendOp(*user, OpPrintingFlags().printGenericOpForm());
        return diag;
      }
    }
  }
  return success();
}

void NodeOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  for (auto value : getInputs())
    effects.emplace_back(MemoryEffects::Read::get(), value,
                         SideEffects::DefaultResource::get());
  for (auto value : getOutputs()) {
    effects.emplace_back(MemoryEffects::Read::get(), value,
                         SideEffects::DefaultResource::get());
    effects.emplace_back(MemoryEffects::Write::get(), value,
                         SideEffects::DefaultResource::get());
  }
}

/// Get the parent schedule op.
ScheduleOp NodeOp::getScheduleOp() {
  return (*this)->getParentOfType<ScheduleOp>();
}

/// Get input taps.
void NodeOp::setInputTap(unsigned idx, unsigned tap) {
  SmallVector<int32_t> newInputTaps(llvm::map_range(
      getInputTapsAsInt(), [](unsigned a) { return (int32_t)a; }));
  newInputTaps[idx] = tap;
  Builder builder(getContext());
  setInputTapsAttr(builder.getI32ArrayAttr(newInputTaps));
}
unsigned NodeOp::getInputTap(unsigned idx) {
  return getInputTaps()[idx].cast<IntegerAttr>().getInt();
}
SmallVector<unsigned> NodeOp::getInputTapsAsInt() {
  auto array = llvm::map_range(getInputTaps(), [](Attribute attr) {
    return attr.cast<IntegerAttr>().getInt();
  });
  return {array.begin(), array.end()};
}

/// Return the number of inputs, outputs, and params.
unsigned NodeOp::getNumInputs() {
  return getODSOperandIndexAndLength(0).second;
}
unsigned NodeOp::getNumOutputs() {
  return getODSOperandIndexAndLength(1).second;
}
unsigned NodeOp::getNumParams() {
  return getODSOperandIndexAndLength(2).second;
}

/// Get the type of operand: input, output, or param.
PortKind NodeOp::getPortKind(OpOperand &operand) {
  assert(operand.getOwner() == *this && "invalid operand");
  return getPortKind(operand.getOperandNumber());
}
PortKind NodeOp::getPortKind(unsigned operandIdx) {
  if (operandIdx >= getODSOperandIndexAndLength(2).first)
    return PortKind::PARAM;
  else if (operandIdx >= getODSOperandIndexAndLength(1).first)
    return PortKind::OUTPUT;
  else
    return PortKind::INPUT;
}

/// Get the input, output, and param arguments.
iterator_range<Block::args_iterator> NodeOp::getInputArgs() {
  auto range = getODSOperandIndexAndLength(0);
  return {std::next(getBody().args_begin(), range.first),
          std::next(getBody().args_begin(), range.first + range.second)};
}
iterator_range<Block::args_iterator> NodeOp::getOutputArgs() {
  auto range = getODSOperandIndexAndLength(1);
  return {std::next(getBody().args_begin(), range.first),
          std::next(getBody().args_begin(), range.first + range.second)};
}
iterator_range<Block::args_iterator> NodeOp::getParamArgs() {
  auto range = getODSOperandIndexAndLength(2);
  return {std::next(getBody().args_begin(), range.first),
          std::next(getBody().args_begin(), range.first + range.second)};
}

bool NodeOp::isLivein(Value value) {
  return value.isa<BlockArgument>() &&
         value.getParentRegion() == &(*this).getBody();
}

SmallVector<Value> NodeOp::getLiveins() {
  auto args = (*this).getBody().getArguments();
  return {args.begin(), args.end()};
}

SmallVector<Operation *> NodeOp::getLiveinUsers(Value livein) {
  assert(isLivein(livein) && "invalid livein");
  auto users = livein.getUsers();
  return {users.begin(), users.end()};
}

/// Update the signature of the node op recursively.
void NodeOp::updateSignatureRecursively() {
  llvm::SmallDenseSet<ScheduleOp> schedules;
  for (auto [operand, arg] :
       llvm::zip(getOperands(), getBody().getArguments())) {
    arg.setType(operand.getType());
    for (auto user : arg.getUsers())
      if (auto schedule = dyn_cast<ScheduleOp>(user))
        schedules.insert(schedule);
  }
  // TODO: How to traverse all schedule ops?
  for (auto schedule : schedules)
    schedule.updateSignatureRecursively();
}

//===----------------------------------------------------------------------===//
// BufferOp and ConstBufferOp
//===----------------------------------------------------------------------===//

namespace {
struct FlattenReadOnlyBuffer : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (buffer.getInitValue() &&
        llvm::all_of(buffer->getUsers(),
                     [](Operation *user) { return isa<AffineLoadOp>(user); })) {
      auto initValue = buffer.getInitValue().value();
      auto constant =
          rewriter.create<arith::ConstantOp>(buffer.getLoc(), initValue);
      for (auto user : buffer->getUsers())
        rewriter.replaceOp(user, constant.getResult());
      rewriter.eraseOp(buffer);
      return success();
    }
    return failure();
  }
};
} // namespace

static NodeOp sinkBufferIntoNode(NodeOp node, BufferOp buffer,
                                 PatternRewriter &rewriter) {
  assert(node->getParentRegion() == buffer->getParentRegion() &&
         "node and buffer is not at the same region");
  SmallVector<Value> inputs;
  SmallVector<unsigned, 8> inputTaps;
  SmallVector<Value> outputs;
  llvm::BitVector eraseIndices;

  for (auto input : llvm::enumerate(node.getInputs())) {
    if (input.value() != buffer) {
      inputs.push_back(input.value());
      inputTaps.push_back(node.getInputTap(input.index()));
      eraseIndices.push_back(false);
    } else {
      auto arg = node.getBody().getArgument(input.index());
      arg.replaceAllUsesWith(buffer);
      eraseIndices.push_back(true);
    }
  }
  for (auto output : llvm::enumerate(node.getOutputs())) {
    if (output.value() != buffer) {
      outputs.push_back(output.value());
      eraseIndices.push_back(false);
    } else {
      auto arg =
          node.getBody().getArgument(node.getNumInputs() + output.index());
      arg.replaceAllUsesWith(buffer);
      eraseIndices.push_back(true);
    }
  }
  for (unsigned i = 0; i < node.getNumParams(); ++i)
    eraseIndices.push_back(false);

  auto &nodeBlock = node.getBody().front();
  buffer->moveBefore(&nodeBlock.front());
  nodeBlock.eraseArguments(eraseIndices);

  rewriter.setInsertionPointAfter(node);
  auto newNode =
      rewriter.create<NodeOp>(node.getLoc(), inputs, outputs, node.getParams(),
                              inputTaps, node.getLevelAttr());
  rewriter.inlineRegionBefore(node.getBody(), newNode.getBody(),
                              newNode.getBody().begin());
  rewriter.eraseOp(node);
  return newNode;
}

static ScheduleOp sinkBufferIntoSchedule(ScheduleOp schedule, BufferOp buffer,
                                         PatternRewriter &rewriter) {
  assert(schedule->getParentRegion() == buffer->getParentRegion() &&
         "node and buffer is not at the same region");
  SmallVector<Value> operands;
  llvm::BitVector eraseIndices;

  for (auto operand : llvm::enumerate(schedule.getOperands())) {
    if (operand.value() != buffer) {
      operands.push_back(operand.value());
      eraseIndices.push_back(false);
    } else
      eraseIndices.push_back(true);
  }

  auto &scheduleBlock = schedule.getBody().front();
  buffer->moveBefore(&scheduleBlock.front());
  scheduleBlock.eraseArguments(eraseIndices);

  rewriter.setInsertionPointAfter(schedule);
  auto newSchedule = rewriter.create<ScheduleOp>(schedule.getLoc(), operands,
                                                 schedule.getIsLegalAttr());
  rewriter.inlineRegionBefore(schedule.getBody(), newSchedule.getBody(),
                              newSchedule.getBody().begin());
  rewriter.eraseOp(schedule);
  return newSchedule;
}

namespace {
struct SinkInternalBuffer : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (!isExtBuffer(buffer) && llvm::hasSingleElement(buffer->getUsers())) {
      auto user = *buffer->getUsers().begin();

      // Sink the buffer into the node or schedule user.
      if (user->getParentRegion() == buffer->getParentRegion() &&
          isa<NodeOp, ScheduleOp>(user)) {
        if (auto node = dyn_cast<NodeOp>(user))
          sinkBufferIntoNode(node, buffer, rewriter);
        else if (auto schedule = dyn_cast<ScheduleOp>(user))
          sinkBufferIntoSchedule(schedule, buffer, rewriter);
        return success();
      }
    }
    return failure();
  }
};
} // namespace

void BufferOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                           MLIRContext *context) {
  results.add<FlattenReadOnlyBuffer>(context);
  results.add<SinkInternalBuffer>(context);
}

LogicalResult BufferOp::verify() {
  if (auto initValue = getInitValue())
    if (initValue.value().getType() != getType().getElementType())
      return emitOpError("initial value's type doesn't align with memref type");

  if (isExtBuffer(*this)) {
    if (auto node = dyn_cast<NodeOp>((*this)->getParentOp()))
      return emitOpError("external buffer should not be placed in node");
    if (auto schedule = dyn_cast<ScheduleOp>((*this)->getParentOp()))
      if (!isa<func::FuncOp>(schedule->getParentOp()))
        return emitOpError("external buffer must be placed in top schedule");
  }
  return success();
}

int32_t BufferOp::getBufferDepth() { return getDepth(); }
std::optional<TypedAttr> BufferOp::getBufferInitValue() {
  return getInitValue();
}

void BufferOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Allocate::get(), getMemref(),
                       SideEffects::DefaultResource::get());
}

int32_t ConstBufferOp::getBufferDepth() { return 1; }
std::optional<TypedAttr> ConstBufferOp::getBufferInitValue() {
  return std::optional<TypedAttr>();
}

LogicalResult ConstBufferOp::verify() {
  if (llvm::any_of((*this)->getUses(), isWritten))
    return emitOpError("const buffer cannot be written");

  auto memrefType = getType();
  auto attrType = getValue().getType().cast<TensorType>();
  if (memrefType.getElementType() != attrType.getElementType())
    return emitOpError("element type mismatch");
  if (memrefType.getShape() != attrType.getShape())
    return emitOpError("shape mismatch");
  return success();
}

void ConstBufferOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Allocate::get(), getMemref(),
                       SideEffects::DefaultResource::get());
}
