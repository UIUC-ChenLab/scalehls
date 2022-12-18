//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_INITALLDIALECTS_H
#define SCALEHLS_INITALLDIALECTS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MLProgram/IR/MLProgram.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "scalehls/Dialect/HLS/HLS.h"

namespace mlir {
namespace scalehls {

// Add all the ScaleHLS dialects to the provided registry.
inline void registerAllDialects(mlir::DialectRegistry &registry) {
  // clang-format off
  registry.insert<
    mlir::func::FuncDialect,
    mlir::tosa::TosaDialect,
    mlir::tensor::TensorDialect,
    mlir::linalg::LinalgDialect,
    mlir::memref::MemRefDialect,
    mlir::bufferization::BufferizationDialect,
    mlir::AffineDialect,
    mlir::math::MathDialect,
    mlir::arith::ArithDialect,
    mlir::vector::VectorDialect,
    mlir::scf::SCFDialect,
    mlir::scalehls::hls::HLSDialect,
    mlir::LLVM::LLVMDialect,
    mlir::DLTIDialect,
    mlir::ml_program::MLProgramDialect
  >();
  // clang-format on
}

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_INITALLDIALECTS_H
