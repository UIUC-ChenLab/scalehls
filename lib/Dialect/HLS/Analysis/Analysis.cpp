//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Analysis/Analysis.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "dataflow-analysis"

using namespace mlir;
using namespace scalehls;
using namespace hls;