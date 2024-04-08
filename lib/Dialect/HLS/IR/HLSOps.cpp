//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/Liveness.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
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
    if (initValue.value().getType() != getType().getElementType())
      return emitOpError("initial value's type doesn't align with tensor type");
  return success();
}

//===----------------------------------------------------------------------===//
// TensorInstanceOp
//===----------------------------------------------------------------------===//

LogicalResult TensorInstanceOp::verify() {
  if (auto initValue = getInitValue())
    if (initValue.value().getType() != getType().getElementType())
      return emitOpError("initial value's type doesn't align with tensor type");
  if (!(*this)->hasOneUse())
    return emitOpError("tensor instance should have exactly one use");
  if (!getSingleUser<TaskOp>())
    return emitOpError("tensor instance should be used by a task, but found")
           << *getSingleUser();
  return success();
}

//===----------------------------------------------------------------------===//
// ITensorInitOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorInitOp::verify() {
  if (auto initValue = getInitValue())
    if (initValue.value().getType() != getType().getDataType())
      return emitOpError("initial value doesn't align with itensor data type");
  return success();
}

//===----------------------------------------------------------------------===//
// ITensorInstanceOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorInstanceOp::verify() {
  if (auto initValue = getInitValue())
    if (initValue.value().getType() != getType().getDataType())
      return emitOpError("initial value doesn't align with itensor data type");
  if (!(*this)->hasOneUse())
    return emitOpError("itensor instance should have exactly one use");
  if (!getSingleUser<TaskOp>())
    return emitOpError("tensor instance should be used by a task, but found")
           << *getSingleUser();
  return success();
}

//===----------------------------------------------------------------------===//
// ITensorReadFullTensorOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorReadFullTensorOp::verify() {
  if (getFullTensorInitType() != getFullTensorType())
    return emitOpError("initial tensor type doesn't align with tensor type");
  if (!getSourceType().isConvertableWith(getFullTensorType(), getPacked()))
    return emitOpError("itensor type is not convertable with full tensor type");
  return success();
}

MutableOperandRange ITensorReadFullTensorOp::getDpsInitsMutable() {
  return getFullTensorInitMutable();
}

//===----------------------------------------------------------------------===//
// ITensorWriteFullTensorOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorWriteFullTensorOp::verify() {
  if (getDestType() != getResultType())
    return emitOpError("initial itensor type doesn't align with result type");
  if (!getResultType().isConvertableWith(getFullTensorType(), getPacked()))
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
                                              OpOperand *iTensor) {
  auto iTensorType = cast<ITensorType>(iTensor->get().getType());
  auto untiledITensor = getUntiledOperand(iTensor);

  auto loops = getSurroundingLoops(op, untiledITensor->get().getParentBlock());
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
  if (isa<RankedTensorType>(getValueType())) {
    if (!getInit())
      return emitOpError("missing initial tensor for tensor read");
    if (getInitType() != getValueType())
      return emitOpError("initial tensor type doesn't align with value type");
  }
  return verifyTripCountsAndSteps(*this, &getSourceMutable());
}

MutableOperandRange ITensorReadOp::getDpsInitsMutable() {
  return getInitMutable();
}

