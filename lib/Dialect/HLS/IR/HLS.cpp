//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/IR/HLS.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/IntegerSet.h"
#include "scalehls/Utils/Utils.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;
using namespace affine;

//===----------------------------------------------------------------------===//
// HLS dialect
//===----------------------------------------------------------------------===//

void HLSDialect::initialize() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "scalehls/Dialect/HLS/IR/HLSOpsTypes.cpp.inc"
      >();

  addAttributes<
#define GET_ATTRDEF_LIST
#include "scalehls/Dialect/HLS/IR/HLSOpsAttributes.cpp.inc"
      >();

  addOperations<
#define GET_OP_LIST
#include "scalehls/Dialect/HLS/IR/HLSOps.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// Affine SelectOp
//===----------------------------------------------------------------------===//

void AffineSelectOp::build(OpBuilder &builder, OperationState &result,
                           IntegerSet set, ValueRange args, Value trueValue,
                           Value falseValue) {
  assert(trueValue.getType() == falseValue.getType() &&
         "true and false must have the same type");
  result.addTypes(trueValue.getType());
  result.addOperands(args);
  result.addOperands(trueValue);
  result.addOperands(falseValue);
  result.addAttribute(getConditionAttrStrName(), IntegerSetAttr::get(set));
}

namespace {
struct AlwaysTrueOrFalseSelect : public OpRewritePattern<AffineSelectOp> {
  using OpRewritePattern<AffineSelectOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineSelectOp op,
                                PatternRewriter &rewriter) const override {
    auto set = op.getIntegerSet();
    bool alwaysTrue = false;
    bool alwaysFalse = false;

    if (set.isEmptyIntegerSet())
      alwaysFalse = true;

    else if (set.getNumInputs() == 0) {
      SmallVector<bool, 4> flagList;
      for (auto expr : llvm::enumerate(set.getConstraints())) {
        auto constValue = cast<AffineConstantExpr>(expr.value()).getValue();
        flagList.push_back(set.isEq(expr.index()) ? constValue == 0
                                                  : constValue >= 0);
      }
      alwaysTrue = llvm::all_of(flagList, [](bool flag) { return flag; });
      alwaysFalse = !alwaysTrue;

    } else {
      // Create the base constraints from the integer set attached to
      // SelectOp.
      FlatAffineValueConstraints constrs(set);

      // Bind vars in the constraints to SelectOp args.
      auto args = SmallVector<Value, 4>(op.getArgs());
      constrs.setValues(0, constrs.getNumDimAndSymbolVars(), args);

      // Add induction variable constraints.
      for (auto arg : args)
        if (isAffineForInductionVar(arg))
          (void)constrs.addAffineForOpDomain(getForInductionVarOwner(arg));

      // Always false if there's no known solution for the constraints.
      alwaysFalse = constrs.isEmpty();
    }

    // Replace uses if always-false or true is proved.
    if (alwaysFalse)
      rewriter.replaceOp(op, op.getFalseValue());
    else if (alwaysTrue)
      rewriter.replaceOp(op, op.getTrueValue());
    else
      return failure();
    return success();
  }
};
} // namespace

void AffineSelectOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                                 MLIRContext *context) {
  results.add<AlwaysTrueOrFalseSelect>(context);
}

/// Canonicalize an affine if op's conditional (integer set + operands).
OpFoldResult AffineSelectOp::fold(FoldAdaptor adaptor) {
  auto set = getIntegerSet();
  SmallVector<Value, 4> operands(getArgs());
  composeSetAndOperands(set, operands);
  canonicalizeSetAndOperands(&set, &operands);
  setConditional(set, operands);
  return {};
}

