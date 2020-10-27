//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/Benchmark/Benchmark.h"
#include "mlir/IR/StandardTypes.h"

using namespace mlir;
using namespace scalehls;
using namespace benchmark;

void BenchmarkDialect::initialize() {

  addOperations<
#define GET_OP_LIST
#include "Dialect/Benchmark/Benchmark.cpp.inc"
      >();
}

#define GET_OP_CLASSES
#include "Dialect/Benchmark/Benchmark.cpp.inc"
