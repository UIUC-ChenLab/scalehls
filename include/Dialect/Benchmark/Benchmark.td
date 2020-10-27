//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_BENCHMARK_BENCHMARK_TD
#define SCALEHLS_DIALECT_BENCHMARK_BENCHMARK_TD

include "mlir/IR/OpBase.td"

def BenchmarkDialect : Dialect {
  let name = "benchmark";
  let summary = "A Benchmark out-of-tree MLIR dialect";
  let description = [{
    This dialect contains a set of frequently used high-level operations (e.g.
    convolution, relu, pooling, etc.) which can be lowered to Standard/Affine
    dialect for benchmarking the estimation and optimization of HLS techiques.
  }];
  let cppNamespace = "::mlir::scalehls::benchmark";
}

class BenchmarkOp<string mnemonic, list<OpTrait> traits = []> :
    Op<BenchmarkDialect, mnemonic, traits>;

include "Ops.td"

#endif // SCALEHLS_DIALECT_BENCHMARK_BENCHMARK_TD
