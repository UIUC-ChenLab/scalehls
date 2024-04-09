//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSLATION_EMITHLSCPP_H
#define SCALEHLS_TRANSLATION_EMITHLSCPP_H

#include "mlir/IR/BuiltinOps.h"

namespace mlir {
namespace scalehls {

// Emit HLS C++ code for the given module.
LogicalResult emitHLSCpp(ModuleOp module, llvm::raw_ostream &os,
                         int64_t axiMaxWidenBitwidth = 512);

void registerEmitHLSCppTranslation();

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSLATION_EMITHLSCPP_H
