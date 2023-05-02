//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Conversions/Passes.h"
#include "mlir/CAPI/Pass.h"
#include "mlir/Pass/Pass.h"
#include "scalehls-c/Conversions.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "scalehls/Conversions/Passes.h.inc"
} // namespace

#ifdef __cplusplus
extern "C" {
#endif

#include "scalehls/Conversions/Passes.capi.cpp.inc"

#ifdef __cplusplus
}
#endif
