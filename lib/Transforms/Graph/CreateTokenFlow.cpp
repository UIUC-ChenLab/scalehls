//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct CreateTokenFlow : public CreateTokenFlowBase<CreateTokenFlow> {
  void runOnOperation() override {}
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateTokenFlowPass() {
  return std::make_unique<CreateTokenFlow>();
}
