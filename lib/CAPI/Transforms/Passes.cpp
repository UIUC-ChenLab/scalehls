//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "mlir/CAPI/Pass.h"
#include "mlir/Pass/Pass.h"
#include "scalehls-c/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

#ifdef __cplusplus
extern "C" {
#endif

#include "scalehls/Transforms/Passes.capi.cpp.inc"

#ifdef __cplusplus
}
#endif