//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Interfaces/ViewLikeInterface.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace bufferization;
using namespace scalehls;
using namespace hls;

/// Bufferization of schedule/task operation. Replace with a new schedule/task
/// that yields memrefs.
struct TaskOpInterface
    : public BufferizableOpInterface::ExternalModel<TaskOpInterface,
                                                    hls::TaskOp> {
  /// Schedule/task do not have tensor OpOperands. Thus, no OpOperand will be
  /// bufferized to memory read/write or be aliased to any returned values.
  AliasingValueList getAliasingValues(Operation *op, OpOperand &opOperand,
                                      const AnalysisState &state) const {
    return {};
  }

  // Schedule/task do not have tensor OpOperands. The yielded value can be any
  // SSA value that is in scope. To allow for use-def chain traversal in the
  // analysis, the yielded value is aliasing with the result.
  AliasingOpOperandList
  getAliasingOpOperands(Operation *op, Value value,
                        const AnalysisState &state) const {
    OpOperand *operand = &cast<hls::TaskOp>(op).getYieldOp()->getOpOperand(
        cast<OpResult>(value).getResultNumber());
    return {{operand, BufferRelation::Equivalent}};
  }

  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    OpBuilder::InsertionGuard g(rewriter);
    auto concreteOp = cast<hls::TaskOp>(op);

    // Compute bufferized result types.
    SmallVector<Type> newTypes;
    for (Value result : concreteOp.getResults()) {
      if (!result.getType().isa<TensorType>()) {
        newTypes.push_back(result.getType());
        continue;
      }
      auto bufferType = bufferization::getBufferType(result, options);
      if (failed(bufferType))
        return failure();
      newTypes.push_back(*bufferType);
    }

    // Create new schedule/task op.
    rewriter.setInsertionPoint(concreteOp);
    auto newOp = rewriter.create<hls::TaskOp>(concreteOp.getLoc(), newTypes,
                                              ValueRange());
    rewriter.inlineRegionBefore(concreteOp.getBody(), newOp.getBody(),
                                newOp.getBody().end());

    // Replace schedule/task op results.
    replaceOpWithBufferizedValues(rewriter, concreteOp, newOp->getResults());
    return success();
  }

  FailureOr<BaseMemRefType>
  getBufferType(Operation *op, Value value, const BufferizationOptions &options,
                SmallVector<Value> &invocationStack) const {
    assert(value.getDefiningOp() == op && "invalid value");
    auto yieldedValue = cast<hls::TaskOp>(op).getYieldOp()->getOperand(
        value.cast<OpResult>().getResultNumber());

    if (auto bufferType =
            yieldedValue.getType().template dyn_cast<BaseMemRefType>())
      return bufferType;

    auto maybeBufferType =
        bufferization::getBufferType(yieldedValue, options, invocationStack);
    if (failed(maybeBufferType))
      return failure();
    return *maybeBufferType;
  }
};

/// Bufferization of fdf.yield operation.
struct YieldOpInterface
    : public BufferizableOpInterface::ExternalModel<YieldOpInterface, YieldOp> {
  bool bufferizesToAllocation(Operation *op, Value value) const { return true; }

  bool bufferizesToMemoryRead(Operation *op, OpOperand &opOperand,
                              const AnalysisState &state) const {
    return true;
  }
  bool bufferizesToMemoryWrite(Operation *op, OpOperand &opOperand,
                               const AnalysisState &state) const {
    return false;
  }

  AliasingValueList getAliasingValues(Operation *op, OpOperand &opOperand,
                                      const AnalysisState &state) const {
    if (isa<TaskOp>(op->getParentOp()))
      return {{op->getParentOp()->getResult(opOperand.getOperandNumber()),
               BufferRelation::Equivalent}};
    return {};
  }

  bool mustBufferizeInPlace(Operation *op, OpOperand &opOperand,
                            const AnalysisState &state) const {
    // Yield operands always bufferize inplace. Otherwise, an alloc + copy may
    // be generated inside the block. We should not return/yield allocations
    // when possible.
    return true;
  }

  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    OpBuilder::InsertionGuard g(rewriter);
    auto yield = cast<YieldOp>(op);
    auto parent = yield->getParentOp();

    // Traverse and bufferize each operand of the yield operation.
    for (auto operand : yield.getOperands()) {
      if (!operand.getType().isa<TensorType>())
        continue;

      auto maybeBuffer = getBuffer(rewriter, operand, options);
      auto maybeType = bufferization::getBufferType(operand, options);
      if (failed(maybeBuffer) || failed(maybeType))
        continue;

      // For now, we always generate an explicit copy to handle view-like
      // operations. This is not efficient but it's safe.
      if (auto view = maybeBuffer->getDefiningOp<ViewLikeOpInterface>()) {
        rewriter.setInsertionPoint(parent);
        auto localBuffer = options.createAlloc(
            rewriter, yield.getLoc(), maybeType->cast<MemRefType>(), {});
        if (failed(localBuffer))
          return failure();

        rewriter.setInsertionPoint(yield);
        if (failed(options.createMemCpy(rewriter, yield.getLoc(), *maybeBuffer,
                                        *localBuffer)))
          return failure();

        rewriter.replaceUsesWithIf(operand, *localBuffer, [&](OpOperand &use) {
          return use.getOwner() == yield;
        });
      } else {
        rewriter.setInsertionPoint(yield);
        auto replacement = rewriter.create<bufferization::ToMemrefOp>(
            yield.getLoc(), *maybeType, operand);
        rewriter.replaceUsesWithIf(operand, replacement, [&](OpOperand &use) {
          return use.getOwner() == yield;
        });
      }
    }
    return success();
  }
};

