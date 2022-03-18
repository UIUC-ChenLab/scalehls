//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Utils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct RaiseImplicitCopy : public RaiseImplicitCopyBase<RaiseImplicitCopy> {
  void runOnOperation() override {}
};
} // namespace

std::unique_ptr<Pass> scalehls::createRaiseImplicitCopyPass() {
  return std::make_unique<RaiseImplicitCopy>();
}
