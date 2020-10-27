//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/BenchmarkToAffine.h"
#include "Dialect/Benchmark/Benchmark.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;
using namespace scalehls;
using namespace benchmark;

namespace {
class BenchmarkToAffinePass
    : public mlir::PassWrapper<BenchmarkToAffinePass, OperationPass<ModuleOp>> {
public:
  void runOnOperation() override;
};
} // namespace

void BenchmarkToAffinePass::runOnOperation() {}

void benchmark::registerBenchmarkToAffinePass() {
  PassRegistration<BenchmarkToAffinePass>(
      "benchmark-to-affine",
      "Lower benchmark operations to corresponding affine representation.");
}
