//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Interfaces/ViewLikeInterface.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace bufferization;
using namespace scalehls;
using namespace hls;

/// Helper function for task bufferization. Return the indices of all values
/// that have a tensor type.
static DenseSet<int64_t> getTensorIndices(ValueRange values) {
  DenseSet<int64_t> result;
  for (const auto &it : llvm::enumerate(values))
    if (isa<TensorType>(it.value().getType()))
      result.insert(it.index());
  return result;
}

/// Helper function for task bufferization. Return "true" if the given value
/// is guaranteed to not alias with an external tensor apart from values in
/// `exceptions`. A value is external if it is defined outside of the given
/// region or if it is an entry block argument of the region.
static bool doesNotAliasExternalValue(Value value, Region *region,
                                      ValueRange exceptions,
                                      const OneShotAnalysisState &state) {
  assert(region->getBlocks().size() == 1 &&
         "expected region with single block");
  bool result = true;
  state.applyOnAliases(value, [&](Value alias) {
    if (llvm::is_contained(exceptions, alias))
      return;
    Region *aliasRegion = alias.getParentRegion();
    if (isa<BlockArgument>(alias) && !region->isProperAncestor(aliasRegion))
      result = false;
    if (isa<OpResult>(alias) && !region->isAncestor(aliasRegion))
      result = false;
  });
  return result;
}

/// Compute the bufferized type of a task init_arg. This type must be equal to
/// the bufferized type of the corresponding init_arg and the bufferized type of
/// the corresponding yielded value.
///
/// This function uses bufferization::getBufferType to compute the bufferized
/// type of the init_arg and of the yielded value. (The computation of the
/// bufferized yielded value type usually requires computing the bufferized type
/// of the `iter_arg` again; the implementation of getBufferType traces back the
/// use-def chain of the given value and computes a buffer type along the way.)
/// If both buffer types are equal, no casts are needed the computed buffer type
/// can be used directly. Otherwise, the buffer types can only differ in their
/// layout map and a cast must be inserted.
static FailureOr<BaseMemRefType> computeTaskRegionIterArgBufferType(
    Operation *task, BlockArgument iterArg, Value initArg, Value yieldedValue,
    const BufferizationOptions &options, SmallVector<Value> &invocationStack) {
  // Determine the buffer type of the init_arg.
  auto initArgBufferType =
      bufferization::getBufferType(initArg, options, invocationStack);
  if (failed(initArgBufferType))
    return failure();

  if (llvm::count(invocationStack, iterArg) >= 2) {
    // If the iter_arg is already twice on the invocation stack, just take the
    // type of the init_arg. This is to avoid infinite tasks when calculating
    // the buffer type. This will most likely result in computing a memref type
    // with a fully dynamic layout map.

    // Note: For more precise layout map computation, a fixpoint iteration could
    // be done (i.e., re-computing the yielded buffer type until the bufferized
    // iter_arg type no longer changes). This current implementation immediately
    // switches to a fully dynamic layout map when a mismatch between bufferized
    // init_arg type and bufferized yield value type is detected.
    return *initArgBufferType;
  }

  // Compute the buffer type of the yielded value.
  BaseMemRefType yieldedValueBufferType;
  if (isa<BaseMemRefType>(yieldedValue.getType())) {
    // Task yield was already bufferized.
    yieldedValueBufferType = cast<BaseMemRefType>(yieldedValue.getType());
  } else {
    // Note: This typically triggers a recursive call for the buffer type of
    // the iter_arg.
    auto maybeBufferType =
        bufferization::getBufferType(yieldedValue, options, invocationStack);
    if (failed(maybeBufferType))
      return failure();
    yieldedValueBufferType = *maybeBufferType;
  }

  // If yielded type and init_arg type are the same, use that type directly.
  if (*initArgBufferType == yieldedValueBufferType)
    return yieldedValueBufferType;

  // If there is a mismatch between the yielded buffer type and the init_arg
  // buffer type, the buffer type must be promoted to a fully dynamic layout
  // map.
  auto yieldedBufferType = cast<BaseMemRefType>(yieldedValueBufferType);
  auto iterTensorType = cast<TensorType>(iterArg.getType());
  auto initBufferType = llvm::cast<BaseMemRefType>(*initArgBufferType);
  if (initBufferType.getMemorySpace() != yieldedBufferType.getMemorySpace())
    return task->emitOpError(
        "init_arg and yielded value bufferize to inconsistent memory spaces");

  if (auto yieldedRankedBufferType = dyn_cast<MemRefType>(yieldedBufferType)) {
    assert(
        llvm::all_equal({yieldedRankedBufferType.getShape(),
                         cast<MemRefType>(initBufferType).getShape(),
                         cast<RankedTensorType>(iterTensorType).getShape()}) &&
        "expected same shape");
  }

  return getMemRefTypeWithFullyDynamicLayout(
      iterTensorType, yieldedBufferType.getMemorySpace());
}

