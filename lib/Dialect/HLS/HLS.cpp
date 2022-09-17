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
#include "scalehls/Support/Utils.h"
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
// ScheduleOp and ReturnOp
//===----------------------------------------------------------------------===//

namespace {
struct SimplifyScheduleHierarchy : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    // If the schedule doesn't contain any task or node, the schedule can be
    // fully inlined.
    if (schedule.getOps<TaskOp>().empty() &&
        schedule.getOps<NodeOp>().empty()) {
      auto &scheduleOps = schedule.getBody().front().getOperations();
      auto &parentOps = schedule->getBlock()->getOperations();
      parentOps.splice(schedule->getIterator(), scheduleOps,
                       scheduleOps.begin(), std::prev(scheduleOps.end()));

      rewriter.replaceOp(schedule, schedule.getReturnOp()->getOperands());
      return success();
    }
    return failure();
  }
};
} // namespace

void ScheduleOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                             MLIRContext *context) {
  results.add<SimplifyScheduleHierarchy>(context);
}

/// Get the terminator return op.
ReturnOp ScheduleOp::getReturnOp() {
  return cast<ReturnOp>(getBody().front().getTerminator());
}

LogicalResult ScheduleOp::verify() {
  if (getIsLegal()) {
    if (llvm::any_of(getOps(), [](Operation &op) {
          return !isa<NodeOp, BufferOp, ConstBufferOp, StreamOp, ReturnOp>(op);
        })) {
      auto diag =
          mlir::emitError(getLoc(), "legal schedule contains non-dataflow ops");
      for (auto &op : getOps())
        if (!isa<HLSDialect>(op.getDialect()))
          diag.attachNote(op.getLoc())
              .append("see current op:")
              .appendOp(op, OpPrintingFlags().printGenericOpForm());
      return diag;
    }

    for (auto node : getOps<NodeOp>()) {
      if (!node.getLevel()) {
        auto diag = mlir::emitError(
            getLoc(), "legal schedule contains node not scheduled: ");
        diag.attachNote(node.getLoc())
            .append("see current node: ")
            .appendOp(*node, OpPrintingFlags().printGenericOpForm());
        return diag;
      }
      for (auto output : node.getOutputs())
        if (getConsumersInSchedule(output, *this).size() > 1 ||
            getProducersInSchedule(output, *this).size() > 1) {
          auto diag = mlir::emitError(
              getLoc(),
              "legal schedule violates single-consumer or single-producer\n");
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

LogicalResult ReturnOp::verify() {
  if (getOperandTypes() !=
      (*this)->getParentOfType<ScheduleOp>().getResultTypes())
    return emitOpError("return type doesn't align with schedule type");
  return success();
}

//===----------------------------------------------------------------------===//
// TaskOp and YieldOp
//===----------------------------------------------------------------------===//

namespace {
struct SimplifyTaskIOs : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    auto yield = task.getYieldOp();
    bool hasUnusedPort = false;

    // Identify output values that are used.
    SmallVector<Value, 4> usedOutputs;
    SmallVector<Value, 4> usedResults;
    for (auto result : task.getResults())
      if (result.use_empty()) {
        hasUnusedPort = true;
      } else {
        usedOutputs.push_back(yield.getOperand(result.getResultNumber()));
        usedResults.push_back(result);
      }

    // Identify input values that are used.
    llvm::SmallDenseSet<BlockArgument, 4> unusedArgs;
    SmallVector<Value, 4> usedInputs;
    for (auto arg : task.getBody().getArguments())
      if (arg.use_empty()) {
        hasUnusedPort = true;
        unusedArgs.insert(arg);
      } else {
        usedInputs.push_back(task.getOperand(arg.getArgNumber()));
      }
    task.getBody().front().eraseArguments(
        [&](BlockArgument arg) { return unusedArgs.count(arg); });

    // Construct new graph task.
    if (hasUnusedPort) {
      rewriter.setInsertionPoint(yield);
      rewriter.replaceOpWithNewOp<YieldOp>(yield, usedOutputs);

      rewriter.setInsertionPoint(task);
      auto newTask = rewriter.create<TaskOp>(
          task.getLoc(), ValueRange(usedOutputs), usedInputs);
      rewriter.inlineRegionBefore(task.getBody(), newTask.getBody(),
                                  newTask.getBody().end());
      for (auto t : llvm::zip(usedResults, newTask.getResults()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

      rewriter.eraseOp(task);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct SimplifyTaskHierarchy : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    // If the parent schedule only contains the current task, then the task can
    // be fully inlined.
    if (llvm::hasSingleElement(task.getScheduleOp().getOps<TaskOp>())) {
      auto &taskOps = task.getBody().front().getOperations();
      auto &scheduleOps =
          task.getScheduleOp().getBody().front().getOperations();
      scheduleOps.splice(task->getIterator(), taskOps, taskOps.begin(),
                         std::prev(taskOps.end()));

      for (auto t :
           llvm::zip(task.getBody().getArguments(), task.getOperands()))
        std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
      rewriter.replaceOp(task, task.getYieldOp()->getOperands());
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

/// Get the parent schedule op.
ScheduleOp TaskOp::getScheduleOp() {
  return (*this)->getParentOfType<ScheduleOp>();
}

/// Get the terminator output op.
YieldOp TaskOp::getYieldOp() {
  return cast<YieldOp>(getBody().front().getTerminator());
}

LogicalResult TaskOp::verify() {
  if (getOperandTypes() != getBody().getArgumentTypes())
    return emitOpError("operand type doesn't align with argument type");
  return success();
}

LogicalResult YieldOp::verify() {
  if (getOperandTypes() != (*this)->getParentOfType<TaskOp>().getResultTypes())
    return emitOpError("yield type doesn't align with task type");
  return success();
}

//===----------------------------------------------------------------------===//
// ToStreamOp and ToValueOp
//===----------------------------------------------------------------------===//

LogicalResult ToStreamOp::verify() {
  if (getValue().getType() !=
      getStream().getType().cast<StreamType>().getElementType())
    return emitOpError("value and stream type doesn't match");
  return success();
}

OpFoldResult ToStreamOp::fold(ArrayRef<Attribute>) {
  if (auto toValue = getValue().getDefiningOp<ToValueOp>())
    if (toValue.getStream().getType() == getType())
      return toValue.getStream();
  return {};
}

LogicalResult ToValueOp::verify() {
  if (getValue().getType() !=
      getStream().getType().cast<StreamType>().getElementType())
    return emitOpError("value and stream type doesn't match");
  return success();
}

OpFoldResult ToValueOp::fold(ArrayRef<Attribute>) {
  if (auto toStream = getStream().getDefiningOp<ToStreamOp>())
    if (toStream.getValue().getType() == getType())
      return toStream.getValue();
  return {};
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

namespace {
struct SimplifyNodeHierarchy : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    // If the parent schedule only contains the current node, then the node can
    // be fully inlined.
    if (llvm::hasSingleElement(node.getScheduleOp().getOps<NodeOp>())) {
      auto &nodeOps = node.getBody().front().getOperations();
      auto &scheduleOps =
          node.getScheduleOp().getBody().front().getOperations();
      scheduleOps.splice(node->getIterator(), nodeOps);

      for (auto t :
           llvm::zip(node.getBody().getArguments(), node.getOperands()))
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

/// Get the parent schedule op.
ScheduleOp NodeOp::getScheduleOp() {
  return (*this)->getParentOfType<ScheduleOp>();
}

/// Get input taps.
int32_t NodeOp::getInputTap(unsigned idx) {
  return getInputTaps()[idx].cast<IntegerAttr>().getInt();
}
SmallVector<int32_t, 4> NodeOp::getInputTapsAsInt() {
  SmallVector<int32_t, 4> array;
  for (auto attr : getInputTaps())
    array.push_back(attr.cast<IntegerAttr>().getInt());
  return array;
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

LogicalResult NodeOp::verify() {
  if (getOperandTypes() != getBody().getArgumentTypes())
    return emitOpError("operand type doesn't align with argument type");

  if (llvm::any_of(getParams(), [](Value param) {
        return param.getType().isa<ShapedType, StreamType>();
      }))
    return emitOpError("node params should not be shaped or stream typed");

  if (getInputs().size() != getInputTaps().size())
    return emitOpError("node inputs and input taps are not aligned");
  for (auto t : llvm::zip(getInputs(), getInputTapsAsInt()))
    if (getBufferDepth(std::get<0>(t)) <= (unsigned)std::get<1>(t))
      return emitOpError("node input tap is larger than buffer/stream depth");

  for (auto inputArg : getInputArgs())
    if (llvm::any_of(inputArg.getUses(), isWritten))
      return emitOpError("input operand is written");
  for (auto outputArg : getOutputArgs())
    if (!llvm::any_of(outputArg.getUses(), isWritten))
      return emitOpError("output operand is not written");
  return success();
}

//===----------------------------------------------------------------------===//
// BufferOp and ConstBufferOp
//===----------------------------------------------------------------------===//

int32_t BufferOp::getBufferDepth() { return getDepth(); }

int32_t ConstBufferOp::getBufferDepth() { return 1; }

LogicalResult ConstBufferOp::verify() {
  auto memrefType = getType();
  auto attrType = getValue().getType().cast<TensorType>();
  if (memrefType.getElementType() != attrType.getElementType())
    return emitOpError("element type mismatch");
  if (!memrefType.hasStaticShape() || !attrType.hasStaticShape())
    return emitOpError("has dynamic shape");
  if (memrefType.getShape() != attrType.getShape())
    return emitOpError("shape mismatch");
  return success();
}

//===----------------------------------------------------------------------===//
// StreamOp, StreamReadOp, and StreamWriteOp
//===----------------------------------------------------------------------===//

LogicalResult StreamOp::verify() {
  if (getDepth() != getChannel().getType().cast<StreamType>().getDepth())
    return emitOpError("stream channel depth is not aligned");
  return success();
}

LogicalResult StreamReadOp::verify() {
  if (getResult())
    if (getChannel().getType().cast<StreamType>().getElementType() !=
        getResult().getType())
      return emitOpError("result type doesn't align with channel type");
  return success();
}

LogicalResult StreamWriteOp::verify() {
  if (getChannel().getType().cast<StreamType>().getElementType() !=
      getValue().getType())
    return emitOpError("value type doesn't align with channel type");
  return success();
}

//===----------------------------------------------------------------------===//
// AxiBundleOp, AxiPortOp, and AxiPackOp
//===----------------------------------------------------------------------===//

LogicalResult AxiPortOp::verify() {
  if (getAxi().getType().cast<AxiType>().getElementType() !=
      getValue().getType())
    return emitOpError("axi type doesn't align with value type");
  if (getAxi().getType().cast<AxiType>().getKind() !=
      getBundle().getType().cast<BundleType>().getKind())
    return emitOpError("axi kind doesn't align with bundle kind");
  return success();
}

LogicalResult AxiPackOp::verify() {
  if (getAxi().getType().cast<AxiType>().getElementType() !=
      getValue().getType())
    return emitOpError("axi type doesn't align with value type");
  return success();
}

//===----------------------------------------------------------------------===//
// Primitive operations
//===----------------------------------------------------------------------===//

LogicalResult PrimMulOp::verify() {
  auto AIsVector = getA().getType().isa<VectorType>();
  auto BIsVector = getB().getType().isa<VectorType>();
  auto CIsVector = getC().getType().isa<VectorType>();

  if ((AIsVector || BIsVector) && CIsVector)
    return success();
  if (!AIsVector && !BIsVector && !CIsVector)
    return success();
  return failure();
}

bool PrimMulOp::isPackMul() {
  auto AIsVector = getA().getType().isa<VectorType>();
  auto BIsVector = getB().getType().isa<VectorType>();
  return (AIsVector && !BIsVector) || (!AIsVector && BIsVector);
}

namespace {
struct SimplifyPrimCastOp : public OpRewritePattern<PrimCastOp> {
  using OpRewritePattern<PrimCastOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(PrimCastOp cast,
                                PatternRewriter &rewriter) const override {
    if (cast.getInput().getType() == cast.getOutput().getType()) {
      rewriter.replaceOp(cast, cast.getInput());
      return success();
    }

    // If the input of the cast is defined by another cast, then the two casts
    // can be merged into one.
    if (cast.getInput().hasOneUse())
      if (auto defCast = cast.getInput().getDefiningOp<PrimCastOp>()) {
        rewriter.replaceOpWithNewOp<PrimCastOp>(cast, cast.getType(),
                                                defCast.getInput());
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

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLS/HLSAttributes.cpp.inc"

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLS/HLSTypes.cpp.inc"

#include "scalehls/Dialect/HLS/HLSInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/HLS.cpp.inc"
