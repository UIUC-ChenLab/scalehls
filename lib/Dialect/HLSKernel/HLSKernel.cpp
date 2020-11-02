//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSKernel/HLSKernel.h"
#include "mlir/IR/StandardTypes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlskernel;

void HLSKernelDialect::initialize() {

  addOperations<
#define GET_OP_LIST
#include "Dialect/HLSKernel/HLSKernel.cpp.inc"
      >();
}

#include "Dialect/HLSCpp/HLSCppInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "Dialect/HLSKernel/HLSKernel.cpp.inc"