/// Helper function for task bufferization. Return the bufferized values of the
/// given OpOperands. If an operand is not a tensor, return the original value.
static FailureOr<SmallVector<Value>>
getBuffers(RewriterBase &rewriter, MutableOperandRange operands,
           const BufferizationOptions &options) {
  SmallVector<Value> result;
  for (OpOperand &opOperand : operands) {
    if (isa<TensorType>(opOperand.get().getType())) {
      FailureOr<Value> resultBuffer =
          getBuffer(rewriter, opOperand.get(), options);
      if (failed(resultBuffer))
        return failure();
      result.push_back(*resultBuffer);
    } else {
      result.push_back(opOperand.get());
    }
  }
  return result;
}

/// Helper function for task bufferization. Cast the given buffer to the given
/// memref type.
static Value castBuffer(OpBuilder &b, Value buffer, Type type) {
  assert(isa<BaseMemRefType>(type) && "expected BaseMemRefType");
  assert(isa<BaseMemRefType>(buffer.getType()) && "expected BaseMemRefType");
  // If the buffer already has the correct type, no cast is needed.
  if (buffer.getType() == type)
    return buffer;
  // TODO: In case `type` has a layout map that is not the fully dynamic
  // one, we may not be able to cast the buffer. In that case, the task
  // iter_arg's layout map must be changed (see uses of `castBuffer`).
  assert(memref::CastOp::areCastCompatible(buffer.getType(), type) &&
         "buffer cast incompatible in bufferization");
  return b.create<memref::CastOp>(buffer.getLoc(), type, buffer).getResult();
}

/// Helper function for task bufferization. Given a list of bbArgs of the new
/// (bufferized) task op, wrap the bufferized tensor args (now memrefs) into
/// ToTensorOps, so that the block body can be moved over to the new op.
static SmallVector<Value>
getBbArgReplacements(RewriterBase &rewriter, Block::BlockArgListType bbArgs,
                     const DenseSet<int64_t> &tensorIndices) {
  SmallVector<Value> result;
  for (const auto &it : llvm::enumerate(bbArgs)) {
    size_t idx = it.index();
    Value val = it.value();
    if (tensorIndices.contains(idx)) {
      result.push_back(
          rewriter.create<bufferization::ToTensorOp>(val.getLoc(), val)
              .getResult());
    } else {
      result.push_back(val);
    }
  }
  return result;
}

