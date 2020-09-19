//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Dialect/HLSCpp/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct QoREstimation : public QoREstimationBase<QoREstimation> {
  void runOnOperation() {}
};
} // namespace

std::unique_ptr<mlir::Pass> hlscpp::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
