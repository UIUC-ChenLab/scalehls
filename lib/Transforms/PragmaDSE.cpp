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
struct PragmaDSE : public PragmaDSEBase<PragmaDSE> {
  void runOnOperation() override {}
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createPragmaDSEPass() {
  return std::make_unique<PragmaDSE>();
}
