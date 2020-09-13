//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Dialect/HLSCpp/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct PragmaInsertion : public PragmaInsertionBase<PragmaInsertion> {
  void runOnOperation() override;
};
} // namespace

void PragmaInsertion::runOnOperation() { return; }

std::unique_ptr<mlir::Pass>
mlir::scalehls::hlscpp::createPragmaInsertionPass() {
  return std::make_unique<PragmaInsertion>();
}
