//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Dialect/HLSCpp/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct StaticAnalysis : public StaticAnalysisBase<StaticAnalysis> {
  void runOnOperation() {}
};
} // namespace

std::unique_ptr<mlir::Pass> hlscpp::createStaticAnalysisPass() {
  return std::make_unique<StaticAnalysis>();
}
