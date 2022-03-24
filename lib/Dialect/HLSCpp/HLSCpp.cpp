//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLSCpp/HLSCpp.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/PatternMatch.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// HLSCpp dialect
//===----------------------------------------------------------------------===//

void HLSCppDialect::initialize() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "scalehls/Dialect/HLSCpp/HLSCppTypes.cpp.inc"
      >();

  addAttributes<
#define GET_ATTRDEF_LIST
#include "scalehls/Dialect/HLSCpp/HLSCppAttributes.cpp.inc"
      >();

  addOperations<
#define GET_OP_LIST
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// HLSCpp dialect utils
//===----------------------------------------------------------------------===//

/// Get the users of a stream channel. If the channel is used by a function
/// call, this method will recursively look into the corresponding sub-function.
/// If the channel is used by a function return, this method will recursively
/// look into each function that calls the parent function of the return.
void hlscpp::getStreamChannelUsers(Value channel,
                                   SmallVectorImpl<Operation *> &users) {
  assert(channel.getType().isa<StreamType>() && "channel must be stream type");

  for (auto &use : channel.getUses()) {
    auto user = use.getOwner();
    if (auto call = dyn_cast<func::CallOp>(user)) {
      auto func = SymbolTable::lookupNearestSymbolFrom<FuncOp>(
          call, call.getCalleeAttr());
      if (!func.isPrivate())
        getStreamChannelUsers(func.getArgument(use.getOperandNumber()), users);

    } else if (auto returnOp = dyn_cast<func::ReturnOp>(user)) {
      auto func = returnOp->getParentOfType<FuncOp>();
      auto symbolUses = func.getSymbolUses(func->getParentOfType<ModuleOp>());
      if (!symbolUses.hasValue())
        continue;
      for (auto &symbolUse : symbolUses.getValue()) {
        if (auto call = dyn_cast<func::CallOp>(symbolUse.getUser()))
          getStreamChannelUsers(call.getResult(use.getOperandNumber()), users);
      }
    } else
      users.push_back(user);
  }
}

/// Timing attribute utils.
TimingAttr hlscpp::getTiming(Operation *op) {
  return op->getAttrOfType<TimingAttr>("timing");
}
void hlscpp::setTiming(Operation *op, TimingAttr timing) {
  assert(timing.getBegin() <= timing.getEnd() && "invalid timing attribute");
  op->setAttr("timing", timing);
}
void hlscpp::setTiming(Operation *op, int64_t begin, int64_t end,
                       int64_t latency, int64_t minII) {
  auto timing = TimingAttr::get(op->getContext(), begin, end, latency, minII);
  setTiming(op, timing);
}

/// Resource attribute utils.
ResourceAttr hlscpp::getResource(Operation *op) {
  return op->getAttrOfType<ResourceAttr>("resource");
}
void hlscpp::setResource(Operation *op, ResourceAttr resource) {
  op->setAttr("resource", resource);
}
void hlscpp::setResource(Operation *op, int64_t lut, int64_t dsp,
                         int64_t bram) {
  auto resource = ResourceAttr::get(op->getContext(), lut, dsp, bram);
  setResource(op, resource);
}

/// Loop information attribute utils.
LoopInfoAttr hlscpp::getLoopInfo(Operation *op) {
  return op->getAttrOfType<LoopInfoAttr>("loop_info");
}
void hlscpp::setLoopInfo(Operation *op, LoopInfoAttr loopInfo) {
  op->setAttr("loop_info", loopInfo);
}
void hlscpp::setLoopInfo(Operation *op, int64_t flattenTripCount,
                         int64_t iterLatency, int64_t minII) {
  auto loopInfo =
      LoopInfoAttr::get(op->getContext(), flattenTripCount, iterLatency, minII);
  setLoopInfo(op, loopInfo);
}

/// Loop directives attribute utils.
LoopDirectiveAttr hlscpp::getLoopDirective(Operation *op) {
  return op->getAttrOfType<LoopDirectiveAttr>("loop_directive");
}
void hlscpp::setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective) {
  op->setAttr("loop_directive", loopDirective);
}
void hlscpp::setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                              bool dataflow, bool flatten) {
  auto loopDirective = LoopDirectiveAttr::get(op->getContext(), pipeline,
                                              targetII, dataflow, flatten);
  setLoopDirective(op, loopDirective);
}

