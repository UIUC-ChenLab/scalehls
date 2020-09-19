//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
#define GEN_PASS_REGISTRATION
#include "Dialect/HLSCpp/HLSCppPasses.h.inc"
} // namespace

void hlscpp::registerHLSCppPasses() { registerPasses(); }
