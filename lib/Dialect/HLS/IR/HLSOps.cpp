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

LogicalResult TensorInitOp::canonicalize(TensorInitOp op,
                                         PatternRewriter &rewriter) {
  if (op->hasOneUse())
    return failure();

  for (auto &use : llvm::make_early_inc_range(op->getUses())) {
    rewriter.setInsertionPoint(use.getOwner());
    auto newOp = cast<hls::TensorInitOp>(rewriter.clone(*op));
    rewriter.replaceUsesWithIf(
        op.getResult(), newOp.getResult(),
        [&](OpOperand &operand) { return operand == use; });
  }
  rewriter.eraseOp(op);
  return success();
}

//===----------------------------------------------------------------------===//
// StreamOp
//===----------------------------------------------------------------------===//

template <typename Effect>
static void recursivelyGetEffectUses(TypedValue<StreamType> stream,
                                     SmallVectorImpl<OpOperand *> &uses) {
  for (auto &use : stream.getUses()) {
    if (auto viewUser = dyn_cast<StreamViewLikeInterface>(use.getOwner()))
      recursivelyGetEffectUses<Effect>(viewUser.getResult(), uses);
    else if (auto effectsUser =
                 dyn_cast<MemoryEffectOpInterface>(use.getOwner()))
      if (effectsUser.getEffectOnValue<Effect>(stream))
        uses.push_back(&use);
  }
}

SmallVector<OpOperand *> StreamOp::getReadUses() {
  SmallVector<OpOperand *> readUses;
  recursivelyGetEffectUses<MemoryEffects::Read>(getStream(), readUses);
  return readUses;
}

SmallVector<OpOperand *> StreamOp::getWriteUses() {
  SmallVector<OpOperand *> writeUses;
  recursivelyGetEffectUses<MemoryEffects::Write>(getStream(), writeUses);
  return writeUses;
}

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

//===----------------------------------------------------------------------===//
// StreamToTensorOp
//===----------------------------------------------------------------------===//

LogicalResult StreamToTensorOp::verify() {
  if (!getSourceType().isConvertableWith(getTensorType()))
    return emitOpError("stream type is not convertable with tensor type");
  return success();
}

void StreamToTensorOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Read::get(), getSource(),
                       SideEffects::DefaultResource::get());
}

//===----------------------------------------------------------------------===//
// TensorToStreamOp
//===----------------------------------------------------------------------===//

LogicalResult TensorToStreamOp::verify() {
  auto verifyDestsResult = verifyDests();
  if (failed(verifyDestsResult))
    return verifyDestsResult;

  if (!getDestType().isConvertableWith(getTensorType()))
    return emitOpError("stream type is not convertable with tensor type");
  return success();
}

void TensorToStreamOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  for (auto dest : getDests())
    effects.emplace_back(MemoryEffects::Write::get(), dest,
                         SideEffects::DefaultResource::get());
}

StreamWriteLikeInterface
TensorToStreamOp::cloneWith(ValueRange dests, PatternRewriter &rewriter) {
  return rewriter.create<TensorToStreamOp>(getLoc(), getTensor(), dests);
}

//===----------------------------------------------------------------------===//
// StreamReadOp
//===----------------------------------------------------------------------===//

static LogicalResult verifyTripCountsAndSteps(Operation *op,
                                              TypedValue<StreamType> stream) {
  auto streamType = stream.getType();
  if (!streamType.hasIterInfo())
    return success();

  auto loops = getSurroundingLoops(op, stream.getParentBlock());
  auto tripCounts = getLoopTripCounts(loops);
  auto steps = getLoopSteps(loops);
  if (!tripCounts || !steps)
    return op->emitOpError("iteration trip counts or steps not available");

  auto stripedLoopInfo =
      llvm::make_filter_range(llvm::zip(*tripCounts, *steps), [](auto tuple) {
        return std::get<0>(tuple) != 1;
      });

  auto stripedIterInfo = llvm::make_filter_range(
      llvm::zip(streamType.getIterTripCounts(), streamType.getIterSteps()),
      [](auto tuple) { return std::get<0>(tuple) != 1; });

  if (std::distance(stripedLoopInfo.begin(), stripedLoopInfo.end()) !=
          std::distance(stripedIterInfo.begin(), stripedIterInfo.end()) ||
      llvm::any_of(llvm::zip(stripedLoopInfo, stripedIterInfo), [](auto tuple) {
        return std::get<0>(tuple) != std::get<1>(tuple);
      }))
    return op->emitOpError("loop trip counts or steps doesn't align with "
                           "stream iteration\nloop trip counts: ")
           << *tripCounts << ", steps: " << *steps
           << "\nstream iteration trip counts: "
           << streamType.getIterTripCounts()
           << ", steps: " << streamType.getIterSteps();
  return success();
}

