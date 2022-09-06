//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/HLS.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/Dominance.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// HLS dialect
//===----------------------------------------------------------------------===//

void HLSDialect::initialize() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "scalehls/Dialect/HLS/HLSTypes.cpp.inc"
      >();

  addAttributes<
#define GET_ATTRDEF_LIST
#include "scalehls/Dialect/HLS/HLSAttributes.cpp.inc"
      >();

  addOperations<
#define GET_OP_LIST
#include "scalehls/Dialect/HLS/HLS.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// HLS dialect utils
//===----------------------------------------------------------------------===//

/// Get the users of a stream channel. If the channel is used by a function
/// call, this method will recursively look into the corresponding sub-function.
/// If the channel is used by a function return, this method will recursively
/// look into each function that calls the parent function of the return.
void hls::getStreamChannelUsers(Value channel,
                                SmallVectorImpl<Operation *> &users) {
  assert(channel.getType().isa<StreamType>() && "channel must be stream type");

  for (auto &use : channel.getUses()) {
    auto user = use.getOwner();
    if (auto call = dyn_cast<func::CallOp>(user)) {
      auto func = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
          call, call.getCalleeAttr());
      if (!func.isPrivate())
        getStreamChannelUsers(func.getArgument(use.getOperandNumber()), users);

    } else if (auto returnOp = dyn_cast<func::ReturnOp>(user)) {
      auto func = returnOp->getParentOfType<func::FuncOp>();
      auto symbolUses = func.getSymbolUses(func->getParentOfType<ModuleOp>());
      if (!symbolUses.hasValue())
        continue;
      for (auto &symbolUse : symbolUses.getValue()) {
        if (auto call = dyn_cast<func::CallOp>(symbolUse.getUser()))
          getStreamChannelUsers(call.getResult(use.getOperandNumber()), users);
      }
    } else if (auto output = dyn_cast<DataflowOutputOp>(user)) {
      auto node = output->getParentOfType<DataflowNodeOp>();
      getStreamChannelUsers(node.getResult(use.getOperandNumber()), users);
    } else
      users.push_back(user);
  }
}

/// Timing attribute utils.
TimingAttr hls::getTiming(Operation *op) {
  return op->getAttrOfType<TimingAttr>("timing");
}
void hls::setTiming(Operation *op, TimingAttr timing) {
  assert(timing.getBegin() <= timing.getEnd() && "invalid timing attribute");
  op->setAttr("timing", timing);
}
void hls::setTiming(Operation *op, int64_t begin, int64_t end, int64_t latency,
                    int64_t minII) {
  auto timing = TimingAttr::get(op->getContext(), begin, end, latency, minII);
  setTiming(op, timing);
}

/// Resource attribute utils.
ResourceAttr hls::getResource(Operation *op) {
  return op->getAttrOfType<ResourceAttr>("resource");
}
void hls::setResource(Operation *op, ResourceAttr resource) {
  op->setAttr("resource", resource);
}
void hls::setResource(Operation *op, int64_t lut, int64_t dsp, int64_t bram) {
  auto resource = ResourceAttr::get(op->getContext(), lut, dsp, bram);
  setResource(op, resource);
}

/// Loop information attribute utils.
LoopInfoAttr hls::getLoopInfo(Operation *op) {
  return op->getAttrOfType<LoopInfoAttr>("loop_info");
}
void hls::setLoopInfo(Operation *op, LoopInfoAttr loopInfo) {
  op->setAttr("loop_info", loopInfo);
}
void hls::setLoopInfo(Operation *op, int64_t flattenTripCount,
                      int64_t iterLatency, int64_t minII) {
  auto loopInfo =
      LoopInfoAttr::get(op->getContext(), flattenTripCount, iterLatency, minII);
  setLoopInfo(op, loopInfo);
}

/// Loop directives attribute utils.
LoopDirectiveAttr hls::getLoopDirective(Operation *op) {
  return op->getAttrOfType<LoopDirectiveAttr>("loop_directive");
}
void hls::setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective) {
  op->setAttr("loop_directive", loopDirective);
}
void hls::setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                           bool dataflow, bool flatten) {
  auto loopDirective = LoopDirectiveAttr::get(op->getContext(), pipeline,
                                              targetII, dataflow, flatten);
  setLoopDirective(op, loopDirective);
}

