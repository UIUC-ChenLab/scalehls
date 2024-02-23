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
  for (auto &use : (*this)->getUses())
    numWrites += isWritten(use);
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

  if (std::distance(stripedLoopInfo.begin(), stripedLoopInfo.end()) !=
          std::distance(stripedIterInfo.begin(), stripedIterInfo.end()) ||
      llvm::any_of(llvm::zip(stripedLoopInfo, stripedIterInfo), [](auto tuple) {
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
  if (getChannel().getType().getElementType() != getResult().getType())
    return emitOpError("result type doesn't align with channel type");
  if (getInit())
    if (getInit().getType() != getResult().getType())
      return emitOpError("initial value type doesn't align with result type");
  return success();
  // return verifyTripCountsAndSteps(*this, getChannel());
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
  return success();
  // return verifyTripCountsAndSteps(*this, getChannel());
}

void StreamWriteOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Write::get(), getChannel(),
                       SideEffects::DefaultResource::get());
}

//===----------------------------------------------------------------------===//
// StreamReassociateOp
//===----------------------------------------------------------------------===//

LogicalResult StreamReassociateOp::verify() {
  if (getInputType().getDataType() != getOutputType().getDataType())
    return emitOpError("input and output data type doesn't match");

  // Verify the shape reassociation.
  auto lowShapeType = getExpandShape() ? getInputType() : getOutputType();
  auto highShapeType = getExpandShape() ? getOutputType() : getInputType();
  auto lowShape = lowShapeType.getShape();
  auto highShape = highShapeType.getShape();
  auto shapeReassociation = getShapeReassociationIndices();
  if (shapeReassociation.size() != lowShape.size())
    return emitOpError("shape reassociation has invalid size");

  for (auto [indices, lowDimSize] : llvm::zip(shapeReassociation, lowShape)) {
    int64_t highDimSizeProduct = 1;
    for (auto index : indices)
      highDimSizeProduct *= highShape[index];
    if (lowDimSize != highDimSizeProduct)
      return emitOpError(
          "shape reassociation doesn't align with input/output shape");
  }

  // Verify the iteration reassociation.
  auto lowIterationType =
      getExpandIteration() ? getInputType() : getOutputType();
  auto highIterationType =
      getExpandIteration() ? getOutputType() : getInputType();
  auto iterationReassociation = getIterationReassociationIndices();
  if ((int64_t)iterationReassociation.size() != lowIterationType.getIterRank())
    return emitOpError("iteration reassociation has invalid size");

  for (auto [indices, lowTripCount, lowStep] :
       llvm::zip(iterationReassociation, lowIterationType.getIterTripCounts(),
                 lowIterationType.getIterSteps())) {
    int64_t highTripCountProduct = 1, highStepProduct = 1;
    for (auto index : indices) {
      highTripCountProduct *= highIterationType.getIterTripCounts()[index];
      highStepProduct *= highIterationType.getIterSteps()[index];
    }
    if (lowTripCount != highTripCountProduct || lowStep != highStepProduct)
      return emitOpError("iteration reassociation doesn't align with "
                         "input/output iteration trip counts or steps");
  }
  return success();
}

static OpFoldResult foldStreamViewLikeInterface(StreamViewLikeInterface op) {
  if (op.getInput().getType() == op.getOutput().getType())
    return op.getInput();
  if (auto prevView = op.getInput().getDefiningOp<StreamViewLikeInterface>())
    if (prevView.getInputType() == op.getOutput().getType())
      return prevView.getInput();
  return {};
}

