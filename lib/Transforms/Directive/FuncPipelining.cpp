//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// Apply function pipelining to the input function, all contained loops are
/// automatically fully unrolled.
static bool applyFuncPipelining(FuncOp func, int64_t targetII) {
  if (!applyFullyLoopUnrolling(func.front()))
    return false;

  auto topFunc = false;
  if (auto funcDirect = getFuncDirective(func))
    topFunc = funcDirect.getTopFunc();

  setFuncDirective(func, true, targetII, false, topFunc);

  return true;
}

namespace {
struct FuncPipelining : public FuncPipeliningBase<FuncPipelining> {
  void runOnOperation() override {
    auto func = getOperation();

    if (func.getName() == targetFunc)
      applyFuncPipelining(func, targetII);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createFuncPipeliningPass() {
  return std::make_unique<FuncPipelining>();
}