LogicalResult StreamReadOp::verify() {
  if (getSourceType().getElementType() != getValueType())
    return emitOpError("value type doesn't align with channel type");
  if (getInitType() && getInitType() != getValueType())
    return emitOpError("initial value type doesn't align with value type");
  return verifyTripCountsAndSteps(*this, getSource());
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
  auto verifyDestsResult = verifyDests();
  if (failed(verifyDestsResult))
    return verifyDestsResult;

  if (getDestType().getElementType() != getValueType())
    return emitOpError("value type doesn't align with channel type");
  for (auto dest : getDests()) {
    auto verifyIterationResult =
        verifyTripCountsAndSteps(*this, cast<TypedValue<StreamType>>(dest));
    if (failed(verifyIterationResult))
      return verifyIterationResult;
  }
  return success();
}

void StreamWriteOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  for (auto dest : getDests())
    effects.emplace_back(MemoryEffects::Write::get(), dest,
                         SideEffects::DefaultResource::get());
}

StreamWriteLikeInterface StreamWriteOp::cloneWith(ValueRange dests,
                                                  PatternRewriter &rewriter) {
  return rewriter.create<StreamWriteOp>(getLoc(), getValue(), dests);
}

//===----------------------------------------------------------------------===//
// StreamBufferOp
//===----------------------------------------------------------------------===//

LogicalResult StreamBufferOp::verify() {
  auto verifyDestsResult = verifyDests();
  if (failed(verifyDestsResult))
    return verifyDestsResult;

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

LogicalResult StreamBufferOp::canonicalize(StreamBufferOp op,
                                           PatternRewriter &rewriter) {
  if (op.getSourceType() == op.getDestType()) {
    rewriter.replaceOpWithNewOp<StreamForkOp>(op, op.getSource(),
                                              op.getDests());
    return success();
  }
  return failure();
}

void StreamBufferOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Read::get(), getSource(),
                       SideEffects::DefaultResource::get());
  for (auto dest : getDests())
    effects.emplace_back(MemoryEffects::Write::get(), dest,
                         SideEffects::DefaultResource::get());
}

StreamWriteLikeInterface StreamBufferOp::cloneWith(ValueRange dests,
                                                   PatternRewriter &rewriter) {
  return rewriter.create<StreamBufferOp>(
      getLoc(), getSource(), dests, getBufferElementType(), getBufferShape(),
      getLoopIndex(), getDimIndex());
}

//===----------------------------------------------------------------------===//
// StreamForkOp
//===----------------------------------------------------------------------===//

LogicalResult StreamForkOp::verify() {
  auto verifyDestsResult = verifyDests();
  if (failed(verifyDestsResult))
    return verifyDestsResult;

  if (getDestType() != getSourceType())
    return emitOpError("dest type doesn't align with source type");
  return success();
}

