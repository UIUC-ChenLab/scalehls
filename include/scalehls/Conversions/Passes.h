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

void registerScaleHLSConversionsPasses();

std::unique_ptr<Pass> createConvertLinalgToFDFPass();
std::unique_ptr<Pass> createConvertFDFToSDFPass();
std::unique_ptr<Pass> createConvertSDFToFuncPass();

#define GEN_PASS_CLASSES
#include "scalehls/Conversions/Passes.h.inc"

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_CONVERSIONS_PASSES_H
