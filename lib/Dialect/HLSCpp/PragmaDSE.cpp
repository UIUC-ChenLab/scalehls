//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Dialect/HLSCpp/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct PragmaDSE : public PragmaDSEBase<PragmaDSE> {
  void runOnOperation() {}
};
} // namespace

std::unique_ptr<mlir::Pass> hlscpp::createPragmaDSEPass() {
  return std::make_unique<PragmaDSE>();
}
