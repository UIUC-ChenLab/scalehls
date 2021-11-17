//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSLATION_EMITHLSCPP_H
#define SCALEHLS_TRANSLATION_EMITHLSCPP_H

#include "scalehls/Translation/EmitHLSCpp.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/IR/AffineExprVisitor.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Translation.h"
#include "scalehls/Dialect/HLSCpp/Visitor.h"
#include "scalehls/Dialect/HLSKernel/Visitor.h"
#include "scalehls/InitAllDialects.h"
#include "scalehls/Support/Utils.h"
#include "llvm/Support/raw_ostream.h"

#include "mlir/IR/BuiltinOps.h"


namespace mlir {
namespace scalehls {

LogicalResult emitHLSCpp(ModuleOp module, llvm::raw_ostream &os);
void registerEmitHLSCppTranslation();

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSLATION_EMITHLSCPP_H