//===----------------------------------------------------------------------===//
// ITensorWriteOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorWriteOp::verify() {
  if (getDestType() != getResultType())
    return emitOpError("initial itensor type doesn't align with result type");
  if (getDestType().getElementType() != getValueType())
    return emitOpError("value type doesn't align with itensor type");
  return verifyTripCountsAndSteps(*this, &getDestMutable());
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

  if (getBufferElementType() != sourceType.getDataType())
    return emitOpError(
        "buffer element type doesn't align with itensor data type");

  if (getLoopIndex() > sourceType.getIterRank())
    return emitOpError("buffer loop index is out of loop range");

  SmallVector<int64_t> bufferShape(getBufferShape());
  if (getPacked()) {
    auto unpackedType = getUnpackedType(getBufferType(), getPackSizes());
    bufferShape = SmallVector<int64_t>(unpackedType.getRank(), 1);
    bufferShape.append(unpackedType.getShape().begin(),
                       unpackedType.getShape().end());
  }

  auto sourceShape = sourceType.getShape();
  for (auto [dim, bufferSize, dimSize, sourceTileSize, destTileSize] :
       llvm::zip(llvm::seq(sourceShape.size()), bufferShape, sourceShape,
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

LogicalResult ITensorReassociateOp::canonicalize(ITensorReassociateOp op,
                                                 PatternRewriter &rewriter) {
  if (auto init = op.getSource().getDefiningOp<ITensorInitOp>()) {
    rewriter.replaceOpWithNewOp<ITensorInitOp>(op, op.getResultType(),
                                               init.getInitValueAttr());
    return success();
  }
  return failure();
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
// ITensorForkOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorForkOp::verify() {
  if (llvm::any_of(getResultTypes(),
                   [&](Type type) { return type != getSourceType(); }))
    return emitOpError("source and result itensor type doesn't match");
  for (auto result : getResults())
    if (!result.hasOneUse())
      return emitOpError("result itensor must have exactly one use but found ")
             << llvm::range_size(result.getUses());
  return success();
}

LogicalResult
ITensorForkOp::fold(FoldAdaptor adaptor,
                    SmallVectorImpl<::mlir::OpFoldResult> &results) {
  if (getNumResults() == 1) {
    results.push_back(getSource());
    return success();
  } else if (auto merge = getSource().getDefiningOp<ITensorJoinOp>()) {
    if (merge.getNumSources() == getNumResults()) {
      for (auto source : merge.getSources())
        results.push_back(source);
      return success();
    }
  }
  return failure();
}

//===----------------------------------------------------------------------===//
// ITensorJoinOp
//===----------------------------------------------------------------------===//

LogicalResult ITensorJoinOp::verify() {
  if (llvm::any_of(getSourceTypes(),
                   [&](Type type) { return type != getResultType(); }))
    return emitOpError("source and result itensor type doesn't match");
  return success();
}

OpFoldResult ITensorJoinOp::fold(FoldAdaptor adaptor) {
  if (getNumSources() == 1)
    return getSources().front();
  return {};
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
// BufferOp
//===----------------------------------------------------------------------===//

LogicalResult BufferOp::canonicalize(BufferOp op, PatternRewriter &rewriter) {
  if (op.use_empty()) {
    rewriter.eraseOp(op);
    return success();
  }
  return failure();
}

LogicalResult BufferOp::verify() {
  if (auto initValue = getInitValue())
    if (initValue.value().getType() != getType().getElementType())
      return emitOpError("initial value's type doesn't align with memref type");
  return success();
}

void BufferOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Allocate::get(), getMemref(),
                       SideEffects::DefaultResource::get());
}

//===----------------------------------------------------------------------===//
// TaskOp
//===----------------------------------------------------------------------===//

namespace {
struct FoldTaskIterArgs : public OpRewritePattern<hls::TaskOp> {
  using OpRewritePattern<hls::TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TaskOp task,
                                PatternRewriter &rewriter) const final {
    bool canonicalize = false;

    // An internal flat vector of block transfer
    // arguments `newBlockTransferArgs` keeps the 1-1 mapping of original to
    // transformed block argument mappings. This plays the role of a
    // IRMapping for the particular use case of calling into
    // `inlineBlockBefore`.
    int64_t numResults = task.getNumResults();
    SmallVector<bool, 4> keepMask;
    keepMask.reserve(numResults);
    SmallVector<Value, 4> newBlockTransferArgs, newIterArgs, newYieldValues,
        newResultValues;
    newBlockTransferArgs.reserve(numResults);
    newIterArgs.reserve(task.getInits().size());
    newYieldValues.reserve(numResults);
    newResultValues.reserve(numResults);
    for (auto [initOperand, iterArg, result, yieldedValue] :
         llvm::zip(task.getInits(), task.getBody().getArguments(),
                   task.getResults(), task.getYieldOp().getOperands())) {
      // Forwarded is `true` when:
      // 1) The region `iter` argument is yielded.
      // 2) The region `iter` argument has no use, and the corresponding iter
      // operand (input) is yielded.
      // 3) The region `iter` argument has no use, and the corresponding op
      // result has no use.
      bool forwarded = ((iterArg == yieldedValue) ||
                        (iterArg.use_empty() &&
                         (initOperand == yieldedValue || result.use_empty())));
      keepMask.push_back(!forwarded);
      canonicalize |= forwarded;
      if (forwarded) {
        newBlockTransferArgs.push_back(initOperand);
        newResultValues.push_back(initOperand);
        continue;
      }
      newIterArgs.push_back(initOperand);
      newYieldValues.push_back(yieldedValue);
      newBlockTransferArgs.push_back(Value()); // placeholder with null value
      newResultValues.push_back(Value());      // placeholder with null value
    }

    if (!canonicalize)
      return failure();

    TaskOp newtask =
        rewriter.create<TaskOp>(task.getLoc(), newIterArgs, task.getNameAttr());
    newtask->setAttrs(task->getAttrs());
    Block *newBlock = rewriter.createBlock(
        &newtask.getBody(), newtask.getBody().begin(), TypeRange(newIterArgs),
        llvm::map_to_vector(newIterArgs, [&](Value v) { return v.getLoc(); }));
    if (newIterArgs.empty()) {
      rewriter.setInsertionPointToEnd(newBlock);
      rewriter.create<hls::YieldOp>(task.getLoc(), newYieldValues);
    }

    // Replace the null placeholders with newly constructed values.
    for (unsigned idx = 0, collapsedIdx = 0, e = newResultValues.size();
         idx != e; ++idx) {
      Value &blockTransferArg = newBlockTransferArgs[idx];
      Value &newResultVal = newResultValues[idx];
      assert((blockTransferArg && newResultVal) ||
             (!blockTransferArg && !newResultVal));
      if (!blockTransferArg) {
        blockTransferArg = newtask.getBody().getArgument(collapsedIdx);
        newResultVal = newtask.getResult(collapsedIdx++);
      }
    }

    Block &oldBlock = task.getRegion().front();
    assert(oldBlock.getNumArguments() == newBlockTransferArgs.size() &&
           "unexpected argument size mismatch");

    // No results case: the scf::task builder already created a zero
    // result terminator. Join before this terminator and just get rid of the
    // original terminator that has been merged in.
    if (newIterArgs.empty()) {
      auto newYieldOp = newtask.getYieldOp();
      rewriter.inlineBlockBefore(&oldBlock, newYieldOp, newBlockTransferArgs);
      rewriter.eraseOp(newBlock->getTerminator()->getPrevNode());
      rewriter.replaceOp(task, newResultValues);
      return success();
    }

    // No terminator case: merge and rewrite the merged terminator.
    auto cloneFilteredTerminator = [&](hls::YieldOp mergedTerminator) {
      OpBuilder::InsertionGuard g(rewriter);
      rewriter.setInsertionPoint(mergedTerminator);
      SmallVector<Value, 4> filteredOperands;
      filteredOperands.reserve(newResultValues.size());
      for (unsigned idx = 0, e = keepMask.size(); idx < e; ++idx)
        if (keepMask[idx])
          filteredOperands.push_back(mergedTerminator.getOperand(idx));
      rewriter.create<hls::YieldOp>(mergedTerminator.getLoc(),
                                    filteredOperands);
    };

    rewriter.mergeBlocks(&oldBlock, newBlock, newBlockTransferArgs);
    auto mergedYieldOp = newtask.getYieldOp();
    cloneFilteredTerminator(mergedYieldOp);
    rewriter.eraseOp(mergedYieldOp);
    rewriter.replaceOp(task, newResultValues);
    return success();
  }
};
} // namespace