OpFoldResult StreamReassociateOp::fold(FoldAdaptor adaptor) {
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

  if (getLoopIndex() > inputType.getIterRank())
    return emitOpError("buffer loop index is out of loop range");

  auto inputShape = inputType.getShape();
  for (auto [dim, bufferSize, dimSize, inputTileSize, outputTileSize] :
       llvm::zip(llvm::seq(inputShape.size()), getBufferShape(), inputShape,
                 inputType.getElementShape(), outputType.getElementShape())) {
    if ((int64_t)dim < getDimIndex()) {
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
template <typename OpType>
struct SimplifyScheduleOrTaskOutputs : public OpRewritePattern<OpType> {
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
      auto newOp =
          rewriter.create<OpType>(op.getLoc(), ValueRange(usedOutputs));
      newOp->setAttrs(op->getAttrs());
      rewriter.inlineRegionBefore(op.getBody(), newOp.getBody(),
                                  newOp.getBody().end());
      for (auto t : llvm::zip(usedResults, newOp.getResults()))
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
struct InlineScheduleOrTask : public OpRewritePattern<OpType> {
  InlineScheduleOrTask(MLIRContext *context,
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
struct DemoteScheduleOrTaskOutputs : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    auto yield = op.getYieldOp();
    bool hasChanged = false;

    for (auto [yieldedValue, result] :
         llvm::zip(yield.getOperands(), op.getResults())) {
      // Try to move yielded buffer/stream to the upper hierarchy.
      auto defOp = yieldedValue.getDefiningOp();
      if (defOp && isa<BufferLikeInterface, StreamOp>(defOp))
        if (op->isAncestor(defOp)) {
          defOp->moveBefore(op);
          hasChanged = true;
        }

      // If the yielded value is defined in an ancestor region of the current
      if (yieldedValue.getParentRegion()->isProperAncestor(&op.getBody())) {
        rewriter.replaceAllUsesWith(result, yieldedValue);
        hasChanged = true;
      }
    }
    return success(hasChanged);
  }
};
} // namespace

void ScheduleOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                             MLIRContext *context) {
  results.add<SimplifyScheduleOrTaskOutputs<ScheduleOp>>(context);
  results.add<InlineScheduleOrTask<ScheduleOp>>(context, [](ScheduleOp op) {
    return op.getOps<TaskOp>().empty() || llvm::hasSingleElement(op.getOps());
  });
  results.add<DemoteScheduleOrTaskOutputs<ScheduleOp>>(context);
}

LogicalResult ScheduleOp::verify() {
  if (getResultTypes() != getYieldOp().getOperandTypes())
    return emitOpError("yield type doesn't align with result type");
  return success();
}

/// Get the terminator yield op.
YieldOp ScheduleOp::getYieldOp() {
  return cast<YieldOp>(getBody().front().getTerminator());
}

//===----------------------------------------------------------------------===//
// TaskOp
//===----------------------------------------------------------------------===//

void TaskOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.add<SimplifyScheduleOrTaskOutputs<TaskOp>>(context);
  results.add<InlineScheduleOrTask<TaskOp>>(context, [](TaskOp op) {
    return llvm::hasSingleElement(
               op.getParentOp<ScheduleOp>().getOps<TaskOp>()) ||
           llvm::hasSingleElement(op.getOps());
  });
  results.add<DemoteScheduleOrTaskOutputs<TaskOp>>(context);
}

LogicalResult TaskOp::verify() {
  if (getResultTypes() != getYieldOp().getOperandTypes())
    return emitOpError("yield type doesn't align with result type");
  return success();
}

/// Get the parent dispatch op.
ScheduleOp TaskOp::getScheduleOp() {
  return (*this)->getParentOfType<ScheduleOp>();
}

/// Get the terminator yield op.
YieldOp TaskOp::getYieldOp() {
  return cast<YieldOp>(getBody().front().getTerminator());
}

// bool TaskOp::isLivein(Value value) {
//   auto liveins = Liveness(*this).getLiveIn(&(*this).getBody().front());
//   return liveins.count(value);
// }

// SmallVector<Value> TaskOp::getLiveins() {
//   auto liveins = Liveness(*this).getLiveIn(&(*this).getBody().front());
//   return {liveins.begin(), liveins.end()};
// }

// SmallVector<Operation *> TaskOp::getLiveinUsers(Value livein) {
//   assert(isLivein(livein) && "invalid livein");
//   auto users = llvm::make_filter_range(livein.getUsers(), [&](Operation
//   *user) {
//     return (*this)->isAncestor(user);
//   });
//   return {users.begin(), users.end()};
// }

//===----------------------------------------------------------------------===//
// BufferOp
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

void BufferOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                           MLIRContext *context) {
  results.add<FlattenReadOnlyBuffer>(context);
}

LogicalResult BufferOp::verify() {
  if (auto initValue = getInitValue())
    if (initValue.value().getType() != getType().getElementType())
      return emitOpError("initial value's type doesn't align with memref type");
  return success();
}

std::optional<TypedAttr> BufferOp::getBufferInitValue() {
  return getInitValue();
}

void BufferOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Allocate::get(), getMemref(),
                       SideEffects::DefaultResource::get());
}

//===----------------------------------------------------------------------===//
// ConstBufferOp
//===----------------------------------------------------------------------===//

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
