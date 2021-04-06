//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLSCpp/HLSCpp.h"
#include "mlir/IR/PatternMatch.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

void HLSCppDialect::initialize() {

  addOperations<
#define GET_OP_LIST
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
      >();
}

// #include "scalehls/Dialect/HLSCpp/HLSCppEnums.cpp.inc"
#include "scalehls/Dialect/HLSCpp/HLSCppInterfaces.cpp.inc"

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

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