namespace {
struct InlineTask : public OpRewritePattern<hls::TaskOp> {
  InlineTask(MLIRContext *context,
             llvm::function_ref<bool(hls::TaskOp)> condition)
      : OpRewritePattern<hls::TaskOp>(context), condition(condition) {}

  LogicalResult matchAndRewrite(hls::TaskOp task,
                                PatternRewriter &rewriter) const override {
    if (condition(task)) {
      Block *block = &task.getBody().front();
      YieldOp yieldOp = task.getYieldOp();
      ValueRange yieldedValue = yieldOp.getOperands();
      rewriter.inlineBlockBefore(block, task, task.getInits());
      rewriter.replaceOp(task, yieldedValue);
      rewriter.eraseOp(yieldOp);
      return success();
    }
    return failure();
  }

private:
  llvm::function_ref<bool(hls::TaskOp)> condition;
};
} // namespace

void TaskOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.add<FoldTaskIterArgs>(context);
  results.add<InlineTask>(context, [](TaskOp task) {
    return task.isSingleTask() && !isa<func::FuncOp>(task->getParentOp());
  });
}

LogicalResult TaskOp::verify() {
  if (getResultTypes() != getYieldOp()->getOperandTypes())
    return emitOpError("yield type doesn't align with result type");
  if (getResultTypes() != getInitTypes())
    return emitOpError("init type doesn't align with result type");
  return success();
}

/// Return the yield op of this task op.
YieldOp TaskOp::getYieldOp() {
  return cast<YieldOp>(this->getRegion().front().getTerminator());
}

/// Get the live-ins of the task op.
llvm::SmallPtrSet<Value, 16> TaskOp::getLiveIns() {
  auto liveness = Liveness(*this);
  llvm::SmallPtrSet<Value, 16> liveIns;
  for (auto liveIn : liveness.getLiveIn(&this->getBody().front()))
    if (liveIn.getParentRegion()->isProperAncestor(&getBody()))
      liveIns.insert(liveIn);
  return liveIns;
}
