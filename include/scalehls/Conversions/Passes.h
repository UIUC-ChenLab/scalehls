//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_CONVERSIONS_PASSES_H
#define SCALEHLS_CONVERSIONS_PASSES_H

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

void registerConversionsPasses();

std::unique_ptr<Pass> createConvertLinalgToFDF();
std::unique_ptr<Pass> createConvertFDFToSDF();
std::unique_ptr<Pass> createConvertSDFToFunc();

#define GEN_PASS_CLASSES
#include "scalehls/Conversions/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_CONVERSIONS_PASSES_H
