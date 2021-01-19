//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Analysis/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
#define GEN_PASS_REGISTRATION
#include "scalehls/Analysis/Passes.h.inc"
} // namespace

void scalehls::registerAnalysisPasses() { registerPasses(); }
