//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace bufferization;
using namespace scalehls;
using namespace hls;

/// Bufferization of dispatch/task operation. Replace with a new dispatch/task
/// that yields memrefs.
template <typename OpType>
struct DispatchOrTaskOpInterface
    : public BufferizableOpInterface::ExternalModel<
          DispatchOrTaskOpInterface<OpType>, OpType> {
  AliasingOpOperandList
  getAliasingOpOperands(Operation *op, Value value,
                        const AnalysisState &state) const {
    // Dispatch/task do not have tensor OpOperands. The yielded value can be any
    // SSA value that is in scope. To allow for use-def chain traversal in the
    // analysis, the yielded value is aliasing with the result.
    size_t resultNum = std::distance(op->getOpResults().begin(),
                                     llvm::find(op->getOpResults(), value));
    OpOperand *operand =
        &cast<OpType>(op).getYieldOp()->getOpOperand(resultNum);
    return {{operand, BufferRelation::Equivalent}};
  }

  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    OpBuilder::InsertionGuard g(rewriter);
    auto task = cast<OpType>(op);

    // Compute bufferized result types.
    SmallVector<Type> newTypes;
    for (Value result : task.getResults()) {
      if (!result.getType().isa<TensorType>()) {
        newTypes.push_back(result.getType());
        continue;
      }
      auto bufferType = bufferization::getBufferType(result, options);
      if (failed(bufferType))
        return failure();
      newTypes.push_back(*bufferType);
    }

    // Create new dispatch/task op.
    rewriter.setInsertionPoint(task);
    auto newTask = rewriter.create<OpType>(task.getLoc(), newTypes);
    rewriter.inlineRegionBefore(task.getBody(), newTask.getBody(),
                                newTask.getBody().end());

    // Replace dispatch/task op results.
    replaceOpWithBufferizedValues(rewriter, op, newTask->getResults());
    return success();
  }

  FailureOr<BaseMemRefType>
  getBufferType(Operation *op, Value value, const BufferizationOptions &options,
                SmallVector<Value> &invocationStack) const {
    assert(value.getDefiningOp() == op && "invalid value");
    auto yieldedValue = cast<OpType>(op).getYieldOp().getOperand(
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

/// Bufferization of fdf.yield operation. Bufferized as part of their enclosing
/// ops, so this is for analysis only.
struct YieldOpInterface
    : public BufferizableOpInterface::ExternalModel<YieldOpInterface, YieldOp> {
  bool bufferizesToMemoryRead(Operation *op, OpOperand &opOperand,
                              const AnalysisState &state) const {
    return true;
  }

  bool bufferizesToMemoryWrite(Operation *op, OpOperand &opOperand,
                               const AnalysisState &state) const {
    return false;
  }

  AliasingValueList getAliasingOpResults(Operation *op, OpOperand &opOperand,
                                         const AnalysisState &state) const {
    if (isa<DispatchOp, TaskOp>(op->getParentOp()))
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
    SmallVector<Value> newResults;
    for (const auto value : cast<YieldOp>(op).getResults()) {
      if (value.getType().isa<TensorType>()) {
        FailureOr<Value> maybeBuffer = getBuffer(rewriter, value, options);
        if (failed(maybeBuffer))
          return failure();
        newResults.push_back(*maybeBuffer);
      } else {
        newResults.push_back(value);
      }
    }
    replaceOpWithNewBufferizedOp<YieldOp>(rewriter, op, newResults);
    return success();
  }
};

/// Bufferization of fdf.alloc_tensor operation.
struct AllocTensorOpInterface
    : public BufferizableOpInterface::ExternalModel<AllocTensorOpInterface,
                                                    AllocTensorOp> {
  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    OpBuilder::InsertionGuard g(rewriter);
    auto allocTensor = cast<AllocTensorOp>(op);

    // Nothing to do for dead AllocTensorOps.
    if (allocTensor->getUses().empty()) {
      rewriter.eraseOp(allocTensor);
      return success();
    }

    // Create memory allocation.
    auto allocType =
        bufferization::getBufferType(allocTensor.getResult(), options);
    if (failed(allocType))
      return failure();
    FailureOr<Value> buffer = options.createAlloc(
        rewriter, allocTensor.getLoc(), allocType->cast<MemRefType>(), {});
    if (failed(buffer))
      return failure();

    // Handle initial value.
    if (auto initValue = allocTensor.getInitValue()) {
      auto initValueOp = initValue.getDefiningOp<arith::ConstantOp>();
      auto bufferOp = buffer->getDefiningOp<BufferOp>();
      if (!initValueOp || !bufferOp)
        return failure();
      bufferOp.setInitValueAttr(initValueOp.getValue());
    }

    // Replace op.
    replaceOpWithBufferizedValues(rewriter, allocTensor, *buffer);
    return success();
  }

  bool resultBufferizesToMemoryWrite(Operation *op, OpResult opResult,
                                     const AnalysisState &state) const {
    return false;
  }

  bool bufferizesToAllocation(Operation *op, Value value) const { return true; }

  AliasingValueList getAliasingOpResults(Operation *op, OpOperand &opOperand,
                                         const AnalysisState &state) const {
    // This is a new allocation. It does not alias with any other buffer.
    return {};
  }

  FailureOr<BaseMemRefType>
  getBufferType(Operation *op, Value value, const BufferizationOptions &options,
                SmallVector<Value> &invocationStack) const {
    auto allocTensor = cast<AllocTensorOp>(op);
    assert(value == allocTensor.getResult() && "invalid value");

    // Compute memory space of this allocation.
    Attribute memorySpace;
    if (options.defaultMemorySpace.has_value())
      memorySpace = *options.defaultMemorySpace;
    else
      return allocTensor.emitError("could not infer memory space");

    return getMemRefTypeWithStaticIdentityLayout(allocTensor.getType(),
                                                 memorySpace);
  }
};

/// Bufferization of uip.instance operation.
struct InstanceOpInterface
    : public BufferizableOpInterface::ExternalModel<InstanceOpInterface,
                                                    InstanceOp> {
  bool bufferizesToMemoryRead(Operation *op, OpOperand &opOperand,
                              const AnalysisState &state) const {
    auto instance = cast<InstanceOp>(op);
    return instance.getPortKind(opOperand) == PortKind::INPUT;
  }

  bool bufferizesToMemoryWrite(Operation *op, OpOperand &opOperand,
                               const AnalysisState &state) const {
    auto instance = cast<InstanceOp>(op);
    return instance.getPortKind(opOperand) == PortKind::OUTPUT;
  }

  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    // Take a guard before anything else.
    OpBuilder::InsertionGuard g(rewriter);
    auto instance = cast<InstanceOp>(op);
    rewriter.setInsertionPoint(instance);

    // New buffer operands for the cloned op.
    SmallVector<Value> newBuffers;
    SmallVector<Value> newOutputBuffers;
    newBuffers.reserve(instance.getNumOperands());
    for (auto &port : instance->getOpOperands()) {
      // For param ports, we just use the original value.
      auto kind = instance.getPortKind(port);
      if (kind == PortKind::PARAM) {
        newBuffers.push_back(port.get());
        continue;
      }

      // For input/output ports, we need to convert them to buffers.
      FailureOr<Value> buffer = getBuffer(rewriter, port.get(), options);
      if (failed(buffer))
        return failure();
      newBuffers.push_back(*buffer);

      // We also collect the output buffers to replace the results later.
      if (kind == PortKind::OUTPUT)
        newOutputBuffers.push_back(*buffer);
    }

    // Clone the op, but use the new operands. Since the new op does not have
    // any tensor results, it does not return anything.
    rewriter.setInsertionPoint(instance);
    clone(rewriter, instance, /*newResultTypes=*/TypeRange{}, newBuffers);

    // Replace the results of the old op with the new output buffers.
    replaceOpWithBufferizedValues(rewriter, instance, newOutputBuffers);
    return success();
  }

  AliasingValueList getAliasingOpResults(Operation *op, OpOperand &opOperand,
                                         const AnalysisState &state) const {
    // Output operands alias with their respective tied OpResults.
    auto instance = cast<InstanceOp>(op);
    if (instance.getPortKind(opOperand) == PortKind::OUTPUT)
      return {
          {instance.getTiedOpResult(opOperand), BufferRelation::Equivalent}};
    return {};
  }
};

void mlir::scalehls::hls::registerBufferizableOpInterfaceExternalModels(
    DialectRegistry &registry) {
  registry.addExtension(+[](MLIRContext *ctx, HLSDialect *dialect) {
    DispatchOp::attachInterface<DispatchOrTaskOpInterface<DispatchOp>>(*ctx);
    TaskOp::attachInterface<DispatchOrTaskOpInterface<TaskOp>>(*ctx);
    YieldOp::attachInterface<YieldOpInterface>(*ctx);
    AllocTensorOp::attachInterface<AllocTensorOpInterface>(*ctx);
    InstanceOp::attachInterface<InstanceOpInterface>(*ctx);
  });
}
