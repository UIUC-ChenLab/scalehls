//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "Conversion/Passes.h.inc"
} // namespace

void scalehls::registerConversionPasses() { registerPasses(); }
