//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "Transforms/Passes.h.inc"
} // namespace

void scalehls::registerTransformsPasses() { registerPasses(); }
