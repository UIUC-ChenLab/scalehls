//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_H
#define SCALEHLS_TRANSFORMS_PASSES_H

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

//===----------------------------------------------------------------------===//
// Conversion Passes
//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createConvertLinalgToFDFPass();
std::unique_ptr<Pass> createConvertFDFToSDFPass();
std::unique_ptr<Pass> createConvertSDFToFuncPass();

//===----------------------------------------------------------------------===//
// Transform Passes
//===----------------------------------------------------------------------===//

using namespace bufferization;

std::unique_ptr<Pass> createComprehensiveBufferizePass(
    std::optional<BufferizationOptions::AllocationFn> allocationFn =
        std::nullopt,
    std::optional<BufferizationOptions::MemCpyFn> memCpyFn = std::nullopt);
std::unique_ptr<Pass>
createGenerateRuntimeFuncPass(std::string topFunc = "forward",
                              std::string runtimeFunc = "runtime");

#define GEN_PASS_CLASSES
#include "scalehls/Transforms/Passes.h.inc"

#define GEN_PASS_REGISTRATION
#include "scalehls/Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
