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
// ScheduleOp
//===----------------------------------------------------------------------===//

namespace {
struct SimplifyScheduleOperands : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    bool hasUnusedPort = false;

    // Identify input values that are used.
    llvm::SmallDenseSet<BlockArgument, 4> unusedArgs;
    SmallVector<Value, 4> usedOperands;
    for (auto arg : schedule.getBody().getArguments())
      if (arg.use_empty()) {
        hasUnusedPort = true;
        unusedArgs.insert(arg);
      } else {
        usedOperands.push_back(schedule.getOperand(arg.getArgNumber()));
      }
    schedule.getBody().front().eraseArguments(
        [&](BlockArgument arg) { return unusedArgs.count(arg); });

    // Construct new schedule.
    if (hasUnusedPort) {
      rewriter.setInsertionPoint(schedule);
      auto newSchedule =
          rewriter.create<ScheduleOp>(schedule.getLoc(), usedOperands);
      rewriter.inlineRegionBefore(schedule.getBody(), newSchedule.getBody(),
                                  newSchedule.getBody().end());
      rewriter.eraseOp(schedule);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
template <typename OpType>
struct InlineScheduleOrNode : public OpRewritePattern<OpType> {
  InlineScheduleOrNode(MLIRContext *context,
                       llvm::function_ref<bool(OpType)> condition)
      : OpRewritePattern<OpType>(context), condition(condition) {}

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    if (condition(op)) {
      auto &ops = op.getBody().front().getOperations();
      auto &parentOps = op->getBlock()->getOperations();
      parentOps.splice(op->getIterator(), ops);

      for (auto t : llvm::zip(op.getBody().getArguments(), op.getOperands()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      rewriter.eraseOp(op);
      return success();
    }
    return failure();
  }

private:
  llvm::function_ref<bool(OpType)> condition;
};
} // namespace

void ScheduleOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                             MLIRContext *context) {
  results.add<SimplifyScheduleOperands>(context);
  results.add<InlineScheduleOrNode<ScheduleOp>>(
      context, [](ScheduleOp op) { return op.getOps<NodeOp>().empty(); });
}

LogicalResult ScheduleOp::verify() {
  if (getOperandTypes() != getBody().getArgumentTypes())
    return emitOpError("operand type doesn't align with argument type");

  if (getIsLegal())
    for (auto &op : getOps())
      if (!isa<NodeOp, BufferOp, ConstBufferOp, StreamOp, BufferVectorizeOp,
               BufferDevectorizeOp>(op)) {
        auto diag = emitOpError("legal schedule has illegal ops:\n");
        diag.attachNote(op.getLoc())
            .append("see current op: ")
            .appendOp(op, OpPrintingFlags().printGenericOpForm());
        return diag;
      }
  return success();
}

void ScheduleOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  for (auto value : getOperands())
    if (value.getType().isa<MemRefType, StreamType>()) {
      effects.emplace_back(MemoryEffects::Read::get(), value,
                           SideEffects::DefaultResource::get());
      effects.emplace_back(MemoryEffects::Write::get(), value,
                           SideEffects::DefaultResource::get());
    }
}

/// FIXME: Check whether the schedule is dependence free.
bool ScheduleOp::isDependenceFree() {
  if (auto loop = dyn_cast<AffineForOp>((*this)->getParentOp()))
    return hasParallelAttr(loop);
  return isa<func::FuncOp>((*this)->getParentOp());
}

/// Update the signature of the schedule op recursively.
void ScheduleOp::updateSignatureRecursively() {
  for (auto [operand, arg] : llvm::zip(getOperands(), getBody().getArguments()))
    arg.setType(operand.getType());
  for (auto node : getOps<NodeOp>())
    node.updateSignatureRecursively();
}

//===----------------------------------------------------------------------===//
// NodeOp
//===----------------------------------------------------------------------===//

namespace {
struct SimplifyNodeIOs : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    bool hasUnusedPort = false;

