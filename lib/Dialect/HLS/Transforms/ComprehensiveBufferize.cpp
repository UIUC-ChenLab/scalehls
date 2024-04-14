//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//
//
// Ported from IREE:
// https://github.com/openxla/iree/blob/main/compiler/src/iree/compiler/Codegen/Common/IREEComprehensiveBufferizePass.cpp
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/Transforms/OneShotAnalysis.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

#define DEBUG_TYPE "scalehls-comprehensive-bufferize"

using namespace mlir;
using namespace scalehls;
using namespace hls;
using namespace bufferization;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_COMPREHENSIVEBUFFERIZE
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

/// Create a linalg::GenericOp version of an n-D copy that can further tile,
/// lower to loops or vectorize, unlike the current implementation of
/// memref::CopyOp.
static Operation *createLinalgCopyOp(OpBuilder &b, Location loc, Value from,
                                     Value to,
                                     ArrayRef<NamedAttribute> attributes = {}) {
  auto memrefTypeFrom = from.getType().dyn_cast<MemRefType>();
  auto memrefTypeTo = to.getType().dyn_cast<MemRefType>();
  if (!memrefTypeFrom || !memrefTypeTo ||
      memrefTypeFrom.getRank() != memrefTypeTo.getRank()) {
    mlir::emitError(
        loc, "unable to generate copy op within bufferization from type ")
        << memrefTypeFrom << " to " << memrefTypeTo;
    return nullptr;
  }
  AffineMap id =
      AffineMap::getMultiDimIdentityMap(memrefTypeTo.getRank(), b.getContext());
  SmallVector<utils::IteratorType> iteratorTypes(memrefTypeTo.getRank(),
                                                 utils::IteratorType::parallel);

  SmallVector<NamedAttribute> linalgAttributes(attributes);
  linalgAttributes.emplace_back(b.getStringAttr(kCopyAttrName),
                                b.getUnitAttr());

  return b.create<linalg::GenericOp>(
      loc, from, to, llvm::ArrayRef({id, id}), iteratorTypes,
      [](OpBuilder &b, Location loc, ValueRange args) {
        b.create<linalg::YieldOp>(loc, args.front());
      },
      linalgAttributes);
}

// Default allocation functions.
static FailureOr<Value> defaultAllocationFn(OpBuilder &builder, Location loc,
                                            MemRefType allocationType,
                                            ValueRange dynamicSizes,
                                            unsigned int alignment) {
  MemRefType type = allocationType;
  return builder.create<hls::BufferOp>(loc, type).getResult();
}

static LogicalResult defaultMemCpyFn(OpBuilder &builder, Location loc,
                                     Value from, Value to) {
  Operation *copyOp = createLinalgCopyOp(builder, loc, from, to);
  return success(static_cast<bool>(copyOp));
}

static OneShotBufferizationOptions getBufferizationOptions() {
  OneShotBufferizationOptions options;
  options.setFunctionBoundaryTypeConversion(LayoutMapOption::IdentityLayoutMap);
  options.bufferizeFunctionBoundaries = true;
  // options.opFilter.denyOperation<arith::ConstantOp>();

  // This type converter converts tensor types to memref types when no exact
  // memref type can be inferred from the context.
  options.unknownTypeConverterFn = [](Value value, Attribute memorySpace,
                                      const BufferizationOptions &options) {
    // We always lower to memref with a static identity layout.
    return bufferization::getMemRefTypeWithStaticIdentityLayout(
        value.getType().cast<TensorType>(), memorySpace);
  };

  return options;
}

// The following is copied from bufferization::runOneShotBufferize with
// modifications.
LogicalResult
runScaleHLSOneShotBufferize(Operation *op,
                            const OneShotBufferizationOptions &options) {
  OneShotAnalysisState state(op, options);
  if (failed(analyzeOp(op, state)))
    return failure();
  if (options.testAnalysisOnly)
    return success();
  return bufferization::runOneShotBufferize(op, options);
}

namespace {
struct ComprehensiveBufferize
    : public hls::impl::ComprehensiveBufferizeBase<ComprehensiveBufferize> {
  void runOnOperation() override {
    ModuleOp moduleOp = getOperation();

    OneShotBufferizationOptions bufferizeOptions = getBufferizationOptions();
    bufferizeOptions.allocationFn = defaultAllocationFn;
    bufferizeOptions.memCpyFn = defaultMemCpyFn;
    if (failed(runScaleHLSOneShotBufferize(moduleOp, bufferizeOptions)))
      return signalPassFailure();

    bufferization::BufferResultsToOutParamsOpts resultsToOutParamsOptions;
    resultsToOutParamsOptions.memCpyFn = defaultMemCpyFn;
    if (failed(bufferization::promoteBufferResultsToOutParams(
            moduleOp, resultsToOutParamsOptions)))
      return signalPassFailure();

    // Remove redundant args and unused results.
    RewritePatternSet patterns(&getContext());
    linalg::populateEraseUnusedOperandsAndResultsPatterns(patterns);
    (void)applyPatternsAndFoldGreedily(moduleOp, std::move(patterns));
  }
};
} // namespace
