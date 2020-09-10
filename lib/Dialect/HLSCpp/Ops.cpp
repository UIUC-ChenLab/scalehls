//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/Ops.h"
#include "mlir/IR/OpImplementation.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

#define GET_OP_CLASSES
#include "Dialect/HLSCpp/HLSCpp.cpp.inc"
