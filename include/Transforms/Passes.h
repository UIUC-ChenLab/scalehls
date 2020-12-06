//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_H
#define SCALEHLS_TRANSFORMS_PASSES_H

#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
class Pass;
} // namespace mlir

namespace mlir {
namespace scalehls {

std::unique_ptr<mlir::Pass> createPragmaDSEPass();
std::unique_ptr<mlir::Pass> createAffineLoopPerfectionPass();
std::unique_ptr<mlir::Pass> createPartialAffineLoopTilePass();
std::unique_ptr<mlir::Pass> createRemoveVarLoopBoundPass();

void registerTransformsPasses();

#define GEN_PASS_CLASSES
#include "Transforms/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_PASSES_H
