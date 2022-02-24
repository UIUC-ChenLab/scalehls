//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct CreateRuntimeMain : public CreateRuntimeMainBase<CreateRuntimeMain> {
  CreateRuntimeMain() = default;
  CreateRuntimeMain(const ScaleHLSPyTorchPipelineOptions &opts) {
    topFunc = opts.hlscppTopFunc;
  }

  void runOnOperation() override {}
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateRuntimeMainPass() {
  return std::make_unique<CreateRuntimeMain>();
}
std::unique_ptr<Pass> scalehls::createCreateRuntimeMainPass(
    const ScaleHLSPyTorchPipelineOptions &opts) {
  return std::make_unique<CreateRuntimeMain>(opts);
}
