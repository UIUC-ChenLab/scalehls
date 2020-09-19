//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/IR/StandardTypes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

void HLSCppDialect::initialize() {

  addOperations<
#define GET_OP_LIST
#include "Dialect/HLSCpp/HLSCpp.cpp.inc"
      >();
}

#include "Dialect/HLSCpp/HLSCppInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "Dialect/HLSCpp/HLSCpp.cpp.inc"
