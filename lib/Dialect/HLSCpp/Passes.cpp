//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

void mlir::scalehls::hlscpp::registerHLSCppPasses() {
#define GEN_PASS_REGISTRATION
#include "Dialect/HLSCpp/HLSCppPasses.h.inc"
}