    // Identify input values that are used.
    llvm::SmallDenseSet<BlockArgument, 4> unusedArgs;
    SmallVector<Value, 4> usedInputs;
    SmallVector<int32_t, 4> usedInputTaps;
    SmallVector<Value, 4> usedOutputs;
    SmallVector<Value, 4> usedParams;
    for (auto arg : node.getBody().getArguments())
      if (arg.use_empty()) {
        hasUnusedPort = true;
        unusedArgs.insert(arg);
      } else {
        auto idx = arg.getArgNumber();
        if (node.getOperandKind(idx) == OperandKind::INPUT) {
          usedInputs.push_back(node.getOperand(idx));
          usedInputTaps.push_back(node.getInputTap(idx));
        } else if (node.getOperandKind(idx) == OperandKind::OUTPUT)
          usedOutputs.push_back(node.getOperand(idx));
        else
          usedParams.push_back(node.getOperand(idx));
      }
    node.getBody().front().eraseArguments(
        [&](BlockArgument arg) { return unusedArgs.count(arg); });

    // Construct new dataflow node.
    if (hasUnusedPort) {
      rewriter.setInsertionPoint(node);
      auto newNode = rewriter.create<NodeOp>(
          node.getLoc(), usedInputs, usedOutputs, usedParams,
          rewriter.getI32ArrayAttr(usedInputTaps), node.getLevelAttr());
      rewriter.inlineRegionBefore(node.getBody(), newNode.getBody(),
                                  newNode.getBody().end());
      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

void NodeOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.add<SimplifyNodeIOs>(context);
  results.add<InlineScheduleOrNode<NodeOp>>(context, [](NodeOp op) {
    return false;
    // return llvm::hasSingleElement(op.getScheduleOp().getOps<NodeOp>());
  });
}

LogicalResult NodeOp::verify() {
  if (getOperandTypes() != getBody().getArgumentTypes())
    return emitOpError("operand type doesn't align with argument type");

  if (llvm::any_of(getParams(), [](Value param) {
        return param.getType().isa<MemRefType, StreamType>();
      }))
    return emitOpError("node params should not be memref or stream typed");

  if (getInputs().size() != getInputTaps().size())
    return emitOpError("number of node inputs and input taps are not aligned");
  for (auto t : llvm::zip(getInputs(), getInputTapsAsInt())) {
    auto depth = getBufferDepth(std::get<0>(t));
    auto inputTap = (unsigned)std::get<1>(t);
    if (depth <= inputTap) {
      auto diag = emitOpError("node input tap is larger than buffer depth, ");
      diag << "input tap: " << inputTap << ", depth: " << depth;
    }
  }

  for (auto inputArg : getInputArgs())
    if (llvm::any_of(inputArg.getUses(), isWritten)) {
      auto diag = emitOpError("input operand ");
      diag << inputArg << " is written";
      return diag;
    }

  for (auto outputArg : getOutputArgs())
    if (!llvm::any_of(outputArg.getUses(), isWritten)) {
      auto diag = emitOpError("output operand ");
      diag << outputArg << " is not written";
      return diag;
    }

  if (getScheduleOp().getIsLegal()) {
    if (!getLevel())
      return emitOpError("node is not scheduled");

    for (auto output : getOutputs()) {
      // DRAM buffer is not considered - the dependencies associated with them
      // are handled later by tokens.
      if (isExtBuffer(output))
        continue;

      if (getDependentConsumers(output, *this).size() > 1 ||
          getProducers(output).size() > 1) {
        auto diag = emitOpError(
            "legal schedule violates single-consumer or single-producer, ");
        diag << "see current buffer: " << output << "\n";
        for (auto user : output.getUsers())
          diag.attachNote(user->getLoc())
              .append("see current buffer user: ")
              .appendOp(*user, OpPrintingFlags().printGenericOpForm());
        return diag;
      }
    }
  }
  return success();
}

void NodeOp::getEffects(
    SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>>
        &effects) {
  for (auto value : getInputs())
    effects.emplace_back(MemoryEffects::Read::get(), value,
                         SideEffects::DefaultResource::get());
  for (auto value : getOutputs()) {
    effects.emplace_back(MemoryEffects::Read::get(), value,
                         SideEffects::DefaultResource::get());
    effects.emplace_back(MemoryEffects::Write::get(), value,
                         SideEffects::DefaultResource::get());
  }
}

/// Get the parent schedule op.
ScheduleOp NodeOp::getScheduleOp() {
  return (*this)->getParentOfType<ScheduleOp>();
}

/// Get input taps.
void NodeOp::setInputTap(unsigned idx, unsigned tap) {
  SmallVector<int32_t> newInputTaps(llvm::map_range(
      getInputTapsAsInt(), [](unsigned a) { return (int32_t)a; }));
  newInputTaps[idx] = tap;
  Builder builder(getContext());
  setInputTapsAttr(builder.getI32ArrayAttr(newInputTaps));
}
unsigned NodeOp::getInputTap(unsigned idx) {
  return getInputTaps()[idx].cast<IntegerAttr>().getInt();
}
SmallVector<unsigned> NodeOp::getInputTapsAsInt() {
  auto array = llvm::map_range(getInputTaps(), [](Attribute attr) {
    return attr.cast<IntegerAttr>().getInt();
  });
  return {array.begin(), array.end()};
}

/// Return the number of inputs, outputs, and params.
unsigned NodeOp::getNumInputs() {
  return getODSOperandIndexAndLength(0).second;
}
unsigned NodeOp::getNumOutputs() {
  return getODSOperandIndexAndLength(1).second;
}
unsigned NodeOp::getNumParams() {
  return getODSOperandIndexAndLength(2).second;
}

/// Get the type of operand: input, output, or param.
OperandKind NodeOp::getOperandKind(OpOperand &operand) {
  assert(operand.getOwner() == *this && "invalid operand");
  return getOperandKind(operand.getOperandNumber());
}
OperandKind NodeOp::getOperandKind(unsigned operandIdx) {
  if (operandIdx >= getODSOperandIndexAndLength(2).first)
    return OperandKind::PARAM;
  else if (operandIdx >= getODSOperandIndexAndLength(1).first)
    return OperandKind::OUTPUT;
  else
    return OperandKind::INPUT;
}

/// Get the input, output, and param arguments.
iterator_range<Block::args_iterator> NodeOp::getInputArgs() {
  auto range = getODSOperandIndexAndLength(0);
  return {std::next(getBody().args_begin(), range.first),
          std::next(getBody().args_begin(), range.first + range.second)};
}
iterator_range<Block::args_iterator> NodeOp::getOutputArgs() {
  auto range = getODSOperandIndexAndLength(1);
  return {std::next(getBody().args_begin(), range.first),
          std::next(getBody().args_begin(), range.first + range.second)};
}
iterator_range<Block::args_iterator> NodeOp::getParamArgs() {
  auto range = getODSOperandIndexAndLength(2);
  return {std::next(getBody().args_begin(), range.first),
          std::next(getBody().args_begin(), range.first + range.second)};
}

bool NodeOp::isLivein(Value value) {
  return value.isa<BlockArgument>() &&
         value.getParentRegion() == &(*this).getBody();
}

SmallVector<Value> NodeOp::getLiveins() {
  auto args = (*this).getBody().getArguments();
  return {args.begin(), args.end()};
}

SmallVector<Operation *> NodeOp::getLiveinUsers(Value livein) {
  assert(isLivein(livein) && "invalid livein");
  auto users = livein.getUsers();
  return {users.begin(), users.end()};
}

/// Update the signature of the node op recursively.
void NodeOp::updateSignatureRecursively() {
  llvm::SmallDenseSet<ScheduleOp> schedules;
  for (auto [operand, arg] :
       llvm::zip(getOperands(), getBody().getArguments())) {
    arg.setType(operand.getType());
    for (auto user : arg.getUsers())
      if (auto schedule = dyn_cast<ScheduleOp>(user))
        schedules.insert(schedule);
  }
  // TODO: How to traverse all schedule ops?
  for (auto schedule : schedules)
    schedule.updateSignatureRecursively();
}
