//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/IR/Dominance.h"
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
// ITensorInitOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorInitOp::verify() {
  if (auto initValue = getInitValue())
    if (initValue.getType() != getType().getDataType())
      return emitOpError("initial value doesn't align with itensor data type");
  return success();
}

//===----------------------------------------------------------------------===//
// ITensorReadFullTensorOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorReadFullTensorOp::verify() {
  if (!getSourceType().isConvertableWith(getFullTensorType()))
    return emitOpError("itensor type is not convertable with tensor type");
  return success();
}

//===----------------------------------------------------------------------===//
// ITensorWriteFullTensorOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorWriteFullTensorOp::verify() {
  if (getDestType() != getResultType())
    return emitOpError("initial itensor type doesn't align with result type");
  if (!getResultType().isConvertableWith(getFullTensorType()))
    return emitOpError("itensor type is not convertable with full tensor type");
  return success();
}

OpFoldResult ITensorWriteFullTensorOp::fold(FoldAdaptor adaptor) {
  if (auto streamToTensor =
          getFullTensor().getDefiningOp<ITensorReadFullTensorOp>())
    if (streamToTensor.getSource().getType() == getResult().getType())
      return streamToTensor.getSource();
  return {};
}

//===----------------------------------------------------------------------===//
// ITensorReadOp
//===----------------------------------------------------------------------===//

static LogicalResult verifyTripCountsAndSteps(Operation *op,
                                              TypedValue<ITensorType> iTensor) {
  auto iTensorType = iTensor.getType();
  auto untiledITensor = getUntiledOperand(iTensor);

  auto loops = getSurroundingLoops(op, untiledITensor.getParentBlock());
  auto tripCounts = getLoopTripCounts(loops);
  auto steps = getLoopSteps(loops);
  if (!tripCounts || !steps)
    return op->emitOpError("iteration trip counts or steps not available");

  auto stripedLoopInfo =
      llvm::make_filter_range(llvm::zip(*tripCounts, *steps), [](auto tuple) {
        return std::get<0>(tuple) != 1;
      });

  auto stripedIterInfo = llvm::make_filter_range(
      llvm::zip(iTensorType.getIterTripCounts(), iTensorType.getIterSteps()),
      [](auto tuple) { return std::get<0>(tuple) != 1; });

  if (std::distance(stripedLoopInfo.begin(), stripedLoopInfo.end()) !=
          std::distance(stripedIterInfo.begin(), stripedIterInfo.end()) ||
      llvm::any_of(llvm::zip(stripedLoopInfo, stripedIterInfo), [](auto tuple) {
        return std::get<0>(tuple) != std::get<1>(tuple);
      }))
    return op->emitOpError("loop trip counts or steps doesn't align with "
                           "itensor iteration\nloop trip counts: ")
           << *tripCounts << ", steps: " << *steps
           << "\nitensor iteration trip counts: "
           << iTensorType.getIterTripCounts()
           << ", steps: " << iTensorType.getIterSteps();
  return success();
}

LogicalResult ITensorReadOp::verify() {
  if (getSourceType().getElementType() != getValueType())
    return emitOpError("value type doesn't align with itensor type");
  if (getInitType() && getInitType() != getValueType())
    return emitOpError("initial tensor type doesn't align with value type");
  return verifyTripCountsAndSteps(*this, getSource());
}

//===----------------------------------------------------------------------===//
// ITensorWriteOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorWriteOp::verify() {
  if (getDestType() != getResultType())
    return emitOpError("initial itensor type doesn't align with result type");
  if (getDestType().getElementType() != getValueType())
    return emitOpError("value type doesn't align with itensor type");
  return verifyTripCountsAndSteps(*this, getDest());
}

//===----------------------------------------------------------------------===//
// ITensorBufferOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorBufferOp::verify() {
  if (getDestType() != getResultType())
    return emitOpError("initial itensor type doesn't align with result type");

  auto sourceType = getSourceType();
  auto destType = getDestType();
  if (!sourceType.isCastableWith(destType))
    return emitOpError("input and output are not castable\ninput shape: ")
           << sourceType.getShape()
           << ", output shape: " << destType.getShape();

  if (getLoopIndex() > sourceType.getIterRank())
    return emitOpError("buffer loop index is out of loop range");

  auto sourceShape = sourceType.getShape();
  for (auto [dim, bufferSize, dimSize, sourceTileSize, destTileSize] :
       llvm::zip(llvm::seq(sourceShape.size()), getBufferShape(), sourceShape,
                 sourceType.getElementShape(), destType.getElementShape())) {
    if ((int64_t)dim < getDimIndex()) {
      if (sourceTileSize != destTileSize || bufferSize < sourceTileSize)
        return emitOpError(
            "buffer size is smaller than input/output tile size");
    } else if (bufferSize != dimSize)
      return emitOpError(
          "buffer size doesn't align with input/output tensor size");
  }
  return success();
}

