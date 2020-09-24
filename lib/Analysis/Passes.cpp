//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "Analysis/Passes.h.inc"
} // namespace

void scalehls::registerAnalysisPasses() { registerPasses(); }
