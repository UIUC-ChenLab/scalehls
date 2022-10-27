//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Utils.h"
#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/IntegerSet.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// Dataflow utils
//===----------------------------------------------------------------------===//

/// Get the root affine loop contained by the node.
AffineForOp scalehls::getNodeRootLoop(NodeOp currentNode) {
  assert(llvm::hasSingleElement(currentNode.getOps<AffineForOp>()) &&
         "node must only contain one loop band");
  return *currentNode.getOps<AffineForOp>().begin();
}

/// Get the affine loop band contained by the node.
AffineLoopBand scalehls::getNodeLoopBand(NodeOp currentNode) {
  AffineLoopBand band;
  getLoopBandFromOutermost(getNodeRootLoop(currentNode), band);
  return band;
}

/// Wrap the operations in the block with dispatch op.
DispatchOp scalehls::dispatchBlock(Block *block) {
  if (!block->getOps<DispatchOp>().empty() ||
      !isa<func::FuncOp, mlir::AffineForOp>(block->getParentOp()))
    return DispatchOp();

  OpBuilder builder(block, block->begin());
  ValueRange returnValues(block->getTerminator()->getOperands());
  auto loc = builder.getUnknownLoc();
  auto dispatch = builder.create<DispatchOp>(loc, returnValues);

  auto &dispatchBlock = dispatch.getBody().emplaceBlock();
  builder.setInsertionPointToEnd(&dispatchBlock);
  builder.create<YieldOp>(loc, returnValues);

  auto &dispatchOps = dispatchBlock.getOperations();
  auto &parentOps = block->getOperations();
  dispatchOps.splice(dispatchBlock.begin(), parentOps,
                     std::next(parentOps.begin()), std::prev(parentOps.end()));
  block->getTerminator()->setOperands(dispatch.getResults());
  return dispatch;
}