struct TaskOpInterface
    : public BufferizableOpInterface::ExternalModel<TaskOpInterface, TaskOp> {
  bool bufferizesToMemoryRead(Operation *op, OpOperand &opOperand,
                              const AnalysisState &state) const {
    auto task = cast<TaskOp>(op);

    // TaskOp alone doesn't bufferize to a memory read, one of the uses of its
    // matching bbArg may.
    return state.isValueRead(
        task.getBody().getArgument(opOperand.getOperandNumber()));
  }

  bool bufferizesToMemoryWrite(Operation *op, OpOperand &opOperand,
                               const AnalysisState &state) const {
    // Tensor `inits` of TaskOps are always considered as a write.
    return true;
  }

  AliasingValueList getAliasingValues(Operation *op, OpOperand &opOperand,
                                      const AnalysisState &state) const {
    auto task = cast<TaskOp>(op);
    OpResult opResult = task->getOpResult(opOperand.getOperandNumber());
    BufferRelation relation = bufferRelation(op, opResult, state);
    return {{opResult, relation,
             /*isDefinite=*/relation == BufferRelation::Equivalent}};
  }

  BufferRelation bufferRelation(Operation *op, OpResult opResult,
                                const AnalysisState &state) const {
    // ForOp results are equivalent to their corresponding init_args if the
    // corresponding iter_args and yield values are equivalent.
    auto task = cast<TaskOp>(op);
    BlockArgument bbArg =
        task.getBody().getArgument(opResult.getResultNumber());
    bool equivalentYield = state.areEquivalentBufferizedValues(
        bbArg, task.getYieldOp().getOperand(bbArg.getArgNumber()));
    return equivalentYield ? BufferRelation::Equivalent
                           : BufferRelation::Unknown;
  }

  bool isWritable(Operation *op, Value value,
                  const AnalysisState &state) const {
    // Interestingly, TaskOp's bbArg can **always** be viewed inplace from the
    // perspective of ops nested under:
    //   1. Either the matching iter operand is not bufferized inplace and an
    //      alloc + optional copy makes the bbArg itself inplaceable.
    //   2. Or the matching iter operand is bufferized inplace and bbArg just
    //      bufferizes to that too.
    return true;
  }

  LogicalResult resolveConflicts(Operation *op, RewriterBase &rewriter,
                                 const AnalysisState &state) const {
    auto bufferizableOp = cast<BufferizableOpInterface>(op);
    if (failed(bufferizableOp.resolveTensorOpOperandConflicts(rewriter, state)))
      return failure();

    if (!state.getOptions().enforceAliasingInvariants)
      return success();

    // According to the `getAliasing...` implementations, a bufferized OpResult
    // may alias only with the corresponding bufferized init_arg (or with a
    // newly allocated buffer) and not with other buffers defined outside of the
    // task. I.e., the i-th OpResult may alias with the i-th init_arg;
    // but not with any other OpOperand.
    auto task = cast<TaskOp>(op);
    auto yieldOp = task.getYieldOp();
    OpBuilder::InsertionGuard g(rewriter);
    rewriter.setInsertionPoint(yieldOp);

    // Indices of all iter_args that have tensor type. These are the ones that
    // are bufferized.
    DenseSet<int64_t> indices = getTensorIndices(task.getInits());
    // For every yielded value, does it alias with something defined outside of
    // the task?
    SmallVector<Value> yieldValues;
    for (const auto it : llvm::enumerate(yieldOp.getResults())) {
      // Note: `state` is guaranteed to be a `OneShotAnalysisState`, but this
      // type cannot be used in the signature of `resolveConflicts` because the
      // op interface is in the "IR" build unit and the `OneShotAnalysisState`
      // is defined in the "Transforms" build unit.
      if (!indices.contains(it.index()) ||
          doesNotAliasExternalValue(
              it.value(), &task.getBody(),
              /*exceptions=*/task.getBody().getArgument(it.index()),
              static_cast<const OneShotAnalysisState &>(state))) {
        yieldValues.push_back(it.value());
        continue;
      }
      FailureOr<Value> alloc = allocateTensorForShapedValue(
          rewriter, yieldOp.getLoc(), it.value(), state.getOptions());
      if (failed(alloc))
        return failure();
      yieldValues.push_back(*alloc);
    }

    rewriter.updateRootInPlace(
        yieldOp, [&]() { yieldOp.getResultsMutable().assign(yieldValues); });
    return success();
  }

  FailureOr<BaseMemRefType>
  getBufferType(Operation *op, Value value, const BufferizationOptions &options,
                SmallVector<Value> &invocationStack) const {
    auto task = cast<TaskOp>(op);
    assert(getOwnerOfValue(value) == op && "invalid value");
    assert(isa<TensorType>(value.getType()) && "expected tensor type");

    if (auto opResult = dyn_cast<OpResult>(value)) {
      // The type of an OpResult must match the corresponding iter_arg type.
      BlockArgument bbArg =
          task.getBody().getArgument(opResult.getResultNumber());
      return bufferization::getBufferType(bbArg, options, invocationStack);
    }

    // Compute result/argument number.
    BlockArgument bbArg = cast<BlockArgument>(value);
    unsigned resultNum = bbArg.getArgNumber();

    // Compute the bufferized type.
    auto yieldOp = task.getYieldOp();
    Value yieldedValue = yieldOp.getOperand(resultNum);
    BlockArgument iterArg = task.getBody().getArgument(resultNum);
    Value initArg = task.getInits()[resultNum];
    return computeTaskRegionIterArgBufferType(
        op, iterArg, initArg, yieldedValue, options, invocationStack);
  }

  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    auto task = cast<TaskOp>(op);
    Block *taskBlock = &task.getBody().front();

    // Indices of all iter_args that have tensor type. These are the ones that
    // are bufferized.
    DenseSet<int64_t> indices = getTensorIndices(task.getInits());

    // The new memref init_args of the task.
    FailureOr<SmallVector<Value>> maybeInitArgs =
        getBuffers(rewriter, task.getInitsMutable(), options);
    if (failed(maybeInitArgs))
      return failure();
    SmallVector<Value> initArgs = *maybeInitArgs;

    // Cast init_args if necessary.
    SmallVector<Value> castedInitArgs;
    for (const auto &it : llvm::enumerate(initArgs)) {
      Value initArg = it.value();
      Value result = task->getResult(it.index());
      // If the type is not a tensor, bufferization doesn't need to touch it.
      if (!isa<TensorType>(result.getType())) {
        castedInitArgs.push_back(initArg);
        continue;
      }
      auto targetType = bufferization::getBufferType(result, options);
      if (failed(targetType))
        return failure();
      castedInitArgs.push_back(castBuffer(rewriter, initArg, *targetType));
    }

    // Construct a new task op with memref instead of tensor values.
    auto castedInitTypes = TypeRange(castedInitArgs);
    auto newTask =
        rewriter.create<TaskOp>(task.getLoc(), castedInitTypes, castedInitArgs);
    newTask->setAttrs(task->getAttrs());
    Block *newTaskBlock = rewriter.createBlock(
        &newTask.getBody(), newTask.getBody().begin(), castedInitTypes,
        llvm::map_to_vector(castedInitArgs,
                            [&](Value v) { return v.getLoc(); }));

    // Set up new iter_args. The task body uses tensors, so wrap the (memref)
    // iter_args of the new task in ToTensorOps.
    rewriter.setInsertionPointToStart(newTaskBlock);
    SmallVector<Value> iterArgs = getBbArgReplacements(
        rewriter, newTask.getBody().getArguments(), indices);

    // Move task body to new task.
    rewriter.mergeBlocks(taskBlock, newTaskBlock, iterArgs);

    // Replace task results.
    replaceOpWithBufferizedValues(rewriter, op, newTask->getResults());
    return success();
  }

  /// Assert that yielded values of an task op are equivalent to their
  /// corresponding bbArgs. In that case, the buffer relations of the
  /// corresponding OpResults are "Equivalent".
  ///
  /// If this is not the case, an allocs+copies are inserted and yielded from
  /// the task. This could be a performance problem, so it must be explicitly
  /// activated with `alloc-return-allocs`.
  LogicalResult verifyAnalysis(Operation *op,
                               const AnalysisState &state) const {
    auto task = cast<TaskOp>(op);
    auto yieldOp = task.getYieldOp();
    for (OpResult opResult : op->getOpResults()) {
      if (!isa<TensorType>(opResult.getType()))
        continue;

      // Note: This is overly strict. We should check for aliasing bufferized
      // values. But we don't have a "must-alias" analysis yet.
      if (bufferRelation(op, opResult, state) != BufferRelation::Equivalent)
        return yieldOp->emitError()
               << "Yield operand #" << opResult.getResultNumber()
               << " is not equivalent to the corresponding iter bbArg";
    }

    return success();
  }
};

