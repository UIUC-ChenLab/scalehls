//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/HLSCpp.h"
#include "mlir/CAPI/Registration.h"
#include "scalehls/Dialect/HLSCpp/HLSCpp.h"

using namespace mlir;
using namespace scalehls;

MLIR_DEFINE_CAPI_DIALECT_REGISTRATION(HLSCpp, hlscpp, hlscpp::HLSCppDialect)