LogicalResult AffineSelectOp::verify() {
  // Verify that we have a condition attribute.
  // FIXME: This should be specified in the arguments list in ODS.
  auto conditionAttr =
      (*this)->getAttrOfType<IntegerSetAttr>(getConditionAttrStrName());
  if (!conditionAttr)
    return emitOpError("requires an integer set attribute named 'condition'");

  // Verify that there are enough operands for the condition.
  IntegerSet condition = conditionAttr.getValue();
  if (getArgs().size() != condition.getNumInputs())
    return emitOpError("operand count and condition integer set dimension and "
                       "symbol count must match");

  // Verify that the operands are valid dimension/symbols.
  unsigned opIt = 0;
  for (auto operand : getArgs()) {
    if (opIt++ < condition.getNumDims()) {
      if (!isValidDim(operand, getAffineScope(*this)))
        return emitOpError("operand cannot be used as a dimension id");
    } else if (!isValidSymbol(operand, getAffineScope(*this))) {
      return emitOpError("operand cannot be used as a symbol");
    }
  }
  return success();
}

ParseResult AffineSelectOp::parse(OpAsmParser &parser, OperationState &result) {
  // Parse the condition attribute set.
  IntegerSetAttr conditionAttr;
  unsigned numDims;
  if (parser.parseAttribute(conditionAttr,
                            AffineSelectOp::getConditionAttrStrName(),
                            result.attributes) ||
      parseDimAndSymbolList(parser, result.operands, numDims))
    return failure();

  // Verify the condition operands.
  auto set = conditionAttr.getValue();
  if (set.getNumDims() != numDims)
    return parser.emitError(
        parser.getNameLoc(),
        "dim operand count and integer set dim count must match");
  if (numDims + set.getNumSymbols() != result.operands.size())
    return parser.emitError(
        parser.getNameLoc(),
        "symbol operand count and integer set symbol count must match");

  SmallVector<OpAsmParser::UnresolvedOperand, 4> values;
  SMLoc valuesLoc = parser.getCurrentLocation();
  Type resultType;
  if (parser.parseOperandList(values) ||
      parser.parseOptionalAttrDict(result.attributes) ||
      parser.parseColonType(resultType))
    return failure();
  result.types.push_back(resultType);

  if (values.size() != 2)
    return parser.emitError(valuesLoc, "should only have two input values");
  if (parser.resolveOperands(values, {resultType, resultType}, valuesLoc,
                             result.operands))
    return failure();
  return success();
}

/// Prints dimension and symbol list.
static void printDimAndSymbolList(Operation::operand_iterator begin,
                                  Operation::operand_iterator end,
                                  unsigned numDims, OpAsmPrinter &printer) {
  OperandRange operands(begin, end);
  printer << '(' << operands.take_front(numDims) << ')';
  if (operands.size() > numDims)
    printer << '[' << operands.drop_front(numDims) << ']';
}

void AffineSelectOp::print(OpAsmPrinter &p) {
  auto conditionAttr =
      (*this)->getAttrOfType<IntegerSetAttr>(getConditionAttrStrName());
  p << " " << conditionAttr;
  printDimAndSymbolList(getArgs().begin(), getArgs().end(),
                        conditionAttr.getValue().getNumDims(), p);

  p << " ";
  p.printOperand(getTrueValue());
  p << ", ";
  p.printOperand(getFalseValue());

  p.printOptionalAttrDict((*this)->getAttrs(),
                          /*elidedAttrs=*/getConditionAttrStrName());
  p << " : ";
  p.printType(getType());
}

IntegerSet AffineSelectOp::getIntegerSet() {
  return (*this)
      ->getAttrOfType<IntegerSetAttr>(getConditionAttrStrName())
      .getValue();
}

void AffineSelectOp::setIntegerSet(IntegerSet newSet) {
  (*this)->setAttr(getConditionAttrStrName(), IntegerSetAttr::get(newSet));
}

/// Sets the integer set with its operands.
void AffineSelectOp::setConditional(IntegerSet set, ValueRange operands) {
  setIntegerSet(set);
  getArgsMutable().assign(operands);
}

//===----------------------------------------------------------------------===//
// Include tablegen classes
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/IR/HLSOpsDialect.cpp.inc"
#include "scalehls/Dialect/HLS/IR/HLSOpsEnums.cpp.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsAttributes.cpp.inc"

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsTypes.cpp.inc"

#include "scalehls/Dialect/HLS/IR/HLSOpsInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOps.cpp.inc"

//===----------------------------------------------------------------------===//
// Attribute Accessors
//===----------------------------------------------------------------------===//

