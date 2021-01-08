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

void MultipleLevelDSE::runOnOperation() {
  // Read configuration file.
  INIReader spec(targetSpec);
  if (spec.ParseError())
    emitError(getOperation().getLoc(), "error: target spec file parse fail, "
                                       "please pass in correct file path\n");

  // Collect profiling latency data.
  LatencyMap latencyMap;
  getLatencyMap(spec, latencyMap);
}

std::unique_ptr<mlir::Pass> scalehls::createMultipleLevelDSEPass() {
  return std::make_unique<MultipleLevelDSE>();
}
