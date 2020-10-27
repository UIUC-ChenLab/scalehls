//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_BENCHMARK_OPS_TD
#define SCALEHLS_DIALECT_BENCHMARK_OPS_TD

def ConvOp : BenchmarkOp<"conv", []> {
  let summary = "convolution operation";
  let description = [{ Convolution operation. }];
}

#endif // SCALEHLS_DIALECT_BENCHMARK_OPS_TD
