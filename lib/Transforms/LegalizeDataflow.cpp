//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"
#include "mlir/IR/Builders.h"

using namespace std;
using namespace mlir;
using namespace scalehls;

namespace {
struct LegalizeDataflow : public LegalizeDataflowBase<LegalizeDataflow> {
  void runOnOperation() override;
};
} // namespace

void LegalizeDataflow::runOnOperation() { return; }

std::unique_ptr<mlir::Pass> scalehls::createLegalizeDataflowPass() {
  return std::make_unique<LegalizeDataflow>();
}
