//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "Transforms/Passes.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct MultipleLevelDSE : public MultipleLevelDSEBase<MultipleLevelDSE> {
  void runOnOperation() override;
};
} // namespace

/// This is a temporary approach.
static void applyMultipleLevelDSE(FuncOp func, OpBuilder &builder,
                                  LatencyMap &latencyMap, int64_t numDSP) {
  HLSCppEstimator estimator(func, latencyMap);
  estimator.estimateFunc();

  builder.setInsertionPoint(func);
  (void)numDSP;
}

void MultipleLevelDSE::runOnOperation() {
  auto module = getOperation();
  auto builder = OpBuilder(module);

  // Read configuration file.
  INIReader spec(targetSpec);
  if (spec.ParseError())
    module->emitError(
        "target spec file parse fail, please pass in correct file path\n");

  // Collect profiling data, where default values are based on PYNQ-Z1 board.
  LatencyMap latencyMap;
  getLatencyMap(spec, latencyMap);
  auto numDSP = spec.GetInteger("specification", "dsp", 220);

  for (auto func : module.getOps<FuncOp>())
    if (auto topFunction = func->getAttrOfType<BoolAttr>("top_function"))
      if (topFunction.getValue())
        applyMultipleLevelDSE(func, builder, latencyMap, numDSP);
}

std::unique_ptr<mlir::Pass> scalehls::createMultipleLevelDSEPass() {
  return std::make_unique<MultipleLevelDSE>();
}