/// Loop directive attribute accessors.
LoopDirectiveAttr hls::getLoopDirective(Operation *op) {
  return op->getAttrOfType<LoopDirectiveAttr>("__loop_direct__");
}
void hls::setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective) {
  op->setAttr("__loop_direct__", loopDirective);
}
void hls::setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                           bool dataflow, bool flatten) {
  auto loopDirective = LoopDirectiveAttr::get(op->getContext(), pipeline,
                                              targetII, dataflow, flatten);
  setLoopDirective(op, loopDirective);
}

/// Function directive attribute accessors.
FuncDirectiveAttr hls::getFuncDirective(Operation *op) {
  return op->getAttrOfType<FuncDirectiveAttr>("__func_direct__");
}
void hls::setFuncDirective(Operation *op, FuncDirectiveAttr funcDirective) {
  op->setAttr("__func_direct__", funcDirective);
}
void hls::setFuncDirective(Operation *op, bool pipeline, int64_t targetInterval,
                           bool dataflow) {
  auto funcDirective = FuncDirectiveAttr::get(op->getContext(), pipeline,
                                              targetInterval, dataflow);
  setFuncDirective(op, funcDirective);
}

/// Top and runtime function attribute utils.
void hls::setTopFuncAttr(Operation *op) {
  op->setAttr("__top__", UnitAttr::get(op->getContext()));
}
bool hls::hasTopFuncAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("__top__");
}
void hls::setRuntimeAttr(Operation *op) {
  op->setAttr("__runtime__", UnitAttr::get(op->getContext()));
}
bool hls::hasRuntimeAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("__runtime__");
}

//===----------------------------------------------------------------------===//
// Transform Utils
//===----------------------------------------------------------------------===//

/// Wrap the operations in the block with dispatch op.
DispatchOp hls::dispatchBlock(StringRef name, Block *block,
                              PatternRewriter &rewriter) {
  if (!block->getOps<DispatchOp>().empty() ||
      !isa<func::FuncOp, scf::ForOp, scf::ForallOp, scf::ParallelOp,
           affine::AffineForOp, affine::AffineParallelOp>(block->getParentOp()))
    return nullptr;

  auto loc = rewriter.getUnknownLoc();
  ValueRange returnValues(block->getTerminator()->getOperands());
  rewriter.setInsertionPointToStart(block);
  auto dispatch = rewriter.create<DispatchOp>(loc, returnValues);

  auto &dispatchBlock = dispatch.getBody().emplaceBlock();
  rewriter.setInsertionPointToEnd(&dispatchBlock);
  rewriter.create<YieldOp>(loc, returnValues);

  auto &dispatchOps = dispatchBlock.getOperations();
  auto &parentOps = block->getOperations();
  dispatchOps.splice(dispatchBlock.begin(), parentOps,
                     std::next(parentOps.begin()), std::prev(parentOps.end()));
  block->getTerminator()->setOperands(dispatch.getResults());

  unsigned taskId = 0;
  for (auto &op : llvm::make_early_inc_range(dispatch.getOps())) {
    if (isa<linalg::LinalgOp, scf::ForOp, affine::AffineForOp>(op) ||
        isa<tensor::TensorDialect>(op.getDialect())) {
      auto task = fuseOpsIntoTask({&op}, rewriter);
      std::string taskName = name.str() + "_" + std::to_string(taskId++);
      op.setAttr(taskName, rewriter.getUnitAttr());
      task->setAttr(taskName, rewriter.getUnitAttr());
    }
  }
  return dispatch;
}

