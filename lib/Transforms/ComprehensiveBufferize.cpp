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
#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"

#define DEBUG_TYPE "scalehls-comprehensive-bufferize"

using namespace mlir;
using namespace scalehls;

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
  return b.create<linalg::GenericOp>(
      loc, /*inputs=*/from, /*outputs=*/to,
      /*indexingMaps=*/llvm::ArrayRef({id, id}),
      /*iteratorTypes=*/iteratorTypes,
      [](OpBuilder &b, Location loc, ValueRange args) {
        b.create<linalg::YieldOp>(loc, args.front());
      },
      attributes);
}

// Default allocation functions.
static FailureOr<Value> defaultAllocationFn(OpBuilder &builder, Location loc,
                                            MemRefType allocationType,
                                            ValueRange dynamicSizes,
                                            unsigned int alignment) {
  MemRefType type = allocationType;
  return builder.create<memref::AllocOp>(loc, type, dynamicSizes).getResult();
}
static LogicalResult defaultDeallocationFn(OpBuilder &builder, Location loc,
                                           Value allocation) {
  builder.create<memref::DeallocOp>(loc, allocation);
  return success();
}
static LogicalResult defaultMemCpyFn(OpBuilder &builder, Location loc,
                                     Value from, Value to) {
  Operation *copyOp = createLinalgCopyOp(builder, loc, from, to);
  return success(static_cast<bool>(copyOp));
}

static OneShotBufferizationOptions getBufferizationOptions() {
  OneShotBufferizationOptions options;

  // bufferization.to_memref is used to bufferize constants in IREE. IREE has
  // it's own logic to handle constants. We'd like to leave the arith.constant
  // as is and insert bufferization.to_memref to convert the tensor to memref.
  options.opFilter.denyOperation<arith::ConstantOp>();
  options.opFilter.denyOperation<bufferization::ToMemrefOp>();

  // This type converter converts tensor types to memref types when no exact
  // memref type can be inferred from the context.
  options.unknownTypeConverterFn = [](Value value, Attribute memorySpace,
                                      const BufferizationOptions &options) {
    auto tensorType = value.getType().cast<TensorType>();

    // Special rule for ConstantOps: These always lower to some memref with a
    // static identity layout.
    if (value.getDefiningOp<arith::ConstantOp>())
      return bufferization::getMemRefTypeWithStaticIdentityLayout(tensorType,
                                                                  memorySpace);

    // Default case: Fully dynamic layout map for best compatibility.
    return bufferization::getMemRefTypeWithFullyDynamicLayout(tensorType,
                                                              memorySpace);
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
    : public ComprehensiveBufferizeBase<ComprehensiveBufferize> {
  explicit ComprehensiveBufferize(
      std::optional<BufferizationOptions::AllocationFn> allocationFn =
          std::nullopt,
      std::optional<BufferizationOptions::DeallocationFn> deallocationFn =
          std::nullopt,
      std::optional<BufferizationOptions::MemCpyFn> memCpyFn = std::nullopt)
      : allocationFn(allocationFn), deallocationFn(deallocationFn),
        memCpyFn(memCpyFn) {}

  void runOnOperation() override {
    ModuleOp moduleOp = getOperation();
    OneShotBufferizationOptions options = getBufferizationOptions();
    options.allocationFn = allocationFn;
    options.deallocationFn = deallocationFn;
    options.memCpyFn = memCpyFn;

    if (failed(runScaleHLSOneShotBufferize(moduleOp, options)))
      return signalPassFailure();

    // Remove redundant args and unused results.
    RewritePatternSet patterns(&getContext());
    linalg::populateEraseUnusedOperandsAndResultsPatterns(patterns);
    if (failed(applyPatternsAndFoldGreedily(moduleOp, std::move(patterns)))) {
      return signalPassFailure();
    }
  }

private:
  const std::optional<BufferizationOptions::AllocationFn> allocationFn;
  const std::optional<BufferizationOptions::DeallocationFn> deallocationFn;
  const std::optional<BufferizationOptions::MemCpyFn> memCpyFn;
};
} // namespace

std::unique_ptr<Pass> scalehls::createComprehensiveBufferizePass(
    std::optional<BufferizationOptions::AllocationFn> allocationFn,
    std::optional<BufferizationOptions::DeallocationFn> deallocationFn,
    std::optional<BufferizationOptions::MemCpyFn> memCpyFn) {
  if (!allocationFn)
    allocationFn = defaultAllocationFn;
  if (!deallocationFn)
    deallocationFn = defaultDeallocationFn;
  if (!memCpyFn)
    memCpyFn = defaultMemCpyFn;
  return std::make_unique<ComprehensiveBufferize>(allocationFn, deallocationFn,
                                                  memCpyFn);
}
