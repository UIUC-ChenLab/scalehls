//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLSCpp/HLSCpp.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

void HLSCppDialect::initialize() {

  addOperations<
#define GET_OP_LIST
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
      >();
}

#include "scalehls/Dialect/HLSCpp/HLSCppEnums.cpp.inc"
#include "scalehls/Dialect/HLSCpp/HLSCppInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCpp.cpp.inc"
