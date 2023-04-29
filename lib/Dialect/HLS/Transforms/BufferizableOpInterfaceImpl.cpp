//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/BufferizableOpInterfaceImpl.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"

#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Utils/StaticValueUtils.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/PatternMatch.h"

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
  getAliasingOpOperands(Operation *op, OpResult opResult,
                        const AnalysisState &state) const {
    // Dispatch/task do not have tensor OpOperands. The yielded value can be any
    // SSA value that is in scope. To allow for use-def chain traversal in the
    // analysis, the yielded value is aliasing with the result.
    size_t resultNum = std::distance(op->getOpResults().begin(),
                                     llvm::find(op->getOpResults(), opResult));
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

    // Move over dispatch/task blocks.
    rewriter.inlineRegionBefore(task.getBody(), newTask.getBody(),
                                newTask.getBody().end());

    // Replace dispatch/task op results.
    replaceOpWithBufferizedValues(rewriter, op, newTask->getResults());
    return success();
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

  AliasingOpResultList getAliasingOpResults(Operation *op, OpOperand &opOperand,
                                            const AnalysisState &state) const {
    if (isa<DispatchOp>(op->getParentOp()))
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

void mlir::scalehls::hls::registerBufferizableOpInterfaceExternalModels(
    DialectRegistry &registry) {
  registry.addExtension(+[](MLIRContext *ctx, HLSDialect *dialect) {
    DispatchOp::attachInterface<DispatchOrTaskOpInterface<DispatchOp>>(*ctx);
    TaskOp::attachInterface<DispatchOrTaskOpInterface<TaskOp>>(*ctx);
    YieldOp::attachInterface<YieldOpInterface>(*ctx);
  });
}
