//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_BENCHMARK_BENCHMARK_H
#define SCALEHLS_DIALECT_BENCHMARK_BENCHMARK_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Function.h"

#include "Dialect/Benchmark/BenchmarkDialect.h.inc"

#define GET_OP_CLASSES
#include "Dialect/Benchmark/Benchmark.h.inc"

#endif // SCALEHLS_DIALECT_BENCHMARK_BENCHMARK_H