/// Fuse the given operations into a new task. The new task will be created
/// before "insertToOp" and each operation will be in the original order. This
/// method always succeeds even if the resulting IR is invalid.
TaskOp hls::fuseOpsIntoTask(ArrayRef<Operation *> ops,
                            PatternRewriter &rewriter, Operation *insertToOp) {
  assert(!ops.empty() && "must fuse at least one op");
  llvm::SmallDenseSet<Operation *, 4> opsSet(ops.begin(), ops.end());

  // Collect output values. This is not sufficient and may lead to empty-used
  // outputs, which will be removed during canonicalization.
  llvm::SetVector<Value> outputValues;
  for (auto op : ops)
    for (auto result : op->getResults())
      if (llvm::any_of(result.getUsers(),
                       [&](Operation *user) { return !opsSet.count(user); }))
        outputValues.insert(result);

  // Create new graph task with all inputs and outputs.
  auto loc = rewriter.getUnknownLoc();
  if (!insertToOp)
    rewriter.setInsertionPoint(ops.front());
  else
    rewriter.setInsertionPoint(insertToOp);
  auto task =
      rewriter.create<TaskOp>(loc, ValueRange(outputValues.getArrayRef()));
  auto taskBlock = rewriter.createBlock(&task.getBody());

  // Move each targeted op into the new graph task.
  rewriter.setInsertionPointToEnd(taskBlock);
  auto yield = rewriter.create<YieldOp>(loc, outputValues.getArrayRef());
  for (auto op : ops)
    op->moveBefore(yield);

  // Replace external output uses with the task results.
  unsigned idx = 0;
  for (auto output : outputValues)
    output.replaceUsesWithIf(task.getResult(idx++), [&](OpOperand &use) {
      return !task->isProperAncestor(use.getOwner());
    });

  // Inline all sub-tasks.
  for (auto subTask : llvm::make_early_inc_range(task.getOps<TaskOp>())) {
    auto &subTaskOps = subTask.getBody().front().getOperations();
    auto &taskOps = task.getBody().front().getOperations();
    taskOps.splice(subTask->getIterator(), subTaskOps, subTaskOps.begin(),
                   std::prev(subTaskOps.end()));
    rewriter.replaceOp(subTask, subTask.getYieldOp()->getOperands());
  }
  return task;
}

/// Fuse multiple nodes into a new node.
NodeOp hls::fuseNodeOps(ArrayRef<NodeOp> nodes, PatternRewriter &rewriter) {
  assert((nodes.size() > 1) && "must fuse at least two nodes");

  // Collect inputs, outputs, and params of the new node.
  llvm::SetVector<Value> inputs;
  llvm::SmallVector<unsigned, 8> inputTaps;
  llvm::SmallVector<Location, 8> inputLocs;
  llvm::SetVector<Value> outputs;
  llvm::SmallVector<Location, 8> outputLocs;
  llvm::SetVector<Value> params;
  llvm::SmallVector<Location, 8> paramLocs;

  for (auto node : nodes) {
    for (auto output : node.getOutputs())
      if (outputs.insert(output))
        outputLocs.push_back(output.getLoc());
    for (auto param : node.getParams())
      if (params.insert(param))
        paramLocs.push_back(param.getLoc());
  }
  for (auto node : nodes)
    for (auto input : llvm::enumerate(node.getInputs())) {
      if (outputs.count(input.value()))
        continue;
      if (inputs.insert(input.value())) {
        inputLocs.push_back(input.value().getLoc());
        inputTaps.push_back(node.getInputTap(input.index()));
      }
    }

  // Construct the new node after the last node.
  rewriter.setInsertionPointAfter(nodes.back());
  auto newNode = rewriter.create<NodeOp>(
      rewriter.getUnknownLoc(), inputs.getArrayRef(), outputs.getArrayRef(),
      params.getArrayRef(), inputTaps);
  auto block = rewriter.createBlock(&newNode.getBody());
  block->addArguments(ValueRange(inputs.getArrayRef()), inputLocs);
  block->addArguments(ValueRange(outputs.getArrayRef()), outputLocs);
  block->addArguments(ValueRange(params.getArrayRef()), paramLocs);

  // Inline all nodes into the new node.
  for (auto node : nodes) {
    auto &nodeOps = node.getBody().front().getOperations();
    auto &newNodeOps = newNode.getBody().front().getOperations();
    newNodeOps.splice(newNode.end(), nodeOps);
    for (auto t : llvm::zip(node.getBody().getArguments(), node.getOperands()))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
    rewriter.eraseOp(node);
  }

  for (auto t : llvm::zip(newNode.getOperands(), block->getArguments()))
    std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
      return newNode->isProperAncestor(use.getOwner());
    });
  return newNode;
}

