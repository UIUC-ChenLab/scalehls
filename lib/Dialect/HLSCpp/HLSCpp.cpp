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
  StringRef lutKw, ffKw, dspKw, bramKw;
  int64_t lut, ff, dsp, bram;
  if (p.parseLess() || p.parseKeyword(lutKw) || p.parseEqual() ||
      p.parseInteger(lut) || p.parseComma() || p.parseKeyword(ffKw) ||
      p.parseEqual() || p.parseInteger(ff) || p.parseComma() ||
      p.parseKeyword(dspKw) || p.parseEqual() || p.parseInteger(dsp) ||
      p.parseComma() || p.parseKeyword(bramKw) || p.parseEqual() ||
      p.parseInteger(bram) || p.parseGreater())
    return Attribute();

  if (lutKw != "lut" || ffKw != "ff" || dspKw != "dsp" || bramKw != "bram")
    return Attribute();

  return ResourceAttr::get(ctxt, lut, ff, dsp, bram);
}

void ResourceAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<lut=" << getLut() << ", ff=" << getFf()
    << ", dsp=" << getDsp() << ", bram=" << getBram() << ">";
}

//===----------------------------------------------------------------------===//
// ScheduleAttr
//===----------------------------------------------------------------------===//

Attribute ScheduleAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                              Type type) {
  int64_t begin, end;
  if (p.parseLSquare() || p.parseInteger(begin) || p.parseComma() ||
      p.parseInteger(end) || p.parseRParen())
    return Attribute();

  return ScheduleAttr::get(ctxt, begin, end);
}

void ScheduleAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "[" << getBegin() << ", " << getEnd() << ")";
}

//===----------------------------------------------------------------------===//
// ModuleInfoAttr
//===----------------------------------------------------------------------===//

Attribute ModuleInfoAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                                Type type) {
  StringRef latencyKw, minIIKw, noshareDspKw;
  int64_t latency, minII, noshareDsp;
  if (p.parseLess() || p.parseKeyword(latencyKw) || p.parseEqual() ||
      p.parseInteger(latency) || p.parseComma() || p.parseKeyword(minIIKw) ||
      p.parseEqual() || p.parseInteger(minII) || p.parseComma() ||
      p.parseKeyword(noshareDspKw) || p.parseEqual() ||
      p.parseInteger(noshareDsp) || p.parseGreater())
    return Attribute();

  if (latencyKw != "latency" || minIIKw != "minII" ||
      noshareDspKw != "noshareDsp")
    return Attribute();

  return ModuleInfoAttr::get(ctxt, latency, minII, noshareDsp);
}

void ModuleInfoAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<latency=" << getLatency() << ", minII=" << getMinII()
    << ", noshareDsp=" << getNoshareDsp() << ">";
}

//===----------------------------------------------------------------------===//
// LoopInfoAttr
//===----------------------------------------------------------------------===//

Attribute LoopInfoAttr::parse(MLIRContext *ctxt, DialectAsmParser &p,
                              Type type) {
  StringRef tripCountKw, flattenTripCountKw, iterLatencyKw;
  int64_t tripCount, flattenTripCount, iterLatency;
  if (p.parseLess() || p.parseKeyword(tripCountKw) || p.parseEqual() ||
      p.parseInteger(tripCount) || p.parseComma() ||
      p.parseKeyword(flattenTripCountKw) || p.parseEqual() ||
      p.parseInteger(flattenTripCount) || p.parseComma() ||
      p.parseKeyword(iterLatencyKw) || p.parseEqual() ||
      p.parseInteger(iterLatency) || p.parseGreater())
    return Attribute();

  if (tripCountKw != "tripCount" || flattenTripCountKw != "flattenTripCount" ||
      iterLatencyKw != "iterLatency")
    return Attribute();

  return LoopInfoAttr::get(ctxt, tripCount, flattenTripCount, iterLatency);
}

void LoopInfoAttr::print(DialectAsmPrinter &p) const {
  p << getMnemonic() << "<tripCount=" << getTripCount()
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