struct YieldOpInterface
    : public BufferizableOpInterface::ExternalModel<YieldOpInterface,
                                                    hls::YieldOp> {
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
    return {};
  }

  bool mustBufferizeInPlace(Operation *op, OpOperand &opOperand,
                            const AnalysisState &state) const {
    // Yield operands always bufferize inplace. Otherwise, an alloc + copy
    // may be generated inside the block. We should not return/yield allocations
    // when possible.
    return true;
  }

  LogicalResult bufferize(Operation *op, RewriterBase &rewriter,
                          const BufferizationOptions &options) const {
    auto yieldOp = cast<hls::YieldOp>(op);

    SmallVector<Value> newResults;
    for (const auto &it : llvm::enumerate(yieldOp.getResults())) {
      Value value = it.value();
      if (isa<TensorType>(value.getType())) {
        FailureOr<Value> maybeBuffer = getBuffer(rewriter, value, options);
        if (failed(maybeBuffer))
          return failure();
        Value buffer = *maybeBuffer;

        FailureOr<BaseMemRefType> resultType = bufferization::getBufferType(
            yieldOp->getParentOp()->getResult(it.index()), options);
        if (failed(resultType))
          return failure();
        buffer = castBuffer(rewriter, buffer, *resultType);
        newResults.push_back(buffer);
      } else {
        newResults.push_back(value);
      }
    }

    replaceOpWithNewBufferizedOp<hls::YieldOp>(rewriter, op, newResults);
    return success();
  }
};

struct TensorInitOpInterface
    : public BufferizableOpInterface::ExternalModel<TensorInitOpInterface,
                                                    hls::TensorInitOp> {
  bool bufferizesToAllocation(Operation *op, Value value) const { return true; }

  bool resultBufferizesToMemoryWrite(Operation *op, OpResult opResult,
                                     const AnalysisState &state) const {
    // The returned tensor does not have specified contents.
    return false;
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

    for (auto &use : llvm::make_early_inc_range(tensorInit->getUses())) {
      rewriter.setInsertionPoint(use.getOwner());
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

      auto repl = rewriter.create<bufferization::ToTensorOp>(
          tensorInit.getLoc(), *buffer);
      rewriter.updateRootInPlace(use.getOwner(), [&]() { use.set(repl); });
    }
    rewriter.eraseOp(tensorInit);
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
    hls::TaskOp::attachInterface<TaskOpInterface>(*ctx);
    hls::YieldOp::attachInterface<YieldOpInterface>(*ctx);
    hls::TensorInitOp::attachInterface<TensorInitOpInterface>(*ctx);
  });
}
