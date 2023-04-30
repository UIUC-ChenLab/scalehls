//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
#define GEN_PASS_REGISTRATION
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace

void hls::registerHLSPasses() { registerPasses(); }
