//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

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
Optional<TypedAttr> BufferOp::getBufferInitValue() { return getInitValue(); }

void BufferOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Allocate::get(), getMemref(),
                       SideEffects::DefaultResource::get());
}

int32_t ConstBufferOp::getBufferDepth() { return 1; }
Optional<TypedAttr> ConstBufferOp::getBufferInitValue() {
  return Optional<TypedAttr>();
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

//===----------------------------------------------------------------------===//
// StreamOp, StreamReadOp, and StreamWriteOp
//===----------------------------------------------------------------------===//

LogicalResult StreamOp::verify() {
  if (getDepth() != getChannel().getType().cast<StreamType>().getDepth())
    return emitOpError("stream channel depth is not aligned");
  return success();
}

void StreamOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  effects.emplace_back(MemoryEffects::Allocate::get(), getChannel(),
                       SideEffects::DefaultResource::get());
}

LogicalResult StreamReadOp::verify() {
  if (getResult())
    if (getChannel().getType().cast<StreamType>().getElementType() !=
        getResult().getType())
      return emitOpError("result type doesn't align with channel type");
  return success();
}

// void StreamReadOp::getEffects(
//     SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
//         &effects) {
//   effects.emplace_back(MemoryEffects::Read::get(), getChannel(),
//                        SideEffects::DefaultResource::get());
// }

LogicalResult StreamWriteOp::verify() {
  if (getChannel().getType().cast<StreamType>().getElementType() !=
      getValue().getType())
    return emitOpError("value type doesn't align with channel type");
  return success();
}

// void StreamWriteOp::getEffects(
//     SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
//         &effects) {
//   effects.emplace_back(MemoryEffects::Write::get(), getChannel(),
//                        SideEffects::DefaultResource::get());
// }

//===----------------------------------------------------------------------===//
// BufferVectorizeOp and BufferDevectorizeOp
//===----------------------------------------------------------------------===//

LogicalResult
verifyVectorizationTypes(function_ref<InFlightDiagnostic()> emitError,
                         MemRefType type, MemRefType vectorizedType) {
  auto vectorType = vectorizedType.getElementType().dyn_cast<VectorType>();
  if (!vectorType || vectorType.getElementType() != type.getElementType())
    return emitError() << "vectorized type must have vector elements with the "
                          "same data type";

  auto layout = type.getLayout().dyn_cast<TileLayoutAttr>();
  auto vectorizedLayout = vectorizedType.getLayout().dyn_cast<TileLayoutAttr>();
  if (!layout || !vectorizedLayout)
    return emitError() << "input and output types must have tile layout";

  for (auto [tileSize, vectorSize, vectorizedTileSize] :
       llvm::zip(layout.getTileShape(), layout.getVectorShape(),
                 vectorizedLayout.getTileShape()))
    if (tileSize != vectorSize * vectorizedTileSize)
      return emitError() << "tile layout mismatch";

  for (auto [size, vectorizedSize, vectorSize] : llvm::zip(
           type.getShape(), vectorizedType.getShape(), layout.getVectorShape()))
    if (size != vectorizedSize * vectorSize)
      return emitError() << "vector shape mismatch";

  unsigned vectorNumElements = 1;
  for (auto dim : layout.getVectorShape())
    vectorNumElements *= dim;
  if (vectorNumElements != vectorType.getNumElements())
    return emitError() << "number of elements mismatch";

  return success();
}

LogicalResult BufferVectorizeOp::verify() {
  return verifyVectorizationTypes([&]() { return emitOpError(); },
                                  getInputType(), getType());
}

LogicalResult BufferDevectorizeOp::verify() {
  return verifyVectorizationTypes([&]() { return emitOpError(); }, getType(),
                                  getInputType());
}

OpFoldResult BufferVectorizeOp::fold(FoldAdaptor adaptor) {
  if (auto devectorize = getInput().getDefiningOp<BufferDevectorizeOp>())
    if (devectorize.getInputType() == getType())
      return devectorize.getInput();
  return {};
}
