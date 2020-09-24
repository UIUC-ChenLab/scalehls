//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_PASSES_H
#define SCALEHLS_ANALYSIS_PASSES_H

#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
class Pass;
} // namespace mlir

namespace mlir {
namespace scalehls {

std::unique_ptr<mlir::Pass> createQoREstimationPass();

void registerAnalysisPasses();

#define GEN_PASS_CLASSES
#include "Analysis/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_PASSES_H
