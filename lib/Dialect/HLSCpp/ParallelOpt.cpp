//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Dialect/HLSCpp/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct ParallelOpt : public ParallelOptBase<ParallelOpt> {
  void runOnOperation() {}
};
} // namespace

std::unique_ptr<mlir::Pass> hlscpp::createParallelOptPass() {
  return std::make_unique<ParallelOpt>();
}
