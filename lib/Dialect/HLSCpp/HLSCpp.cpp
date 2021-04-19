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
  int64_t begin, end, latency, minII;
  if (p.parseLess() || p.parseInteger(begin) || p.parseArrow() ||
      p.parseInteger(end) || p.parseComma() || p.parseInteger(latency) ||
      p.parseComma() || p.parseInteger(minII) || p.parseGreater())
    return Attribute();

  return TimingAttr::get(ctxt, begin, end, latency, minII);
}

void TimingAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<" << getBegin() << " -> " << getEnd() << ", "
    << getLatency() << ", " << getMinII() << ">";
}

//===----------------------------------------------------------------------===//
// LoopInfoAttr
//===----------------------------------------------------------------------===//

Attribute LoopInfoAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                              Type type) {
  StringRef parallelKw, tripCountKw, flattenTripCountKw, iterLatencyKw;
  bool parallel;
  int64_t tripCount, flattenTripCount, iterLatency;
  if (p.parseLess() || p.parseKeyword(parallelKw) || p.parseEqual() ||
      p.parseInteger(parallel) || p.parseComma() ||
      p.parseKeyword(tripCountKw) || p.parseEqual() ||
      p.parseInteger(tripCount) || p.parseComma() ||
      p.parseKeyword(flattenTripCountKw) || p.parseEqual() ||
      p.parseInteger(flattenTripCount) || p.parseComma() ||
      p.parseKeyword(iterLatencyKw) || p.parseEqual() ||
      p.parseInteger(iterLatency) || p.parseGreater())
    return Attribute();

  if (parallelKw != "parallel" || tripCountKw != "tripCount" ||
      flattenTripCountKw != "flattenTripCount" ||
      iterLatencyKw != "iterLatency")
    return Attribute();

  return LoopInfoAttr::get(ctxt, parallel, tripCount, flattenTripCount,
                           iterLatency);
}

void LoopInfoAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<parallel" << getParallel()
    << ", tripCount=" << getTripCount()
    << ", flattenTripCount=" << getFlattenTripCount()
    << ", iterLatency=" << getIterLatency() << ">";
}

//===----------------------------------------------------------------------===//
// LoopDirectiveAttr
//===----------------------------------------------------------------------===//

Attribute LoopDirectiveAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                                   Type type) {
  StringRef pipelineKw, targetIIKw, flattenKw;
  bool pipeline, flatten;
  int64_t targetII;
  if (p.parseLess() || p.parseKeyword(pipelineKw) || p.parseEqual() ||
      p.parseInteger(pipeline) || p.parseComma() ||
      p.parseKeyword(targetIIKw) || p.parseEqual() ||
      p.parseInteger(targetII) || p.parseComma() || p.parseKeyword(flattenKw) ||
      p.parseEqual() || p.parseInteger(flatten) || p.parseGreater())
    return Attribute();

  if (pipelineKw != "pipeline" || targetIIKw != "targetII" ||
      flattenKw != "flatten")
    return Attribute();

  return LoopDirectiveAttr::get(ctxt, pipeline, targetII, flatten);
}

void LoopDirectiveAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<pipeline=" << getPipeline()
    << ", targetII=" << getTargetII() << ", flatten=" << getFlatten() << ">";
}

//===----------------------------------------------------------------------===//
// FuncDirectiveAttr
//===----------------------------------------------------------------------===//

Attribute FuncDirectiveAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                                   Type type) {
  StringRef pipelineKw, targetIIKw, dataflowKw, topFuncKw;
  bool pipeline, dataflow, topFunc;
  int64_t targetII;
  if (p.parseLess() || p.parseKeyword(pipelineKw) || p.parseEqual() ||
      p.parseInteger(pipeline) || p.parseComma() ||
      p.parseKeyword(targetIIKw) || p.parseEqual() ||
      p.parseInteger(targetII) || p.parseComma() ||
      p.parseKeyword(dataflowKw) || p.parseEqual() ||
      p.parseInteger(dataflow) || p.parseComma() || p.parseKeyword(topFuncKw) ||
      p.parseEqual() || p.parseInteger(topFunc) || p.parseGreater())
    return Attribute();

  if (pipelineKw != "pipeline" || targetIIKw != "targetII" ||
      dataflowKw != "dataflow" || topFuncKw != "topFunc")
    return Attribute();

  return FuncDirectiveAttr::get(ctxt, pipeline, targetII, dataflow, topFunc);
}

void FuncDirectiveAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<pipeline=" << getPipeline()
    << ", targetII=" << getTargetII() << ", dataflow=" << getDataflow()
    << ", topFunc=" << getTopFunc() << ">";
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
#include "scalehls/Dialect/HLSCpp/HLSCppInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
