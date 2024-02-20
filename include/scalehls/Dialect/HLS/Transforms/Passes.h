//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_H
#define SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_H

#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/Pass/Pass.h"
#include "scalehls/InitAllDialects.h"
#include <memory>

namespace mlir {
class Pass;
namespace func {
class FuncOp;
} // namespace func
} // namespace mlir

namespace mlir {
namespace scalehls {
namespace hls {

std::unique_ptr<Pass> createPreprocessPass();
std::unique_ptr<Pass> createReduceTensorToStreamPass();
std::unique_ptr<Pass> createMaterializeStreamPass(bool enablePacking = true);
std::unique_ptr<Pass> createScalarizeStreamPass();

std::unique_ptr<Pass> createCreateDataflowPass();
std::unique_ptr<Pass> createLowerDataflowPass();
std::unique_ptr<Pass> createConvertDataflowToFuncPass();

std::unique_ptr<Pass> createApplyTransformPatternPass();
std::unique_ptr<Pass> createRaiseSCFToAffinePass();

std::unique_ptr<Pass> createComprehensiveBufferizePass(
    std::optional<bufferization::BufferizationOptions::AllocationFn>
        allocationFn = std::nullopt,
    std::optional<bufferization::BufferizationOptions::MemCpyFn> memCpyFn =
        std::nullopt);
std::unique_ptr<Pass>
createGenerateRuntimeFuncPass(std::string topFunc = "forward",
                              std::string runtimeFunc = "runtime");
std::unique_ptr<Pass> createLowerCopyToAffineLoopsPass();

#define GEN_PASS_CLASSES
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"

#define GEN_PASS_REGISTRATION
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"

} // namespace hls
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_PASSES_H
