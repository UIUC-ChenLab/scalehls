//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Dialect/HLSCpp.h"
#include "mlir/CAPI/IR.h"
#include "mlir/CAPI/Registration.h"
#include "mlir/CAPI/Support.h"
#include "scalehls/Dialect/HLSCpp/HLSCpp.h"

MLIR_DEFINE_CAPI_DIALECT_REGISTRATION(HLSCpp, hlscpp,
                                      mlir::scalehls::hlscpp::HLSCppDialect)
