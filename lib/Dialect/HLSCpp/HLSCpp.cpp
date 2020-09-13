//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/IR/StandardTypes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

HLSCppDialect::HLSCppDialect(mlir::MLIRContext *context)
    : Dialect(getDialectNamespace(), context) {

  addOperations<
#define GET_OP_LIST
#include "Dialect/HLSCpp/HLSCpp.cpp.inc"
      >();
}

// Op classes definations.

#include "Dialect/HLSCpp/HLSCppInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "Dialect/HLSCpp/HLSCpp.cpp.inc"