/// Parrallel and point loop attribute utils.
void hlscpp::setParallelAttr(Operation *op) {
  op->setAttr("parallel", UnitAttr::get(op->getContext()));
}
bool hlscpp::hasParallelAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("parallel");
}
void hlscpp::setPointAttr(Operation *op) {
  op->setAttr("point", UnitAttr::get(op->getContext()));
}
bool hlscpp::hasPointAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("point");
}

/// Function directives attribute utils.
FuncDirectiveAttr hlscpp::getFuncDirective(Operation *op) {
  return op->getAttrOfType<FuncDirectiveAttr>("func_directive");
}
void hlscpp::setFuncDirective(Operation *op, FuncDirectiveAttr funcDirective) {
  op->setAttr("func_directive", funcDirective);
}
void hlscpp::setFuncDirective(Operation *op, bool pipeline,
                              int64_t targetInterval, bool dataflow) {
  auto funcDirective = FuncDirectiveAttr::get(op->getContext(), pipeline,
                                              targetInterval, dataflow);
  setFuncDirective(op, funcDirective);
}

/// Top and runtime function attribute utils.
void hlscpp::setTopFuncAttr(Operation *op) {
  op->setAttr("top_func", UnitAttr::get(op->getContext()));
}
bool hlscpp::hasTopFuncAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("top_func");
}
void hlscpp::setRuntimeAttr(Operation *op) {
  op->setAttr("runtime", UnitAttr::get(op->getContext()));
}
bool hlscpp::hasRuntimeAttr(Operation *op) {
  return op->hasAttrOfType<UnitAttr>("runtime");
}

//===----------------------------------------------------------------------===//
// Stream operations
//===----------------------------------------------------------------------===//

// Verify users of the operation are legal.
template <typename OpType> static LogicalResult verifyChannelUsers(OpType op) {
  unsigned numRead = 0, numWrite = 0;
  for (auto user : op.getChannelUsers()) {
    if (isa<StreamReadOp, StreamBufferOp>(user))
      ++numRead;
    else if (isa<StreamWriteOp>(user))
      ++numWrite;
    else
      return user->emitOpError("unsupported user of a stream channel");
  }
  if (numWrite > 1)
    return op->emitOpError("stream channel is written by multiple ops");
  return success();
}

static LogicalResult verify(StreamChannelOp op) {
  return verifyChannelUsers(op);
}

static LogicalResult verify(StreamReadOp op) {
  if (op.result())
    if (op.channel().getType().cast<StreamType>().getElementType() !=
        op.result().getType())
      return failure();
  return success();
}

static LogicalResult verify(StreamWriteOp op) {
  if (op.channel().getType().cast<StreamType>().getElementType() !=
      op.value().getType())
    return failure();
  return success();
}

static LogicalResult verify(StreamBufferOp op) {
  if (op.input().getType() != op.output().getType())
    return failure();
  return verifyChannelUsers(op);
}

//===----------------------------------------------------------------------===//
// PrimMulOp
//===----------------------------------------------------------------------===//

static LogicalResult verify(PrimMulOp op) {
  auto AIsVector = op.A().getType().isa<VectorType>();
  auto BIsVector = op.B().getType().isa<VectorType>();
  auto CIsVector = op.C().getType().isa<VectorType>();

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
// HLSCpp operation canonicalizers
//===----------------------------------------------------------------------===//

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

namespace {
struct SimplifyBufferOp : public OpRewritePattern<BufferOp> {
  using OpRewritePattern<BufferOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(BufferOp buffer,
                                PatternRewriter &rewriter) const override {
    if (auto defOp = buffer.input().getDefiningOp<BufferOp>()) {
      buffer.inputMutable().assign(defOp.input());
      return success();
    }
    return failure();
  }
};
} // namespace

void BufferOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                           MLIRContext *context) {
  results.add<SimplifyBufferOp>(context);
}

//===----------------------------------------------------------------------===//
// Include tablegen classes
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLSCpp/HLSCppDialect.cpp.inc"
#include "scalehls/Dialect/HLSCpp/HLSCppEnums.cpp.inc"

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCppTypes.cpp.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCppAttributes.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
