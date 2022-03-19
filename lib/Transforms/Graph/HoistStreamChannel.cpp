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
struct HoistStreamChannel : public HoistStreamChannelBase<HoistStreamChannel> {
  void runOnOperation() override {}
};
} // namespace

std::unique_ptr<Pass> scalehls::createHoistStreamChannelPass() {
  return std::make_unique<HoistStreamChannel>();
}