/// Bufferization of fdf.tensor_init operation.
struct TensorInitOpInterface
    : public BufferizableOpInterface::ExternalModel<TensorInitOpInterface,
                                                    hls::TensorInitOp> {
  bool bufferizesToAllocation(Operation *op, Value value) const { return true; }

  bool resultBufferizesToMemoryWrite(Operation *op, OpResult opResult,
                                     const AnalysisState &state) const {
    return false;
  }

  AliasingValueList getAliasingValues(Operation *op, OpOperand &opOperand,
                                      const AnalysisState &state) const {
    // This is a new allocation. It does not alias with any other buffer.
    return {};
  }

  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    OpBuilder::InsertionGuard g(rewriter);
    auto tensorInit = cast<hls::TensorInitOp>(op);

    // Nothing to do for dead TensorInitOps.
    if (tensorInit->getUses().empty()) {
      rewriter.eraseOp(tensorInit);
      return success();
    }

    // Create memory allocation.
    auto maybeType =
        bufferization::getBufferType(tensorInit.getResult(), options);
    if (failed(maybeType))
      return failure();

    FailureOr<Value> buffer = options.createAlloc(
        rewriter, tensorInit.getLoc(), maybeType->cast<MemRefType>(), {});
    if (failed(buffer))
      return failure();

    // Handle initial value.
    if (auto initValue = tensorInit.getInitValue()) {
      auto initValueOp = initValue.getDefiningOp<arith::ConstantOp>();
      auto bufferOp = buffer->getDefiningOp<BufferOp>();
      if (!initValueOp || !bufferOp)
        return failure();
      bufferOp.setInitValueAttr(initValueOp.getValue());
    }

    // Replace op.
    replaceOpWithBufferizedValues(rewriter, tensorInit, *buffer);
    return success();
  }

  FailureOr<BaseMemRefType>
  getBufferType(Operation *op, Value value, const BufferizationOptions &options,
                SmallVector<Value> &invocationStack) const {
    auto tensorInit = cast<hls::TensorInitOp>(op);
    assert(value == tensorInit.getResult() && "invalid value");

    // Compute memory space of this allocation.
    Attribute memorySpace;
    if (options.defaultMemorySpace.has_value())
      memorySpace = *options.defaultMemorySpace;
    else
      return tensorInit.emitError("could not infer memory space");

    return getMemRefTypeWithStaticIdentityLayout(tensorInit.getType(),
                                                 memorySpace);
  }
};

void mlir::scalehls::hls::registerBufferizableOpInterfaceExternalModels(
    DialectRegistry &registry) {
  registry.addExtension(+[](MLIRContext *ctx, HLSDialect *dialect) {
    TaskOp::attachInterface<TaskOpInterface>(*ctx);
    YieldOp::attachInterface<YieldOpInterface>(*ctx);
    hls::TensorInitOp::attachInterface<TensorInitOpInterface>(*ctx);
  });
}
