//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Dialect/HLS/Passes.h"
#include "mlir/CAPI/Pass.h"
#include "mlir/Pass/Pass.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
#define GEN_PASS_REGISTRATION
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace

#ifdef __cplusplus
extern "C" {
#endif

#include "scalehls/Dialect/HLS/Transforms/Passes.capi.cpp.inc"

#ifdef __cplusplus
}
#endif
