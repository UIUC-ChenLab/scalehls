//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Conversion/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "scalehls/Conversion/Passes.h.inc"
} // namespace

void scalehls::registerConversionPasses() { registerPasses(); }
