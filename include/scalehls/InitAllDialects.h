//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_INITALLDIALECTS_H
#define SCALEHLS_INITALLDIALECTS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/Linalg/IR/LinalgOps.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/IR/Dialect.h"
#include "scalehls/Dialect/HLSCpp/HLSCpp.h"
#include "scalehls/Dialect/HLSKernel/HLSKernel.h"

namespace mlir {
namespace scalehls {

// Add all the ScaleHLS dialects to the provided registry.
inline void registerAllDialects(mlir::DialectRegistry &registry) {
  // clang-format off
  registry.insert<
    mlir::scalehls::hlscpp::HLSCppDialect,
    mlir::scalehls::hlskernel::HLSKernelDialect,
    mlir::StandardOpsDialect,
    mlir::AffineDialect,
    mlir::memref::MemRefDialect,
    mlir::math::MathDialect,
    mlir::arith::ArithmeticDialect,
    mlir::scf::SCFDialect,
    mlir::linalg::LinalgDialect,
    mlir::LLVM::LLVMDialect
  >();
  // clang-format on
}

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_INITALLDIALECTS_H