/// Fuse the given operations into a new task. The new task will be created
/// before the first operation or last operation and each operation will be
/// inserted in order. This method always succeeds even if the resulting IR is
/// invalid.
TaskOp scalehls::fuseOpsIntoTask(ArrayRef<Operation *> ops,
                                 PatternRewriter &rewriter,
                                 bool insertToLastOp) {
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
  if (!insertToLastOp)
    rewriter.setInsertionPoint(ops.front());
  else
    rewriter.setInsertionPoint(ops.back());
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
NodeOp scalehls::fuseNodeOps(ArrayRef<NodeOp> nodes,
                             PatternRewriter &rewriter) {
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
    for (auto input : llvm::enumerate(node.getInputs()))
      if (inputs.insert(input.value())) {
        inputLocs.push_back(input.value().getLoc());
        inputTaps.push_back(node.getInputTap(input.index()));
      }
    for (auto output : node.getOutputs())
      if (outputs.insert(output))
        outputLocs.push_back(output.getLoc());
    for (auto param : node.getParams())
      if (params.insert(param))
        paramLocs.push_back(param.getLoc());
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

static SmallVector<NodeOp> getBufferUsers(Value buffer, bool getProducer,
                                          NodeOp exceptedOp) {
  SmallVector<NodeOp, 4> nodes;
  for (auto &use : buffer.getUses())
    if (auto node = dyn_cast<NodeOp>(use.getOwner()))
      if (node != exceptedOp &&
          ((getProducer && node.getOperandKind(use) == OperandKind::OUTPUT) ||
           (!getProducer && node.getOperandKind(use) == OperandKind::INPUT)))
        nodes.push_back(node);
  return std::move(nodes);
}

/// Get the consumer/producer nodes of the given buffer expect the given op.
SmallVector<NodeOp> scalehls::getConsumersExcept(Value buffer, NodeOp except) {
  return getBufferUsers(buffer, false, except);
}
SmallVector<NodeOp> scalehls::getProducersExcept(Value buffer, NodeOp except) {
  return getBufferUsers(buffer, true, except);
}
SmallVector<NodeOp> scalehls::getConsumers(Value buffer) {
  return getConsumersExcept(buffer, NodeOp());
}
SmallVector<NodeOp> scalehls::getProducers(Value buffer) {
  return getProducersExcept(buffer, NodeOp());
}

/// Find buffer value or buffer op across the dataflow hierarchy.
Value scalehls::findBuffer(Value memref) {
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
hls::BufferLikeInterface scalehls::findBufferOp(Value memref) {
  if (auto buffer = findBuffer(memref))
    return buffer.getDefiningOp<hls::BufferLikeInterface>();
  return hls::BufferLikeInterface();
}

/// Get the depth of a buffer or stream channel. Note that only if the defining
/// operation of the buffer is not a BufferOp or stream types, the returned
/// result will be 1.
unsigned scalehls::getBufferDepth(Value memref) {
  if (auto streamType = memref.getType().dyn_cast<StreamType>()) {
    return streamType.getDepth();
  } else if (auto bufferOp = findBufferOp(memref))
    return bufferOp.getBufferDepth();
  return 1;
}

bool scalehls::isExternalBuffer(Value memref) {
  if (auto type = memref.getType().dyn_cast<MemRefType>())
    return isDram(MemoryKind(type.getMemorySpaceAsInt()));
  return false;
}

/// Check whether the given use has read/write semantics.
bool scalehls::isRead(OpOperand &use) {
  // For NodeOp and ScheduleOp, we don't rely on memory effect interface.
  // Instead, we delve into its region to figure out the effect.
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
bool scalehls::isWritten(OpOperand &use) {
  // For ScheduleOp, we don't rely on memory effect interface. Instead, we delve
  // into its region to figure out the effect. However, for NodeOp, we don't
  // need this recursive approach any more.
  if (auto node = dyn_cast<NodeOp>(use.getOwner()))
    return node.getOperandKind(use) == OperandKind::OUTPUT;
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

//===----------------------------------------------------------------------===//
// Linalg analysis utils
//===----------------------------------------------------------------------===//

bool scalehls::isElementwiseGenericOp(linalg::GenericOp op) {
  // All loops must be parallel loop.
  if (op.getNumParallelLoops() != op.getNumLoops())
    return false;

  for (auto valueMap : llvm::zip(op.getOperands(), op.getIndexingMapsArray())) {
    auto type = std::get<0>(valueMap).getType().cast<ShapedType>();
    auto map = std::get<1>(valueMap);

    // If the operand doens't have static shape, the index map must be identity.
    if (!type.hasStaticShape()) {
      if (!map.isIdentity())
        return false;
      continue;
    }

    // Otherwise, each dimension must either have a size of one or have identity
    // access index.
    unsigned index = map.getNumDims() - type.getRank();
    for (auto shapeExpr : llvm::zip(type.getShape(), map.getResults())) {
      auto dimSize = std::get<0>(shapeExpr);
      auto expr = std::get<1>(shapeExpr);
      if (expr != getAffineDimExpr(index++, expr.getContext()) && dimSize != 1)
        return false;
    }
  }
  return true;
}

//===----------------------------------------------------------------------===//
// Memory and loop analysis utils
//===----------------------------------------------------------------------===//

/// The current op or contained ops have effect on external buffers.
bool scalehls::hasEffectOnExternalBuffer(Operation *op) {
  auto result = op->walk([](MemoryEffectOpInterface effectOp) {
    SmallVector<MemoryEffects::EffectInstance> effects;
    effectOp.getEffects(effects);
    for (auto effect : effects)
      if (isExternalBuffer(effect.getValue()))
        return WalkResult::interrupt();
    return WalkResult::advance();
  });
  return result.wasInterrupted();
}

/// Distribute the given factor from the innermost loop of the given loop band,
/// so that we can apply vectorize, unroll and jam, etc.
SmallVector<unsigned, 8> scalehls::getDistributedFactors(
    unsigned factor, const SmallVectorImpl<mlir::AffineForOp> &band) {
  SmallVector<unsigned, 8> sizes;
  unsigned remainFactor = factor;

  for (auto it = band.rbegin(), e = band.rend(); it != e; ++it) {
    if (auto optionalTripCount = getConstantTripCount(*it)) {
      auto tripCount = optionalTripCount.value();
      auto size = tripCount;

      if (remainFactor >= tripCount)
        remainFactor = (remainFactor + tripCount - 1) / tripCount;
      else if (remainFactor > 1) {
        size = 1;
        while (size < remainFactor || tripCount % size != 0)
          ++size;
        remainFactor = 1;
      } else
        size = 1;

      sizes.push_back(size);
    } else
      sizes.push_back(1);
  }
  std::reverse(sizes.begin(), sizes.end());
  return sizes;
}

/// Return a pair which indicates whether the if statement is always true or
/// false, respectively. The returned result is one-hot.
std::pair<bool, bool> scalehls::ifAlwaysTrueOrFalse(mlir::AffineIfOp ifOp) {
  auto set = ifOp.getIntegerSet();
  auto operands = SmallVector<Value, 4>(ifOp.getOperands().begin(),
                                        ifOp.getOperands().end());

  // Compose all associated AffineApplyOp into the current if operation.
  while (llvm::any_of(operands, [](Value v) {
    return isa_and_nonnull<AffineApplyOp>(v.getDefiningOp());
  })) {
    composeSetAndOperands(set, operands);
  }

  // Replace the original integer set and operands with the composed integer
  // set and operands.
  ifOp.setIntegerSet(set);
  ifOp->setOperands(operands);

  // Construct the constraints of the if statement. For now, we only add the
  // loop induction constraints and integer set constraint.
  FlatAffineValueConstraints constrs;
  constrs.addAffineIfOpDomain(ifOp);
  for (auto operand : operands)
    if (isForInductionVar(operand)) {
      auto iv = getForInductionVarOwner(operand);
      if (failed(constrs.addAffineForOpDomain(iv)))
        continue;
    }

  bool alwaysTrue = false;
  bool alwaysFalse = false;

  if (set.getNumInputs() == 0) {
    // If the integer set is pure constant set, determine whether the
    // condition is always true or always false.
    SmallVector<bool, 4> flagList;
    unsigned idx = 0;
    for (auto expr : set.getConstraints()) {
      bool eqFlag = set.isEq(idx++);
      auto constValue = expr.cast<AffineConstantExpr>().getValue();

      if (eqFlag)
        flagList.push_back(constValue == 0);
      else
        flagList.push_back(constValue >= 0);
    }

    // Only when all sub-conditions are met, the if statement is always true.
    // Otherwise, the statement if always false.
    if (llvm::all_of(flagList, [&](bool flag) { return flag; }))
      alwaysTrue = true;
    else
      alwaysFalse = true;

  } else if (constrs.isEmpty()) {
    // If there is no solution for the constraints, the condition will always
    // be false.
    alwaysFalse = true;
  }

  // Assert only one of the two flags are true.
  assert((!alwaysTrue || !alwaysFalse) && "unexpected if condition");
  return {alwaysTrue, alwaysFalse};
}

/// Check whether the two given if statements have the same condition.
bool scalehls::checkSameIfStatement(AffineIfOp lhsOp, AffineIfOp rhsOp) {
  if (lhsOp == nullptr || rhsOp == nullptr)
    return false;

  auto lhsSet = lhsOp.getIntegerSet();
  auto rhsSet = rhsOp.getIntegerSet();

  // TODO: support if statement with return values.
  if (lhsOp.getNumResults() != 0 || rhsOp.getNumResults() != 0 ||
      lhsOp.getOperands() != rhsOp.getOperands() ||
      lhsSet.getConstraints() != rhsSet.getConstraints() ||
      lhsSet.getEqFlags() != rhsSet.getEqFlags())
    return false;
  return true;
}

/// Parse array attributes.
SmallVector<int64_t, 8> scalehls::getIntArrayAttrValue(Operation *op,
                                                       StringRef name) {
  SmallVector<int64_t, 8> array;
  if (auto arrayAttr = op->getAttrOfType<ArrayAttr>(name)) {
    for (auto attr : arrayAttr)
      if (auto intAttr = attr.dyn_cast<IntegerAttr>())
        array.push_back(intAttr.getInt());
      else
        return SmallVector<int64_t, 8>();
    return array;
  } else
    return SmallVector<int64_t, 8>();
}

/// Collect all load and store operations in the block and return them in "map".
void scalehls::getMemAccessesMap(Block &block, MemAccessesMap &map,
                                 bool includeVectorTransfer) {
  for (auto &op : block) {
    if (auto load = dyn_cast<AffineReadOpInterface>(op))
      map[load.getMemRef()].push_back(&op);

    else if (auto store = dyn_cast<AffineWriteOpInterface>(op))
      map[store.getMemRef()].push_back(&op);

    else if (auto read = dyn_cast<vector::TransferReadOp>(op)) {
      if (includeVectorTransfer)
        map[read.getSource()].push_back(&op);

    } else if (auto write = dyn_cast<vector::TransferWriteOp>(op)) {
      if (includeVectorTransfer)
        map[write.getSource()].push_back(&op);

    } else if (op.getNumRegions()) {
      // Recursively collect memory access operations in each block.
      for (auto &region : op.getRegions())
        for (auto &block : region)
          getMemAccessesMap(block, map);
    }
  }
}

bool scalehls::crossRegionDominates(Operation *a, Operation *b) {
  if (a == b)
    return true;
  if (b->isAncestor(a))
    return false;
  while (a->getParentOp() && !a->getParentOp()->isAncestor(b))
    a = a->getParentOp();
  assert(a->getParentOp() && "reach top-level module op");
  return DominanceInfo().dominates(a, b);
}

// Check if the lhsOp and rhsOp are in the same block. If so, return their
// ancestors that are located at the same block. Note that in this check,
// AffineIfOp is transparent.
Optional<std::pair<Operation *, Operation *>>
scalehls::checkSameLevel(Operation *lhsOp, Operation *rhsOp) {
  // If lhsOp and rhsOp are already at the same level, return true.
  if (lhsOp->getBlock() == rhsOp->getBlock())
    return std::pair<Operation *, Operation *>(lhsOp, rhsOp);

  // Helper to get all surrounding AffineIfOps.
  auto getSurroundIfs =
      ([&](Operation *op, SmallVector<Operation *, 4> &nests) {
        nests.push_back(op);
        auto currentOp = op;
        while (true) {
          auto parentOp = currentOp->getParentOp();
          if (isa<AffineIfOp, scf::IfOp>(parentOp)) {
            nests.push_back(parentOp);
            currentOp = parentOp;
          } else
            break;
        }
      });

  SmallVector<Operation *, 4> lhsNests;
  SmallVector<Operation *, 4> rhsNests;

  getSurroundIfs(lhsOp, lhsNests);
  getSurroundIfs(rhsOp, rhsNests);

  // If any parent of lhsOp and any parent of rhsOp are at the same level,
  // return true.
  for (auto lhs : lhsNests)
    for (auto rhs : rhsNests)
      if (lhs->getBlock() == rhs->getBlock())
        return std::pair<Operation *, Operation *>(lhs, rhs);

  return Optional<std::pair<Operation *, Operation *>>();
}

/// Returns the number of surrounding loops common to 'loopsA' and 'loopsB',
/// where each lists loops from outer-most to inner-most in loop nest.
unsigned scalehls::getCommonSurroundingLoops(Operation *A, Operation *B,
                                             AffineLoopBand *band) {
  SmallVector<AffineForOp, 4> loopsA, loopsB;
  getLoopIVs(*A, &loopsA);
  getLoopIVs(*B, &loopsB);

  unsigned minNumLoops = std::min(loopsA.size(), loopsB.size());
  unsigned numCommonLoops = 0;
  for (unsigned i = 0; i < minNumLoops; ++i) {
    if (loopsA[i] != loopsB[i])
      break;
    ++numCommonLoops;
    if (band != nullptr)
      band->push_back(loopsB[i]);
  }
  return numCommonLoops;
}

/// Calculate the lower and upper bound of the affine map if possible.
Optional<std::pair<int64_t, int64_t>>
scalehls::getBoundOfAffineMap(AffineMap map, ValueRange operands) {
  if (map.isSingleConstant()) {
    auto constBound = map.getSingleConstantResult();
    return std::pair<int64_t, int64_t>(constBound, constBound);
  }

  // For now, we can only handle one result value map.
  if (map.getNumResults() != 1)
    return Optional<std::pair<int64_t, int64_t>>();

  auto context = map.getContext();
  SmallVector<int64_t, 4> lbs;
  SmallVector<int64_t, 4> ubs;
  for (auto operand : operands) {
    // Only if the affine map operands are induction variable, the calculation
    // is possible.
    if (!isForInductionVar(operand))
      return Optional<std::pair<int64_t, int64_t>>();

    // Only if the owner for op of the induction variable has constant bound,
    // the calculation is possible.
    auto forOp = getForInductionVarOwner(operand);
    if (!forOp.hasConstantBounds())
      return Optional<std::pair<int64_t, int64_t>>();

    auto lb = forOp.getConstantLowerBound();
    auto ub = forOp.getConstantUpperBound();
    auto step = forOp.getStep();

    lbs.push_back(lb);
    ubs.push_back(ub - 1 - (ub - 1 - lb) % step);
  }

  // TODO: maybe a more efficient algorithm.
  auto operandNum = operands.size();
  SmallVector<int64_t, 16> results;
  for (unsigned i = 0, e = pow(2, operandNum); i < e; ++i) {
    SmallVector<AffineExpr, 4> replacements;
    for (unsigned pos = 0; pos < operandNum; ++pos) {
      if (i >> pos % 2 == 0)
        replacements.push_back(getAffineConstantExpr(lbs[pos], context));
      else
        replacements.push_back(getAffineConstantExpr(ubs[pos], context));
    }
    auto newExpr = map.getResult(0).replaceDimsAndSymbols(replacements, {});

    if (auto constExpr = newExpr.dyn_cast<AffineConstantExpr>())
      results.push_back(constExpr.getValue());
    else
      return Optional<std::pair<int64_t, int64_t>>();
  }

  auto minmax = std::minmax_element(results.begin(), results.end());
  return std::pair<int64_t, int64_t>(*minmax.first, *minmax.second);
}

bool scalehls::isFullyPartitioned(MemRefType memrefType) {
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
int64_t scalehls::getPartitionFactors(MemRefType memrefType,
                                      SmallVector<int64_t, 8> *factors) {
  auto shape = memrefType.getShape();
  auto layoutMap = memrefType.getLayout().getAffineMap();
  int64_t accumFactor = 1;

  for (int64_t dim = 0; dim < memrefType.getRank(); ++dim) {
    int64_t factor = 1;
    auto expr = layoutMap.getResult(dim);

    if (auto binaryExpr = expr.dyn_cast<AffineBinaryOpExpr>())
      if (auto rhsExpr = binaryExpr.getRHS().dyn_cast<AffineConstantExpr>()) {
        if (expr.getKind() == AffineExprKind::Mod)
          factor = rhsExpr.getValue();
        else if (expr.getKind() == AffineExprKind::FloorDiv)
          factor = (shape[dim] + rhsExpr.getValue() - 1) / rhsExpr.getValue();
      }

    accumFactor *= factor;
    if (factors != nullptr)
      factors->push_back(factor);
  }

  return accumFactor;
}

/// This is method for finding the number of child loops which immediatedly
/// contained by the input operation.
unsigned scalehls::getChildLoopNum(Operation *op) {
  unsigned childNum = 0;
  for (auto &region : op->getRegions())
    for (auto &block : region)
      for (auto &op : block)
        if (isa<AffineForOp>(op))
          ++childNum;

  return childNum;
}

/// Given a tiled loop band, return true and get the tile (tile-space) loop band
/// and the point (intra-tile) loop band. If failed, return false.
bool scalehls::getTileAndPointLoopBand(const AffineLoopBand &band,
                                       AffineLoopBand &tileBand,
                                       AffineLoopBand &pointBand) {
  tileBand.clear();
  pointBand.clear();
  bool isPointLoop = false;

  for (auto loop : band) {
    if (!isPointLoop && !hasPointAttr(loop))
      tileBand.push_back(loop);

    else if (isPointLoop && hasPointAttr(loop))
      pointBand.push_back(loop);

    else if (!isPointLoop && hasPointAttr(loop)) {
      isPointLoop = true;
      pointBand.push_back(loop);

    } else {
      tileBand.clear();
      pointBand.clear();
      return false;
    }
  }
  return true;
}

/// Given a loop band, return true and get the parallel loop band outsides and
/// the reduction loop band inside. If failed, return false.
bool scalehls::getParallelAndReductionLoopBand(const AffineLoopBand &band,
                                               AffineLoopBand &parallelBand,
                                               AffineLoopBand &reductionBand) {
  parallelBand.clear();
  reductionBand.clear();
  bool isReductionLoop = false;

  for (auto loop : band) {
    if (!isReductionLoop && (hasParallelAttr(loop) || isLoopParallel(loop)))
      parallelBand.push_back(loop);

    else if (isReductionLoop &&
             !(hasParallelAttr(loop) || isLoopParallel(loop)))
      reductionBand.push_back(loop);

    else if (!isReductionLoop &&
             !(hasParallelAttr(loop) || isLoopParallel(loop))) {
      isReductionLoop = true;
      reductionBand.push_back(loop);

    } else {
      parallelBand.clear();
      reductionBand.clear();
      return false;
    }
  }
  return true;
}

/// Get the whole loop band given the outermost loop and return it in "band".
/// Meanwhile, the return value is the innermost loop of this loop band.
AffineForOp scalehls::getLoopBandFromOutermost(AffineForOp forOp,
                                               AffineLoopBand &band) {
  band.clear();
  auto currentLoop = forOp;
  while (true) {
    band.push_back(currentLoop);

    if (getChildLoopNum(currentLoop) == 1)
      currentLoop = *currentLoop.getOps<AffineForOp>().begin();
    else
      break;
  }
  return band.back();
}
AffineForOp scalehls::getLoopBandFromInnermost(AffineForOp forOp,
                                               AffineLoopBand &band) {
  band.clear();
  AffineLoopBand reverseBand;

  auto currentLoop = forOp;
  while (true) {
    reverseBand.push_back(currentLoop);

    auto parentLoop = currentLoop->getParentOfType<AffineForOp>();
    if (!parentLoop)
      break;

    if (getChildLoopNum(parentLoop) == 1)
      currentLoop = parentLoop;
    else
      break;
  }

  band.append(reverseBand.rbegin(), reverseBand.rend());
  return band.front();
}

/// Collect all loop bands in the "block" and return them in "bands". If
/// "allowHavingChilds" is true, loop bands containing more than 1 other loop
/// bands are also collected. Otherwise, only loop bands that contains no child
/// loops are collected.
void scalehls::getLoopBands(Block &block, AffineLoopBands &bands,
                            bool allowHavingChilds) {
  bands.clear();
  block.walk([&](AffineForOp loop) {
    auto childNum = getChildLoopNum(loop);

    if (childNum == 0 || (childNum > 1 && allowHavingChilds)) {
      AffineLoopBand band;
      getLoopBandFromInnermost(loop, band);
      bands.push_back(band);
    }
  });
}

void scalehls::getArrays(Block &block, SmallVectorImpl<Value> &arrays,
                         bool allowArguments) {
  // Collect argument arrays.
  if (allowArguments)
    for (auto arg : block.getArguments()) {
      if (arg.getType().isa<MemRefType>())
        arrays.push_back(arg);
    }

  // Collect local arrays.
  for (auto &op : block.getOperations()) {
    if (isa<memref::AllocaOp, memref::AllocOp>(op))
      arrays.push_back(op.getResult(0));
  }
}

Optional<unsigned> scalehls::getAverageTripCount(AffineForOp forOp) {
  if (auto optionalTripCount = getConstantTripCount(forOp))
    return optionalTripCount.value();
  else {
    // TODO: A temporary approach to estimate the trip count. For now, we take
    // the average of the upper bound and lower bound of trip count as the
    // estimated trip count.
    auto lowerBound = getBoundOfAffineMap(forOp.getLowerBoundMap(),
                                          forOp.getLowerBoundOperands());
    auto upperBound = getBoundOfAffineMap(forOp.getUpperBoundMap(),
                                          forOp.getUpperBoundOperands());

    if (lowerBound && upperBound) {
      auto lowerTripCount =
          upperBound.value().second - lowerBound.value().first;
      auto upperTripCount =
          upperBound.value().first - lowerBound.value().second;
      return (lowerTripCount + upperTripCount + 1) / 2;
    } else
      return Optional<unsigned>();
  }
}

bool scalehls::checkDependence(Operation *A, Operation *B) {
  AffineLoopBand commonLoops;
  unsigned numCommonLoops = getCommonSurroundingLoops(A, B, &commonLoops);

  // Traverse each loop level to find dependencies.
  for (unsigned depth = numCommonLoops; depth > 0; depth--) {
    // Skip all parallel loop level.
    if (hasParallelAttr(commonLoops[depth - 1]))
      continue;

    FlatAffineValueConstraints depConstrs;
    DependenceResult result = checkMemrefAccessDependence(
        MemRefAccess(A), MemRefAccess(B), depth, &depConstrs,
        /*dependenceComponents=*/nullptr);
    if (hasDependence(result))
      return true;
  }

  return false;
}

func::FuncOp scalehls::getTopFunc(ModuleOp module, std::string topFuncName) {
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

func::FuncOp scalehls::getRuntimeFunc(ModuleOp module,
                                      std::string runtimeFuncName) {
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

//===----------------------------------------------------------------------===//
// PtrLikeMemRefAccess Struct Definition
//===----------------------------------------------------------------------===//

PtrLikeMemRefAccess::PtrLikeMemRefAccess(Operation *loadOrStoreOpInst) {
  Operation *opInst = nullptr;
  SmallVector<Value, 4> indices;

  if (auto loadOp = dyn_cast<AffineReadOpInterface>(loadOrStoreOpInst)) {
    memref = loadOp.getMemRef();
    opInst = loadOrStoreOpInst;
    auto loadMemrefType = loadOp.getMemRefType();

    indices.reserve(loadMemrefType.getRank());
    for (auto index : loadOp.getMapOperands()) {
      indices.push_back(index);
    }
  } else {
    assert(isa<AffineWriteOpInterface>(loadOrStoreOpInst) &&
           "Affine read/write op expected");
    auto storeOp = cast<AffineWriteOpInterface>(loadOrStoreOpInst);
    opInst = loadOrStoreOpInst;
    memref = storeOp.getMemRef();
    auto storeMemrefType = storeOp.getMemRefType();

    indices.reserve(storeMemrefType.getRank());
    for (auto index : storeOp.getMapOperands()) {
      indices.push_back(index);
    }
  }

  // Get affine map from AffineLoad/Store.
  AffineMap map;
  if (auto loadOp = dyn_cast<AffineReadOpInterface>(opInst))
    map = loadOp.getAffineMap();
  else
    map = cast<AffineWriteOpInterface>(opInst).getAffineMap();

  SmallVector<Value, 8> operands(indices.begin(), indices.end());
  fullyComposeAffineMapAndOperands(&map, &operands);
  map = simplifyAffineMap(map);
  canonicalizeMapAndOperands(&map, &operands);

  accessMap.reset(map, operands);
}

bool PtrLikeMemRefAccess::operator==(const PtrLikeMemRefAccess &rhs) const {
  if (memref != rhs.memref || impl != rhs.impl)
    return false;

  if (impl == rhs.impl && impl && rhs.impl)
    return true;

  AffineValueMap diff;
  AffineValueMap::difference(accessMap, rhs.accessMap, &diff);
  return llvm::all_of(diff.getAffineMap().getResults(),
                      [](AffineExpr e) { return e == 0; });
}