/// Parrallel and point loop attribute utils.
void hls::setParallelAttr(Operation *op) {
  op->setAttr("parallel", UnitAttr::get(op->getContext()));
}
bool hls::hasParallelAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("parallel");
}
void hls::setPointAttr(Operation *op) {
  op->setAttr("point", UnitAttr::get(op->getContext()));
}
bool hls::hasPointAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("point");
}

/// Function directives attribute utils.
FuncDirectiveAttr hls::getFuncDirective(Operation *op) {
  return op->getAttrOfType<FuncDirectiveAttr>("func_directive");
}
void hls::setFuncDirective(Operation *op, FuncDirectiveAttr funcDirective) {
  op->setAttr("func_directive", funcDirective);
}
void hls::setFuncDirective(Operation *op, bool pipeline, int64_t targetInterval,
                           bool dataflow) {
  auto funcDirective = FuncDirectiveAttr::get(op->getContext(), pipeline,
                                              targetInterval, dataflow);
  setFuncDirective(op, funcDirective);
}

/// Top and runtime function attribute utils.
void hls::setTopFuncAttr(Operation *op) {
  op->setAttr("top_func", UnitAttr::get(op->getContext()));
}
bool hls::hasTopFuncAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("top_func");
}
void hls::setRuntimeAttr(Operation *op) {
  op->setAttr("runtime", UnitAttr::get(op->getContext()));
}
bool hls::hasRuntimeAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("runtime");
}

//===----------------------------------------------------------------------===//
// GraphNodeOp
//===----------------------------------------------------------------------===//

LogicalResult GraphNodeOp::verify() {
  if (llvm::any_of((*this)->getUsers(), [&](Operation *user) {
        return !(*this)->getBlock()->findAncestorOpInBlock(*user);
      }))
    return emitOpError("has unexpected consumer from parent block");
  if (llvm::any_of(getOperands(), [](Value value) {
        return !value.getType().isa<TensorType>();
      }))
    return emitOpError("has non-tensor inputs");
  if (llvm::any_of(getResults(), [](Value value) {
        return !value.getType().isa<TensorType>();
      }))
    return emitOpError("has non-tensor outputs");
  return success();
}

