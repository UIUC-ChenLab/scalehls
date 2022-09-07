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
// TaskOp
//===----------------------------------------------------------------------===//

namespace {
struct SimplifyTaskIOs : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp node,
                                PatternRewriter &rewriter) const override {
    auto yield = node.getYieldOp();
    bool hasUnusedPort = false;

    // Identify output values that are used.
    SmallVector<Value, 4> usedOutputs;
    SmallVector<Value, 4> usedResults;
    for (auto result : node.getResults())
      if (result.use_empty()) {
        hasUnusedPort = true;
      } else {
        usedOutputs.push_back(yield.getOperand(result.getResultNumber()));
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
      rewriter.setInsertionPoint(yield);
      rewriter.replaceOpWithNewOp<YieldOp>(yield, usedOutputs);

      rewriter.setInsertionPoint(node);
      auto newNode = rewriter.create<TaskOp>(
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
struct SimplifyTaskHierarchy : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp node,
                                PatternRewriter &rewriter) const override {
    // If the parent block is another graph node OR only contains the current
    // graph node, then the node can be fully inlined.
    auto parentBlock = node->getBlock();
    if (isa<TaskOp>(parentBlock->getParentOp()) ||
        llvm::hasSingleElement(parentBlock->getOps<TaskOp>())) {
      auto &nodeOps = node.getBody()->getOperations();
      auto &parentOps = parentBlock->getOperations();
      parentOps.splice(node->getIterator(), nodeOps, nodeOps.begin(),
                       std::prev(nodeOps.end()));

      for (auto t :
           llvm::zip(node.getBody()->getArguments(), node.getOperands()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      rewriter.replaceOp(node, node.getYieldOp()->getOperands());
      return success();
    }
    return failure();
  }
};
} // namespace

void TaskOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.add<SimplifyTaskHierarchy>(context);
  results.add<SimplifyTaskIOs>(context);
}

/// Get the terminator output op.
YieldOp TaskOp::getYieldOp() {
  return cast<YieldOp>(body().front().getTerminator());
}

LogicalResult TaskOp::verify() {
  if (getOperandTypes() != getBody()->getArgumentTypes())
    return emitOpError("operand type doesn't align with argument type");
  return success();
}

//===----------------------------------------------------------------------===//
// YieldOp
//===----------------------------------------------------------------------===//

LogicalResult YieldOp::verify() {
  if (getOperandTypes() != (*this)->getParentOfType<TaskOp>().getResultTypes())
    return emitOpError("yield type doesn't align with task type");
  return success();
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
    SmallVector<unsigned, 4> unusedArgNumbers;
    SmallVector<Value, 4> usedPorts;
    for (auto arg : node.getBody()->getArguments())
      if (arg.use_empty()) {
        hasUnusedPort = true;
        unusedArgNumbers.push_back(arg.getArgNumber());
      } else {
        usedPorts.push_back(node.getOperand(arg.getArgNumber()));
      }
    node.getBody()->eraseArguments(unusedArgNumbers);

    // Construct new dataflow node.
    if (hasUnusedPort) {
      rewriter.setInsertionPoint(node);
      auto newNode =
          rewriter.create<NodeOp>(node.getLoc(), TypeRange(), usedPorts);
      rewriter.inlineRegionBefore(node.body(), newNode.body(),
                                  newNode.body().end());
      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct SimplifyNodeHierarchy : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    // If the parent block is another node OR only contains the current node,
    // then the node can be fully inlined.
    auto parentBlock = node->getBlock();
    if (isa<NodeOp>(parentBlock->getParentOp()) ||
        llvm::hasSingleElement(parentBlock->getOps<NodeOp>())) {
      auto &nodeOps = node.getBody()->getOperations();
      auto &parentOps = parentBlock->getOperations();
      parentOps.splice(node->getIterator(), nodeOps);

      for (auto t :
           llvm::zip(node.getBody()->getArguments(), node.getOperands()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      rewriter.eraseOp(node);
      return success();
    }
    return failure();
  }
};
} // namespace

void NodeOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.add<SimplifyNodeHierarchy>(context);
  results.add<SimplifyNodeIOs>(context);
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
  return operand.getOwner() == *this && isOutput(operand.getOperandNumber());
}
bool NodeOp::isOutput(unsigned operandIdx) {
  return operandIdx >= getODSOperandIndexAndLength(1).first;
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

LogicalResult NodeOp::verify() {
  // for (auto outputArg : getOutputArguments()) {
  //   if (!llvm::any_of(outputArg.getUses(), [](OpOperand &use) {}))
  //     return failure();
  // }
  return success();
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
// Stream operations
//===----------------------------------------------------------------------===//

// Verify users of the operation are legal.
template <typename OpType> static LogicalResult verifyChannelUsers(OpType op) {
  return success();
}

LogicalResult StreamOp::verify() { return verifyChannelUsers(*this); }

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
