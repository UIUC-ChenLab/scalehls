//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_CONVERSION_PASSES_H
#define SCALEHLS_CONVERSION_PASSES_H

#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
class Pass;
} // namespace mlir

namespace mlir {
namespace scalehls {

// HLSKernel and HLSCpp conversion passes.
std::unique_ptr<Pass> createLegalizeToHLSCppPass();
std::unique_ptr<Pass> createHLSKernelToAffinePass();

/// Onnx kernel legalization pass.
std::unique_ptr<Pass> createLegalizeOnnxPass();

void registerConversionPasses();

#define GEN_PASS_CLASSES
#include "Conversion/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_CONVERSION_PASSES_H
