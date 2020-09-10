//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/Dialect.h"
#include "Dialect/HLSCpp/Ops.h"

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
