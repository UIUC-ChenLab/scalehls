//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls-c/Transforms/Pipelines.h"
#include "scalehls/Transforms/Pipelines.h"

using namespace mlir;
using namespace scalehls;

void mlirRegisterScaleHLSPipelines(void) { registerScaleHLSPipelines(); }
