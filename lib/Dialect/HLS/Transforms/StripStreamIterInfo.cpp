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
struct StripStreamIterInfo
    : public StripStreamIterInfoBase<StripStreamIterInfo> {
  void runOnOperation() override {
    auto op = getOperation();

    // Fold all stream view ops.
    op.walk([&](hls::StreamViewLikeInterface streamView) {
      streamView.getResult().replaceAllUsesWith(streamView.getSource());
      streamView.erase();
    });

    // Strip iteration information of all streams.
    op.walk([&](StreamOp stream) {
      stream.getResult().setType(hls::StreamType::get(
          stream.getType().getElementType(), stream.getType().getDepth()));
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createStripStreamIterInfoPass() {
  return std::make_unique<StripStreamIterInfo>();
}