namespace {
struct EliminateSingleDestForkOp : public OpRewritePattern<StreamForkOp> {
  using OpRewritePattern<StreamForkOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(StreamForkOp streamFork,
                                PatternRewriter &rewriter) const override {
    if (llvm::hasSingleElement(streamFork.getDests())) {
      rewriter.replaceAllUsesExcept(streamFork.getDest(0),
                                    streamFork.getSource(), streamFork);
      rewriter.eraseOp(streamFork);
      return success();
    }
    return failure();
  }
};

struct ForwardForkOpBeforeViewLikeOp : public OpRewritePattern<StreamForkOp> {
  using OpRewritePattern<StreamForkOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(StreamForkOp streamFork,
                                PatternRewriter &rewriter) const override {
    if (auto streamView =
            streamFork.getSource().getDefiningOp<StreamViewLikeInterface>()) {
      rewriter.replaceUsesWithIf(
          streamView.getResult(), streamView.getSource(),
          [&](OpOperand &operand) { return operand.getOwner() == streamFork; });

      rewriter.setInsertionPointAfter(streamFork);
      for (auto dest : streamFork.getDests()) {
        assert(dest.getDefiningOp<StreamOp>() &&
               "destination is not a stream channel");
        dest.setType(streamView.getSourceType());

        auto destStreamView = streamView.cloneWith(dest, rewriter);
        rewriter.replaceUsesWithIf(
            dest, destStreamView.getResult(), [&](OpOperand &operand) {
              return operand.getOwner() != destStreamView &&
                     operand.getOwner() != streamFork;
            });
      }
      return success();
    }
    return failure();
  }
};

struct FuseForkOpIntoWriteLikeOp : public OpRewritePattern<StreamForkOp> {
  using OpRewritePattern<StreamForkOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(StreamForkOp streamFork,
                                PatternRewriter &rewriter) const override {
    if (auto sourceStream = streamFork.getSource().getDefiningOp<StreamOp>()) {
      auto streamWrite = dyn_cast<StreamWriteLikeInterface>(
          sourceStream.getSingleWriteUse()->getOwner());
      assert(streamWrite && "source stream is not written");

      SmallVector<Value> newDests;
      for (auto dest : streamWrite.getDests())
        if (dest != streamFork.getSource())
          newDests.push_back(dest);

      for (auto dest : streamFork.getDests()) {
        auto destStream = dest.getDefiningOp<StreamOp>();
        assert(destStream && "destination is not a stream channel");
        destStream->moveAfter(sourceStream);
        newDests.push_back(dest);
      }

      rewriter.setInsertionPoint(streamWrite);
      rewriter.replaceOp(streamWrite,
                         streamWrite.cloneWith(newDests, rewriter));
      rewriter.eraseOp(streamFork);
      return success();
    }
    return failure();
  }
};
} // namespace

void StreamForkOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                               MLIRContext *context) {
  results.add<EliminateSingleDestForkOp>(context);
  results.add<ForwardForkOpBeforeViewLikeOp>(context);
  results.add<FuseForkOpIntoWriteLikeOp>(context);
}

void StreamForkOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Read::get(), getSource(),
                       SideEffects::DefaultResource::get());
  for (auto dest : getDests())
    effects.emplace_back(MemoryEffects::Write::get(), dest,
                         SideEffects::DefaultResource::get());
}

StreamWriteLikeInterface StreamForkOp::cloneWith(ValueRange dests,
                                                 PatternRewriter &rewriter) {
  return rewriter.create<StreamForkOp>(getLoc(), getSource(), dests);
}

//===----------------------------------------------------------------------===//
// StreamReassociateOp
//===----------------------------------------------------------------------===//

LogicalResult StreamReassociateOp::verify() {
  if (!getSourceType().hasIterInfo() || !getResultType().hasIterInfo())
    return emitOpError("input and output must have iteration information");

  if (getSourceType().getDataType() != getResultType().getDataType())
    return emitOpError("input and output data type doesn't match");

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

OpFoldResult StreamReassociateOp::fold(FoldAdaptor adaptor) {
  return foldRedundantViews();
}

//===----------------------------------------------------------------------===//
// StreamCastOp
//===----------------------------------------------------------------------===//

LogicalResult StreamCastOp::verify() {
  if (!getSourceType().isCastableWith(getResultType())) {
    return emitOpError("input and output are not castable\ninput shape: ")
           << getSourceType().getShape()
           << ", output shape: " << getResultType().getShape();
  }
  return success();
}

OpFoldResult StreamCastOp::fold(FoldAdaptor adaptor) {
  return foldRedundantViews();
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