//===----------------------------------------------------------------------===//
// Analysis Utils
//===----------------------------------------------------------------------===//

/// Get or check the memory kind of a type.
MemoryKind hls::getMemoryKind(MemRefType type) {
  if (auto memorySpace = type.getMemorySpace())
    if (auto kindAttr = memorySpace.dyn_cast<MemoryKindAttr>())
      return kindAttr.getValue();
  return MemoryKind::UNKNOWN;
}

bool hls::isRam1P(MemRefType type) {
  auto kind = getMemoryKind(type);
  return kind == MemoryKind::LUTRAM_1P || kind == MemoryKind::BRAM_1P ||
         kind == MemoryKind::URAM_1P;
}
bool hls::isRam2P(MemRefType type) {
  auto kind = getMemoryKind(type);
  return kind == MemoryKind::LUTRAM_2P || kind == MemoryKind::BRAM_2P ||
         kind == MemoryKind::URAM_2P;
}
bool hls::isRamS2P(MemRefType type) {
  auto kind = getMemoryKind(type);
  return kind == MemoryKind::LUTRAM_S2P || kind == MemoryKind::BRAM_S2P ||
         kind == MemoryKind::URAM_S2P;
}
bool hls::isRamT2P(MemRefType type) {
  auto kind = getMemoryKind(type);
  return kind == MemoryKind::BRAM_T2P || kind == MemoryKind::URAM_T2P;
}
bool hls::isDram(MemRefType type) {
  auto kind = getMemoryKind(type);
  return kind == MemoryKind::DRAM;
}
bool hls::isUnknown(MemRefType type) {
  auto kind = getMemoryKind(type);
  return kind == MemoryKind::UNKNOWN;
}

/// A helper to get all users of a buffer except the given node and with the
/// given kind (producer or consumer).
static auto getUsersExcept(Value buffer, PortKind kind, NodeOp except) {
  SmallVector<NodeOp> nodes;
  for (auto &use : buffer.getUses())
    if (auto node = dyn_cast<NodeOp>(use.getOwner()))
      if (node != except && node.getPortKind(use) == kind)
        nodes.push_back(node);
  return nodes;
}

/// Get the consumer/producer nodes of the given buffer expect the given op.
SmallVector<NodeOp> hls::getConsumersExcept(Value buffer, NodeOp except) {
  return getUsersExcept(buffer, PortKind::INPUT, except);
}
SmallVector<NodeOp> hls::getProducersExcept(Value buffer, NodeOp except) {
  return getUsersExcept(buffer, PortKind::OUTPUT, except);
}
SmallVector<NodeOp> hls::getConsumers(Value buffer) {
  return getConsumersExcept(buffer, NodeOp());
}
SmallVector<NodeOp> hls::getProducers(Value buffer) {
  return getProducersExcept(buffer, NodeOp());
}
SmallVector<NodeOp> hls::getDependentConsumers(Value buffer, NodeOp node) {
  // If the buffer is defined outside of a dependence free schedule op, we can
  // ignore back dependences.
  bool ignoreBackDependence =
      buffer.isa<BlockArgument>() && node.getScheduleOp().isDependenceFree();

  DominanceInfo domInfo;
  SmallVector<NodeOp> nodes;
  for (auto consumer : getConsumersExcept(buffer, node))
    if (!ignoreBackDependence || domInfo.properlyDominates(node, consumer))
      nodes.push_back(consumer);
  return nodes;
}