namespace {
struct SimplifyGraphNodeIOs : public OpRewritePattern<GraphNodeOp> {
  using OpRewritePattern<GraphNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(GraphNodeOp node,
                                PatternRewriter &rewriter) const override {
    auto output = node.getOutputOp();
    bool hasUnusedPort = false;

    // Identify output values that are used.
    SmallVector<Value, 4> usedOutputs;
    SmallVector<Value, 4> usedResults;
    for (auto result : node.getResults())
      if (result.use_empty()) {
        hasUnusedPort = true;
      } else {
        usedOutputs.push_back(output.getOperand(result.getResultNumber()));
        usedResults.push_back(result);
      }

    // Identify input values that are used.
    SmallVector<unsigned, 4> unusedArgNumbers;
    SmallVector<Value, 4> usedInputs;
    for (auto arg : node.getBody()->getArguments())
      if (arg.use_empty()) {
        hasUnusedPort = true;
        unusedArgNumbers.push_back(arg.getArgNumber());
      } else {
        usedInputs.push_back(node.getOperand(arg.getArgNumber()));
      }
    node.getBody()->eraseArguments(unusedArgNumbers);

    // Construct new graph node.
    if (hasUnusedPort) {
      rewriter.setInsertionPoint(output);
      rewriter.replaceOpWithNewOp<GraphOutputOp>(output, usedOutputs);

      rewriter.setInsertionPoint(node);
      auto newNode = rewriter.create<GraphNodeOp>(
          node.getLoc(), ValueRange(usedOutputs), usedInputs);
      rewriter.inlineRegionBefore(node.body(), newNode.body(),
                                  newNode.body().end());
      for (auto t : llvm::zip(usedResults, newNode.getResults()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct SimplifyGraphNodeHierarchy : public OpRewritePattern<GraphNodeOp> {
  using OpRewritePattern<GraphNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(GraphNodeOp node,
                                PatternRewriter &rewriter) const override {
    // If the parent block only contains the current graph node, then the node
    // can be fully inlined.
    auto parentBlock = node->getBlock();
    if (llvm::hasSingleElement(parentBlock->getOps<GraphNodeOp>())) {
      auto &nodeOps = node.getBody()->getOperations();
      auto &parentOps = parentBlock->getOperations();
      parentOps.splice(node->getIterator(), nodeOps, nodeOps.begin(),
                       std::prev(nodeOps.end()));

      for (auto t :
           llvm::zip(node.getBody()->getArguments(), node.getOperands()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      rewriter.replaceOp(node, node.getOutputOp()->getOperands());
      return success();
    }
    return failure();
  }
};
} // namespace

void GraphNodeOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                              MLIRContext *context) {
  results.add<SimplifyGraphNodeHierarchy>(context);
  results.add<SimplifyGraphNodeIOs>(context);
}

/// Get the terminator output op.
GraphOutputOp GraphNodeOp::getOutputOp() {
  return cast<GraphOutputOp>(body().front().getTerminator());
}

//===----------------------------------------------------------------------===//
// GraphOutputOp
//===----------------------------------------------------------------------===//

LogicalResult GraphOutputOp::verify() {
  if (getOperandTypes() !=
      (*this)->getParentOfType<GraphNodeOp>().getResultTypes())
    return emitOpError("output type doesn't align with node type");
  return success();
}

//===----------------------------------------------------------------------===//
// NodeOp
//===----------------------------------------------------------------------===//

LogicalResult NodeOp::verify() {
  // for (auto outputArg : getOutputArguments()) {
  //   if (!llvm::any_of(outputArg.getUses(), [](OpOperand &use) {}))
  //     return failure();
  // }
  return success();
}

/// Return the number of inputs and outputs.
unsigned NodeOp::getNumInputs() {
  return getODSOperandIndexAndLength(0).second;
}
unsigned NodeOp::getNumOutputs() {
  return getODSOperandIndexAndLength(1).second;
}

/// Check whether the operand is an output memref.
bool NodeOp::isOutput(OpOperand &operand) {
  return operand.getOwner() == *this &&
         operand.getOperandNumber() >= getODSOperandIndexAndLength(1).first;
}

/// Get the input and output arguments.
iterator_range<Block::args_iterator> NodeOp::getInputArguments() {
  auto range = getODSOperandIndexAndLength(0);
  return {std::next(getBody()->args_begin(), range.first),
          std::next(getBody()->args_begin(), range.first + range.second)};
}
iterator_range<Block::args_iterator> NodeOp::getOutputArguments() {
  auto range = getODSOperandIndexAndLength(1);
  return {std::next(getBody()->args_begin(), range.first),
          std::next(getBody()->args_begin(), range.first + range.second)};
}

//===----------------------------------------------------------------------===//
// BufferOp
//===----------------------------------------------------------------------===//

static SmallVector<NodeOp, 4> getBufferUsers(Value buffer, bool isProducer,
                                             NodeOp exceptedOp) {
  SmallVector<NodeOp, 4> nodes;
  for (auto &use : buffer.getUses())
    if (auto node = dyn_cast<NodeOp>(use.getOwner()))
      if ((node.isOutput(use) == isProducer) && (node != exceptedOp))
        nodes.push_back(node);
  return nodes;
}

SmallVector<NodeOp, 4> BufferOp::getConsumersExcept(NodeOp exceptedOp) {
  return getBufferUsers(this->getOperation()->getResult(0), false, exceptedOp);
}

SmallVector<NodeOp, 4> BufferOp::getProducersExcept(NodeOp exceptedOp) {
  return getBufferUsers(this->getOperation()->getResult(0), true, exceptedOp);
}

SmallVector<NodeOp, 4> BufferOp::getConsumers() {
  return getConsumersExcept(NodeOp());
}

SmallVector<NodeOp, 4> BufferOp::getProducers() {
  return getProducersExcept(NodeOp());
}

//===----------------------------------------------------------------------===//
// ConstBufferOp
//===----------------------------------------------------------------------===//

LogicalResult ConstBufferOp::verify() {
  auto memrefType = getType();
  auto attrType = value().getType().cast<TensorType>();
  if (memrefType.getElementType() != attrType.getElementType())
    return emitOpError("element type mismatch");
  if (!memrefType.hasStaticShape() || !attrType.hasStaticShape())
    return emitOpError("has dynamic shape");
  if (memrefType.getShape() != attrType.getShape())
    return emitOpError("shape mismatch");
  return success();
}

//===----------------------------------------------------------------------===//
// DataflowNodeOp
//===----------------------------------------------------------------------===//

LogicalResult DataflowNodeOp::verify() {
  if (llvm::any_of((*this)->getUsers(), [&](Operation *user) {
        return !(*this)->getBlock()->findAncestorOpInBlock(*user);
      }))
    return emitOpError("has unexpected dataflow consumer from parent block");
  return success();
}

namespace {
struct OutputSimplifyPattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp node,
                                PatternRewriter &rewriter) const override {
    auto output = node.getOutputOp();
    bool hasUnusedResult = false;

    SmallVector<Value, 4> outputValues;
    SmallVector<Value, 4> resultsToReplace;
    for (auto result : node.getResults()) {
      auto value = output.getOperand(result.getResultNumber());

      // Note that we always keep memref outputs even if they are not used.
      if (result.use_empty() && !value.getType().isa<MemRefType>()) {
        hasUnusedResult = true;
        continue;
      }
      outputValues.push_back(value);
      resultsToReplace.push_back(result);
    }

    if (hasUnusedResult) {
      rewriter.setInsertionPoint(output);
      rewriter.replaceOpWithNewOp<DataflowOutputOp>(output, outputValues);

      rewriter.setInsertionPoint(node);
      auto newNode = rewriter.create<DataflowNodeOp>(
          node.getLoc(), ValueRange(outputValues), node.levelAttr());
      rewriter.inlineRegionBefore(node.body(), newNode.body(),
                                  newNode.body().end());
      for (auto t : llvm::zip(resultsToReplace, newNode.getResults()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct HierarchySimplifyPattern : public OpRewritePattern<DataflowNodeOp> {
  using OpRewritePattern<DataflowNodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowNodeOp node,
                                PatternRewriter &rewriter) const override {
    // If the parent block only contains the current dataflow node, then the
    // node can be fully inlined.
    auto parentBlock = node->getBlock();
    if (llvm::hasSingleElement(parentBlock->getOps<DataflowNodeOp>())) {
      auto &nodeOps = node.getBody()->getOperations();
      auto &parentOps = parentBlock->getOperations();
      parentOps.splice(node->getIterator(), nodeOps, nodeOps.begin(),
                       std::prev(nodeOps.end()));

      auto output = node.getBody()->getTerminator();
      rewriter.replaceOp(node, output->getOperands());
      return success();
    }
    return failure();
  }
};
} // namespace

void DataflowNodeOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                                 MLIRContext *context) {
  results.add<HierarchySimplifyPattern>(context);
  results.add<OutputSimplifyPattern>(context);
}

DataflowOutputOp DataflowNodeOp::getOutputOp() {
  return cast<DataflowOutputOp>(body().front().getTerminator());
}

/// Collect output values of the dataflow node. Note that here we consider not
/// only SSA outputs, but also memrefs that are updated.
SmallVector<mlir::Value> DataflowNodeOp::getOutputValues() {
  DominanceInfo DT;
  SmallVector<Value> outputValues;
  for (auto &op : getBody()->getOperations()) {
    outputValues.append(op.result_begin(), op.result_end());
    op.walk([&](Operation *child) {
      // TODO: Any other ops need to be included?
      Value output;
      if (auto copy = dyn_cast<memref::CopyOp>(child))
        output = copy.target();
      else if (auto store = dyn_cast<mlir::AffineWriteOpInterface>(child))
        output = store.getMemRef();

      // Only push back unique outputs.
      if (output && DT.dominates(output.getParentBlock(), getBody()) &&
          llvm::find(outputValues, output) == outputValues.end())
        outputValues.push_back(output);
    });
  }
  return outputValues;
}

/// Collect uses of the dataflow node. A use is defined by a pair of value (the
/// edge) and operation (the user).
SmallVector<std::pair<Value, Operation *>> DataflowNodeOp::getDataflowUses() {
  SmallVector<std::pair<Value, Operation *>> dfUses;
  for (auto &use : (*this)->getUses()) {
    auto user = (*this)->getBlock()->findAncestorOpInBlock(*use.getOwner());
    auto dfUse = std::pair<Value, Operation *>(use.get(), user);
    if (llvm::find(dfUses, dfUse) == dfUses.end())
      dfUses.push_back(dfUse);
  }
  return dfUses;
}

//===----------------------------------------------------------------------===//
// DataflowOutputOp
//===----------------------------------------------------------------------===//

LogicalResult DataflowOutputOp::verify() {
  if (getOperandTypes() !=
      (*this)->getParentOfType<DataflowNodeOp>().getResultTypes())
    return emitOpError("output type doesn't align with node type");

  llvm::SmallDenseSet<Value, 4> outputs(operand_begin(), operand_end());
  auto node = (*this)->getParentOfType<DataflowNodeOp>();

  DominanceInfo DT;
  SmallVector<Value> updatedMemrefs;
  node.walk([&](Operation *child) {
    // TODO: Any other ops need to be included?
    Value memref;
    if (auto copy = dyn_cast<memref::CopyOp>(child))
      memref = copy.target();
    else if (auto store = dyn_cast<mlir::AffineWriteOpInterface>(child))
      memref = store.getMemRef();

    // Only push back unique memrefs.
    if (memref && DT.dominates(memref.getParentBlock(), node.getBody()) &&
        llvm::find(updatedMemrefs, memref) == updatedMemrefs.end())
      updatedMemrefs.push_back(memref);
  });

  // for (auto memref : updatedMemrefs)
  //   if (!outputs.count(memref)) {
  //     auto diag = emitOpError("updated memref should be an output, ");
  //     diag << "missed memref: " << memref << "\n";
  //     return diag;
  //   }
  return success();
}

//===----------------------------------------------------------------------===//
// DataflowBufferOp
//===----------------------------------------------------------------------===//

LogicalResult DataflowBufferOp::verify() {
  if (depth() != 1 && level())
    return emitOpError("only buffer with depth of 1 can have level attribute");
  return success();
}

namespace {
struct DataflowBufferCanonicalizePattern
    : public OpRewritePattern<DataflowBufferOp> {
  using OpRewritePattern<DataflowBufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(DataflowBufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (auto defOp = buffer.input().getDefiningOp<DataflowBufferOp>()) {
      buffer.inputMutable().assign(defOp.input());
      auto newDepth = buffer.depth() + defOp.depth();
      buffer->setAttr(buffer.depthAttrName(),
                      rewriter.getUI32IntegerAttr(newDepth));
      return success();
    }
    return failure();
  }
};
} // namespace

void DataflowBufferOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                                   MLIRContext *context) {
  results.add<DataflowBufferCanonicalizePattern>(context);
}

bool DataflowBufferOp::isExternal() {
  if (getType().isa<TensorType>())
    return true;
  if (auto type = getType().dyn_cast<MemRefType>())
    if (type.getMemorySpaceAsInt() == (unsigned)MemoryKind::DRAM)
      return true;
  return false;
}

//===----------------------------------------------------------------------===//
// Stream operations
//===----------------------------------------------------------------------===//

// Verify users of the operation are legal.
template <typename OpType> static LogicalResult verifyChannelUsers(OpType op) {
  unsigned numRead = 0, numWrite = 0;
  for (auto user : op.getChannelUsers()) {
    if (isa<StreamReadOp>(user))
      ++numRead;
    else if (isa<StreamWriteOp>(user))
      ++numWrite;
    else
      return user->emitOpError("stream channel has unsupported user");
  }
  if (numWrite > 1)
    return op->emitOpError("stream channel is written by multiple ops");
  return success();
}

LogicalResult StreamChannelOp::verify() { return verifyChannelUsers(*this); }

LogicalResult StreamReadOp::verify() {
  if (result())
    if (channel().getType().cast<StreamType>().getElementType() !=
        result().getType())
      return emitOpError("result type doesn't align with channel type");
  return success();
}

LogicalResult StreamWriteOp::verify() {
  if (channel().getType().cast<StreamType>().getElementType() !=
      value().getType())
    return emitOpError("value type doesn't align with channel type");
  return success();
}

//===----------------------------------------------------------------------===//
// Primitive operations
//===----------------------------------------------------------------------===//

LogicalResult PrimMulOp::verify() {
  auto AIsVector = A().getType().isa<VectorType>();
  auto BIsVector = B().getType().isa<VectorType>();
  auto CIsVector = C().getType().isa<VectorType>();

  if ((AIsVector || BIsVector) && CIsVector)
    return success();
  if (!AIsVector && !BIsVector && !CIsVector)
    return success();
  return failure();
}

bool PrimMulOp::isPackMul() {
  auto AIsVector = A().getType().isa<VectorType>();
  auto BIsVector = B().getType().isa<VectorType>();
  return (AIsVector && !BIsVector) || (!AIsVector && BIsVector);
}

namespace {
struct SimplifyPrimCastOp : public OpRewritePattern<PrimCastOp> {
  using OpRewritePattern<PrimCastOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(PrimCastOp cast,
                                PatternRewriter &rewriter) const override {
    if (cast.input().getType() == cast.output().getType()) {
      rewriter.replaceOp(cast, cast.input());
      return success();
    }

    // If the input of the cast is defined by another cast, then the two casts
    // can be merged into one.
    if (cast.input().hasOneUse())
      if (auto defCast = cast.input().getDefiningOp<PrimCastOp>()) {
        rewriter.replaceOpWithNewOp<PrimCastOp>(cast, cast.getType(),
                                                defCast.input());
        return success();
      }
    return failure();
  }
};
} // namespace

void PrimCastOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                             MLIRContext *context) {
  results.add<SimplifyPrimCastOp>(context);
}

LogicalResult PrimConstOp::verify() {
  auto memrefType = getType();
  auto attrType = value().getType().cast<TensorType>();
  if (memrefType.getElementType() != attrType.getElementType())
    return emitOpError("element type mismatch");
  if (!memrefType.hasStaticShape() || !attrType.hasStaticShape())
    return emitOpError("has dynamic shape");
  if (memrefType.getShape() != attrType.getShape())
    return emitOpError("shape mismatch");
  return success();
}

//===----------------------------------------------------------------------===//
// ResourceAttr
//===----------------------------------------------------------------------===//

Attribute ResourceAttr::parse(AsmParser &p, Type type) {
  StringRef lutKw, dspKw, bramKw;
  int64_t lut, dsp, bram;
  if (p.parseLess() || p.parseKeyword(&lutKw) || p.parseEqual() ||
      p.parseInteger(lut) || p.parseComma() || p.parseKeyword(&dspKw) ||
      p.parseEqual() || p.parseInteger(dsp) || p.parseComma() ||
      p.parseKeyword(&bramKw) || p.parseEqual() || p.parseInteger(bram) ||
      p.parseGreater())
    return Attribute();

  if (lutKw != "lut" || dspKw != "dsp" || bramKw != "bram")
    return Attribute();

  return ResourceAttr::get(p.getContext(), lut, dsp, bram);
}

void ResourceAttr::print(AsmPrinter &p) const {
  p << "<lut=" << getLut() << ", dsp=" << getDsp() << ", bram=" << getBram()
    << ">";
}

//===----------------------------------------------------------------------===//
// TimingAttr
//===----------------------------------------------------------------------===//

Attribute TimingAttr::parse(AsmParser &p, Type type) {
  int64_t begin, end, latency, interval;
  if (p.parseLess() || p.parseInteger(begin) || p.parseArrow() ||
      p.parseInteger(end) || p.parseComma() || p.parseInteger(latency) ||
      p.parseComma() || p.parseInteger(interval) || p.parseGreater())
    return Attribute();

  return TimingAttr::get(p.getContext(), begin, end, latency, interval);
}

void TimingAttr::print(AsmPrinter &p) const {
  p << "<" << getBegin() << " -> " << getEnd() << ", " << getLatency() << ", "
    << getInterval() << ">";
}

//===----------------------------------------------------------------------===//
// LoopInfoAttr
//===----------------------------------------------------------------------===//

Attribute LoopInfoAttr::parse(AsmParser &p, Type type) {
  StringRef flattenTripCountKw, iterLatencyKw, minIIKw;
  int64_t flattenTripCount, iterLatency, minII;
  if (p.parseLess() || p.parseKeyword(&flattenTripCountKw) || p.parseEqual() ||
      p.parseInteger(flattenTripCount) || p.parseComma() ||
      p.parseKeyword(&iterLatencyKw) || p.parseEqual() ||
      p.parseInteger(iterLatency) || p.parseComma() ||
      p.parseKeyword(&minIIKw) || p.parseEqual() || p.parseInteger(minII) ||
      p.parseGreater())
    return Attribute();

  if (flattenTripCountKw != "flattenTripCount" ||
      iterLatencyKw != "iterLatency" || minIIKw != "minII")
    return Attribute();

  return LoopInfoAttr::get(p.getContext(), flattenTripCount, iterLatency,
                           minII);
}

void LoopInfoAttr::print(AsmPrinter &p) const {
  p << "<flattenTripCount=" << getFlattenTripCount()
    << ", iterLatency=" << getIterLatency() << ", minII=" << getMinII() << ">";
}

//===----------------------------------------------------------------------===//
// LoopDirectiveAttr
//===----------------------------------------------------------------------===//

Attribute LoopDirectiveAttr::parse(AsmParser &p, Type type) {
  StringRef pipelineKw, targetIIKw, dataflowKw, flattenKw;
  StringRef pipeline, dataflow, flatten;
  int64_t targetII;
  if (p.parseLess() || p.parseKeyword(&pipelineKw) || p.parseEqual() ||
      p.parseKeyword(&pipeline) || p.parseComma() ||
      p.parseKeyword(&targetIIKw) || p.parseEqual() ||
      p.parseInteger(targetII) || p.parseComma() ||
      p.parseKeyword(&dataflowKw) || p.parseEqual() ||
      p.parseKeyword(&dataflow) || p.parseComma() ||
      p.parseKeyword(&flattenKw) || p.parseEqual() ||
      p.parseKeyword(&flatten) || p.parseGreater())
    return Attribute();

  if (pipelineKw != "pipeline" || targetIIKw != "targetII" ||
      dataflowKw != "dataflow" || flattenKw != "flatten")
    return Attribute();

  return LoopDirectiveAttr::get(p.getContext(), pipeline == "true", targetII,
                                dataflow == "true", flatten == "true");
}

void LoopDirectiveAttr::print(AsmPrinter &p) const {
  p << "<pipeline=" << getPipeline() << ", targetII=" << getTargetII()
    << ", dataflow=" << getDataflow() << ", flatten=" << getFlatten() << ">";
}

//===----------------------------------------------------------------------===//
// FuncDirectiveAttr
//===----------------------------------------------------------------------===//

Attribute FuncDirectiveAttr::parse(AsmParser &p, Type type) {
  StringRef pipelineKw, targetIntervalKw, dataflowKw;
  StringRef pipeline, dataflow;
  int64_t targetInterval;
  if (p.parseLess() || p.parseKeyword(&pipelineKw) || p.parseEqual() ||
      p.parseKeyword(&pipeline) || p.parseComma() ||
      p.parseKeyword(&targetIntervalKw) || p.parseEqual() ||
      p.parseInteger(targetInterval) || p.parseComma() ||
      p.parseKeyword(&dataflowKw) || p.parseEqual() ||
      p.parseKeyword(&dataflow) || p.parseGreater())
    return Attribute();

  if (pipelineKw != "pipeline" || targetIntervalKw != "targetInterval" ||
      dataflowKw != "dataflow")
    return Attribute();

  return FuncDirectiveAttr::get(p.getContext(), pipeline == "true",
                                targetInterval, dataflow == "true");
}

void FuncDirectiveAttr::print(AsmPrinter &p) const {
  p << "<pipeline=" << getPipeline()
    << ", targetInterval=" << getTargetInterval()
    << ", dataflow=" << getDataflow() << ">";
}

//===----------------------------------------------------------------------===//
// Include tablegen classes
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/HLSDialect.cpp.inc"
#include "scalehls/Dialect/HLS/HLSEnums.cpp.inc"

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLS/HLSTypes.cpp.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLS/HLSAttributes.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/HLS.cpp.inc"
