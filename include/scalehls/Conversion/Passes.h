//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
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

// SCF2Affine Raising passes
std::unique_ptr<Pass> createRaiseLoadStorePass();
std::unique_ptr<Pass> createRaiseSCFForPass();
void LoadStoreRaisingPatterns(RewritePatternSet &patterns);
void SCFForRaisingPatterns(RewritePatternSet &patterns);

// HLSKernel and HLSCpp conversion passes.
std::unique_ptr<Pass> createLegalizeToHLSCppPass();
std::unique_ptr<Pass> createHLSKernelToAffinePass();

/// Onnx kernel legalization pass.
std::unique_ptr<Pass> createLegalizeOnnxPass();

void registerConversionPasses();

#define GEN_PASS_CLASSES
#include "scalehls/Conversion/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_CONVERSION_PASSES_H