/// A helper to get all nested users of a buffer except the given node and with
/// the given kind (producer or consumer).
static SmallVector<std::pair<NodeOp, Value>>
getNestedUsersExcept(Value buffer, PortKind kind, NodeOp except) {
  SmallVector<std::tuple<NodeOp, Value, PortKind>> worklist;

  // A helper to append all node users of the given buffer.
  auto appendWorklist = [&](Value buffer) {
    for (auto &use : buffer.getUses())
      if (auto node = dyn_cast<NodeOp>(use.getOwner()))
        if (node != except)
          worklist.push_back({node, buffer, node.getPortKind(use)});
  };

  // Initialize the worklist.
  appendWorklist(buffer);

  SmallVector<std::pair<NodeOp, Value>> nestedUsers;
  while (!worklist.empty()) {
    auto current = worklist.pop_back_val();
    auto node = std::get<0>(current);
    auto nodeBuffer = std::get<1>(current);
    auto nodeKind = std::get<2>(current);

    // If the current node doesn't have hierarchy, we add it to results if the
    // node kind is aligned.
    if (!node.hasHierarchy()) {
      if (nodeKind == kind)
        nestedUsers.push_back({node, nodeBuffer});
      continue;
    }

    // Otherwise, we should delve into the hierarchy and traverse all contained
    // schedules.
    auto index =
        llvm::find(node.getOperands(), nodeBuffer) - node.operand_begin();
    assert(index != node.getNumOperands() && "invalid node or node buffer");
    auto arg = node.getBody().getArgument(index);

    for (auto &use : arg.getUses())
      if (auto schedule = dyn_cast<ScheduleOp>(use.getOwner()))
        appendWorklist(schedule.getBody().getArgument(use.getOperandNumber()));
  }
  return nestedUsers;
}

/// Get the nested consumer/producer nodes of the given buffer expect the given
/// node. The corresponding buffer values are also returned.
SmallVector<std::pair<NodeOp, Value>>
hls::getNestedConsumersExcept(Value buffer, NodeOp except) {
  return getNestedUsersExcept(buffer, PortKind::INPUT, except);
}
SmallVector<std::pair<NodeOp, Value>>
hls::getNestedProducersExcept(Value buffer, NodeOp except) {
  return getNestedUsersExcept(buffer, PortKind::OUTPUT, except);
}
SmallVector<std::pair<NodeOp, Value>> hls::getNestedConsumers(Value buffer) {
  return getNestedConsumersExcept(buffer, NodeOp());
}
SmallVector<std::pair<NodeOp, Value>> hls::getNestedProducers(Value buffer) {
  return getNestedProducersExcept(buffer, NodeOp());
}

/// Get the depth of a buffer or stream channel. Note that only if the defining
/// operation of the buffer is not a BufferOp or stream types, the returned
/// result will be 1.
unsigned hls::getBufferDepth(Value memref) {
  if (auto streamType = memref.getType().dyn_cast<StreamType>()) {
    return streamType.getDepth();
  } else if (auto bufferOp = findBufferOp(memref))
    return bufferOp.getBufferDepth();
  return 1;
}

/// Find buffer value or buffer op across the dataflow hierarchy.
Value hls::findBuffer(Value memref) {
  if (auto arg = memref.dyn_cast<BlockArgument>()) {
    if (auto node = dyn_cast<NodeOp>(arg.getParentBlock()->getParentOp()))
      return findBuffer(node->getOperand(arg.getArgNumber()));
    else if (auto schedule =
                 dyn_cast<ScheduleOp>(arg.getParentBlock()->getParentOp()))
      return findBuffer(schedule->getOperand(arg.getArgNumber()));
    return memref;
  } else if (auto viewOp = memref.getDefiningOp<ViewLikeOpInterface>())
    return findBuffer(viewOp.getViewSource());
  else if (auto buffer = memref.getDefiningOp<hls::BufferLikeInterface>())
    return buffer.getMemref();
  return Value();
}
hls::BufferLikeInterface hls::findBufferOp(Value memref) {
  if (auto buffer = findBuffer(memref))
    return buffer.getDefiningOp<hls::BufferLikeInterface>();
  return hls::BufferLikeInterface();
}

/// Check whether the given buffer is external.
bool hls::isExtBuffer(Value memref) {
  if (auto type = memref.getType().dyn_cast<MemRefType>())
    return isDram(type);
  return false;
}

