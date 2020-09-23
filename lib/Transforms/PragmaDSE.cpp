//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Transforms/INIReader.h"
#include "Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct PragmaDSE : public PragmaDSEBase<PragmaDSE> {
  void runOnOperation() {}
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createPragmaDSEPass() {
  return std::make_unique<PragmaDSE>();
}
