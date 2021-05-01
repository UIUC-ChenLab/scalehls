//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLSCpp/HLSCpp.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/PatternMatch.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// HLSCpp dilaect
//===----------------------------------------------------------------------===//

void HLSCppDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
      >();

  addAttributes<
#define GET_ATTRDEF_LIST
#include "scalehls/Dialect/HLSCpp/HLSCppAttributes.cpp.inc"
      >();
}

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCppAttributes.cpp.inc"

Attribute HLSCppDialect::parseAttribute(DialectAsmParser &p, Type type) const {
  StringRef attrName;
  Attribute attr;

  if (p.parseKeyword(&attrName))
    return Attribute();

  auto parseResult =
      generatedAttributeParser(getContext(), p, attrName, type, attr);
  if (parseResult.hasValue())
    return attr;

  p.emitError(p.getNameLoc(), "Unexpected hlscpp attribute");
  return Attribute();
}

void HLSCppDialect::printAttribute(Attribute attr, DialectAsmPrinter &p) const {
  if (succeeded(generatedAttributePrinter(attr, p)))
    return;
  llvm_unreachable("Unexpected attribute");
}

//===----------------------------------------------------------------------===//
// ResourceAttr
//===----------------------------------------------------------------------===//

Attribute ResourceAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                              Type type) {
  StringRef lutKw, dspKw, bramKw, nonShareDspKw;
  int64_t lut, dsp, bram, nonShareDsp;
  if (p.parseLess() || p.parseKeyword(&lutKw) || p.parseEqual() ||
      p.parseInteger(lut) || p.parseComma() || p.parseKeyword(&dspKw) ||
      p.parseEqual() || p.parseInteger(dsp) || p.parseComma() ||
      p.parseKeyword(&bramKw) || p.parseEqual() || p.parseInteger(bram) ||
      p.parseComma() || p.parseKeyword(&nonShareDspKw) || p.parseEqual() ||
      p.parseInteger(nonShareDsp) || p.parseGreater())
    return Attribute();

  if (lutKw != "lut" || dspKw != "dsp" || bramKw != "bram" ||
      nonShareDspKw != "nonShareDsp")
    return Attribute();

  return ResourceAttr::get(ctxt, lut, dsp, bram, nonShareDsp);
}

void ResourceAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<lut=" << getLut() << ", dsp=" << getDsp()
    << ", bram=" << getBram() << ", nonShareDsp=" << getNonShareDsp() << ">";
}

//===----------------------------------------------------------------------===//
// TimingAttr
//===----------------------------------------------------------------------===//

Attribute TimingAttr::parse(MLIRContext *ctxt, DialectAsmParser &p, Type type) {
  int64_t begin, end, latency, interval;
  if (p.parseLess() || p.parseInteger(begin) || p.parseArrow() ||
      p.parseInteger(end) || p.parseComma() || p.parseInteger(latency) ||
      p.parseComma() || p.parseInteger(interval) || p.parseGreater())
    return Attribute();

  return TimingAttr::get(ctxt, begin, end, latency, interval);
}

void TimingAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<" << getBegin() << " -> " << getEnd() << ", "
    << getLatency() << ", " << getInterval() << ">";
}

//===----------------------------------------------------------------------===//
// LoopInfoAttr
//===----------------------------------------------------------------------===//

Attribute LoopInfoAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                              Type type) {
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

  return LoopInfoAttr::get(ctxt, flattenTripCount, iterLatency, minII);
}

void LoopInfoAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<flattenTripCount=" << getFlattenTripCount()
    << ", iterLatency=" << getIterLatency() << ", minII=" << getMinII() << ">";
}

//===----------------------------------------------------------------------===//
// LoopDirectiveAttr
//===----------------------------------------------------------------------===//

Attribute LoopDirectiveAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                                   Type type) {
  StringRef pipelineKw, targetIIKw, dataflowKw, flattenKw, parallelKw;
  bool pipeline, dataflow, flatten, parallel;
  int64_t targetII;
  if (p.parseLess() || p.parseKeyword(&pipelineKw) || p.parseEqual() ||
      p.parseInteger(pipeline) || p.parseComma() ||
      p.parseKeyword(&targetIIKw) || p.parseEqual() ||
      p.parseInteger(targetII) || p.parseComma() ||
      p.parseKeyword(&dataflowKw) || p.parseEqual() ||
      p.parseInteger(dataflow) || p.parseComma() ||
      p.parseKeyword(&flattenKw) || p.parseEqual() || p.parseInteger(flatten) ||
      p.parseComma() || p.parseKeyword(&parallelKw) || p.parseEqual() ||
      p.parseInteger(parallel) || p.parseGreater())
    return Attribute();

  if (pipelineKw != "pipeline" || targetIIKw != "targetII" ||
      dataflowKw != "dataflow" || flattenKw != "flatten" ||
      parallelKw != "parallel")
    return Attribute();

  return LoopDirectiveAttr::get(ctxt, pipeline, targetII, dataflow, flatten,
                                parallel);
}

void LoopDirectiveAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<pipeline=" << getPipeline()
    << ", targetII=" << getTargetII() << ", dataflow=" << getDataflow()
    << ", flatten=" << getFlatten() << ", parallel=" << getParallel() << ">";
}

//===----------------------------------------------------------------------===//
// FuncDirectiveAttr
//===----------------------------------------------------------------------===//

Attribute FuncDirectiveAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                                   Type type) {
  StringRef pipelineKw, targetIntervalKw, dataflowKw, topFuncKw;
  bool pipeline, dataflow, topFunc;
  int64_t targetInterval;
  if (p.parseLess() || p.parseKeyword(&pipelineKw) || p.parseEqual() ||
      p.parseInteger(pipeline) || p.parseComma() ||
      p.parseKeyword(&targetIntervalKw) || p.parseEqual() ||
      p.parseInteger(targetInterval) || p.parseComma() ||
      p.parseKeyword(&dataflowKw) || p.parseEqual() ||
      p.parseInteger(dataflow) || p.parseComma() ||
      p.parseKeyword(&topFuncKw) || p.parseEqual() || p.parseInteger(topFunc) ||
      p.parseGreater())
    return Attribute();

  if (pipelineKw != "pipeline" || targetIntervalKw != "targetInterval" ||
      dataflowKw != "dataflow" || topFuncKw != "topFunc")
    return Attribute();

  return FuncDirectiveAttr::get(ctxt, pipeline, targetInterval, dataflow,
                                topFunc);
}

void FuncDirectiveAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<pipeline=" << getPipeline()
    << ", targetInterval=" << getTargetInterval()
    << ", dataflow=" << getDataflow() << ", topFunc=" << getTopFunc() << ">";
}

//===----------------------------------------------------------------------===//
// HLSCpp operation pattern rewritters
//===----------------------------------------------------------------------===//

namespace {
struct SimplifyCastOp : public OpRewritePattern<CastOp> {
  using OpRewritePattern<CastOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(CastOp castOp,
                                PatternRewriter &rewriter) const override {
    if (castOp.input().getType() == castOp.output().getType()) {
      castOp.output().replaceAllUsesWith(castOp.input());
      rewriter.eraseOp(castOp);
    }

    return success();
  }
};
} // namespace

void CastOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.add<SimplifyCastOp>(context);
}

//===----------------------------------------------------------------------===//
// Include tablegen classes
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLSCpp/HLSCppEnums.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