//===----------------------------------------------------------------------===//
// ITensorReassociateOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorReassociateOp::verify() {
  if (getSourceType().getDataType() != getResultType().getDataType())
    return emitOpError("source and result itensor data type doesn't match");
  if (getSourceType().getDepth() != getResultType().getDepth())
    return emitOpError("source and result itensor depth doesn't match");

  // Verify the shape reassociation.
  auto lowShapeType = getExpandShape() ? getSourceType() : getResultType();
  auto highShapeType = getExpandShape() ? getResultType() : getSourceType();
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
      getExpandIteration() ? getSourceType() : getResultType();
  auto highIterationType =
      getExpandIteration() ? getResultType() : getSourceType();
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

OpFoldResult ITensorReassociateOp::fold(FoldAdaptor adaptor) {
  return foldRedundantViews();
}

//===----------------------------------------------------------------------===//
// ITensorCastOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorCastOp::verify() {
  if (!getSourceType().isCastableWith(getResultType())) {
    return emitOpError("input and output are not castable\ninput shape: ")
           << getSourceType().getShape()
           << ", output shape: " << getResultType().getShape();
    if (getSourceType().getDepth() != getResultType().getDepth())
      return emitOpError("source and result itensor depth doesn't match");
  }
  return success();
}

OpFoldResult ITensorCastOp::fold(FoldAdaptor adaptor) {
  return foldRedundantViews();
}

//===----------------------------------------------------------------------===//
// StreamOp
//===----------------------------------------------------------------------===//

LogicalResult StreamOp::verify() {
  // We don't do any inter-procedural analysis for now.
  if (llvm::any_of((*this)->getUsers(),
                   [](Operation *user) { return isa<CallOpInterface>(user); }))
    return success();

  auto writeUses = getWriteUses();
  auto readUses = getReadUses();
  if (writeUses.size() != 1)
    return emitOpError("stream channel must be written exactly once");
  if (readUses.size() != 1)
    return emitOpError("stream channel must be read exactly once");

  auto writer = writeUses.front()->getOwner();
  auto reader = readUses.front()->getOwner();
  if (!crossRegionDominates(writer, reader))
    return emitOpError("writer doesn't properly dominate reader\nwriter: ")
           << *writer << "\nreader: " << *reader;
  return success();
}

LogicalResult StreamOp::canonicalize(StreamOp op, PatternRewriter &rewriter) {
  if (op.use_empty()) {
    rewriter.eraseOp(op);
    return success();
  }
  return failure();
}

void StreamOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Allocate::get(), getStream(),
                       SideEffects::DefaultResource::get());
}

template <typename Effect>
static SmallVector<OpOperand *> getEffectUses(TypedValue<StreamType> stream) {
  SmallVector<OpOperand *> uses;
  for (auto &use : stream.getUses()) {
    if (auto effectsUser = dyn_cast<MemoryEffectOpInterface>(use.getOwner()))
      if (effectsUser.getEffectOnValue<Effect>(stream))
        uses.push_back(&use);
  }
  return uses;
}

SmallVector<OpOperand *> StreamOp::getReadUses() {
  return getEffectUses<MemoryEffects::Read>(getStream());
}
SmallVector<OpOperand *> StreamOp::getWriteUses() {
  return getEffectUses<MemoryEffects::Write>(getStream());
}

hls::StreamReadOp StreamOp::getReader() {
  auto readUses = getReadUses();
  assert(readUses.size() == 1 && "stream must only have one read use");
  return cast<hls::StreamReadOp>(readUses.front()->getOwner());
}
hls::StreamWriteOp StreamOp::getWriter() {
  auto writeUses = getWriteUses();
  assert(writeUses.size() == 1 && "stream must only have one write use");
  return cast<hls::StreamWriteOp>(writeUses.front()->getOwner());
}

//===----------------------------------------------------------------------===//
// StreamReadOp
//===----------------------------------------------------------------------===//

LogicalResult StreamReadOp::verify() {
  if (getValueType() != getSourceType().getElementType())
    return emitOpError("value type doesn't align with stream type");
  return success();
}

void StreamReadOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Read::get(), getSource(),
                       SideEffects::DefaultResource::get());
}

//===----------------------------------------------------------------------===//
// StreamWriteOp
//===----------------------------------------------------------------------===//

LogicalResult StreamWriteOp::verify() {
  if (getValueType() != getDestType().getElementType())
    return emitOpError("value type doesn't align with stream type");
  return success();
}

void StreamWriteOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Write::get(), getDest(),
                       SideEffects::DefaultResource::get());
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
