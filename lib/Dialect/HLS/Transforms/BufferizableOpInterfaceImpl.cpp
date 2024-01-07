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
  /// Dispatch/task do not have tensor OpOperands. Thus, no OpOperand will be
  /// bufferized to memory read/write or be aliased to any returned values.
  AliasingValueList getAliasingValues(Operation *op, OpOperand &opOperand,
                                      const AnalysisState &state) const {
    return {};
  }

  // Dispatch/task do not have tensor OpOperands. The yielded value can be any
  // SSA value that is in scope. To allow for use-def chain traversal in the
  // analysis, the yielded value is aliasing with the result.
  AliasingOpOperandList
  getAliasingOpOperands(Operation *op, Value value,
                        const AnalysisState &state) const {
    size_t resultNum = std::distance(op->getResults().begin(),
                                     llvm::find(op->getResults(), value));
    OpOperand *operand =
        &cast<OpType>(op).getYieldOp()->getOpOperand(resultNum);
    return {{operand, BufferRelation::Equivalent}};
  }

  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    OpBuilder::InsertionGuard g(rewriter);

    // Compute bufferized result types.
    SmallVector<Type> newTypes;
    for (Value result : op->getResults()) {
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
    rewriter.setInsertionPoint(op);
    auto newOp = rewriter.create<OpType>(op->getLoc(), newTypes);
    rewriter.inlineRegionBefore(cast<OpType>(op).getBody(), newOp.getBody(),
                                newOp.getBody().end());

    // Replace dispatch/task op results.
    replaceOpWithBufferizedValues(rewriter, op, newOp->getResults());
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

  AliasingValueList getAliasingValues(Operation *op, OpOperand &opOperand,
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

  AliasingValueList getAliasingValues(Operation *op, OpOperand &opOperand,
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

void mlir::scalehls::hls::registerBufferizableOpInterfaceExternalModels(
    DialectRegistry &registry) {
  registry.addExtension(+[](MLIRContext *ctx, HLSDialect *dialect) {
    DispatchOp::attachInterface<DispatchOrTaskOpInterface<DispatchOp>>(*ctx);
    TaskOp::attachInterface<DispatchOrTaskOpInterface<TaskOp>>(*ctx);
    YieldOp::attachInterface<YieldOpInterface>(*ctx);
    AllocTensorOp::attachInterface<AllocTensorOpInterface>(*ctx);
  });
}