/// Check whether the given use has read/write semantics.
bool hls::isRead(OpOperand &use) {
  // For NodeOp and ScheduleOp, we don't rely on memory effect interface.
  // Instead, we delve into its region to figure out the effect. However, for
  // InstanceOp, we don't need this recursive approach any more.
  if (auto node = dyn_cast<NodeOp>(use.getOwner()))
    return llvm::any_of(
        node.getBody().getArgument(use.getOperandNumber()).getUses(),
        [](OpOperand &argUse) { return isRead(argUse); });
  else if (auto schedule = dyn_cast<ScheduleOp>(use.getOwner()))
    return llvm::any_of(
        schedule.getBody().getArgument(use.getOperandNumber()).getUses(),
        [](OpOperand &argUse) { return isRead(argUse); });
  else if (auto view = dyn_cast<ViewLikeOpInterface>(use.getOwner()))
    return llvm::any_of(view->getUses(),
                        [](OpOperand &viewUse) { return isRead(viewUse); });
  return hasEffect<MemoryEffects::Read>(use.getOwner(), use.get()) ||
         isa<StreamReadOp>(use.getOwner());
}
bool hls::isWritten(OpOperand &use) {
  // For ScheduleOp, we don't rely on memory effect interface. Instead, we delve
  // into its region to figure out the effect. However, for InstanceOp and
  // NodeOp, we don't need this recursive approach any more.
  if (auto node = dyn_cast<NodeOp>(use.getOwner()))
    return node.getPortKind(use) == PortKind::OUTPUT;
  else if (auto schedule = dyn_cast<ScheduleOp>(use.getOwner()))
    return llvm::any_of(
        schedule.getBody().getArgument(use.getOperandNumber()).getUses(),
        [](OpOperand &argUse) { return isWritten(argUse); });
  else if (auto view = dyn_cast<ViewLikeOpInterface>(use.getOwner()))
    return llvm::any_of(view->getUses(),
                        [](OpOperand &viewUse) { return isWritten(viewUse); });
  return hasEffect<MemoryEffects::Write>(use.getOwner(), use.get()) ||
         isa<StreamWriteOp>(use.getOwner());
}

func::FuncOp hls::getTopFunc(ModuleOp module, std::string topFuncName) {
  func::FuncOp topFunc;
  for (auto func : module.getOps<func::FuncOp>())
    if (hasTopFuncAttr(func) || func.getName() == topFuncName) {
      if (!topFunc)
        topFunc = func;
      else
        return func::FuncOp();
    }
  return topFunc;
}

func::FuncOp hls::getRuntimeFunc(ModuleOp module, std::string runtimeFuncName) {
  func::FuncOp runtimeFunc;
  for (auto func : module.getOps<func::FuncOp>())
    if (hasRuntimeAttr(func) || func.getName() == runtimeFuncName) {
      if (!runtimeFunc)
        runtimeFunc = func;
      else
        return func::FuncOp();
    }
  return runtimeFunc;
}

bool hls::isFullyPartitioned(MemRefType memrefType) {
  if (memrefType.getRank() == 0)
    return true;

  bool fullyPartitioned = false;
  SmallVector<int64_t, 8> factors;
  getPartitionFactors(memrefType, &factors);

  auto shapes = memrefType.getShape();
  fullyPartitioned =
      factors == SmallVector<int64_t, 8>(shapes.begin(), shapes.end());

  return fullyPartitioned;
}

// Calculate partition factors through analyzing the "memrefType" and return
// them in "factors". Meanwhile, the overall partition number is calculated and
// returned as well.
int64_t hls::getPartitionFactors(MemRefType memrefType,
                                 SmallVectorImpl<int64_t> *factors) {
  int64_t accumFactor = 1;
  if (auto attr = memrefType.getLayout().dyn_cast<PartitionLayoutAttr>())
    for (auto factor : attr.getActualFactors(memrefType.getShape())) {
      accumFactor *= factor;
      if (factors)
        factors->push_back(factor);
    }
  else if (factors)
    factors->assign(memrefType.getRank(), 1);
  return accumFactor;
}

/// The current op or contained ops have effect on external buffers.
bool hls::hasEffectOnExternalBuffer(Operation *op) {
  auto result = op->walk([](MemoryEffectOpInterface effectOp) {
    SmallVector<MemoryEffects::EffectInstance> effects;
    effectOp.getEffects(effects);
    for (auto effect : effects)
      if (isExtBuffer(effect.getValue()))
        return WalkResult::interrupt();
    return WalkResult::advance();
  });
  return result.wasInterrupted();
}
