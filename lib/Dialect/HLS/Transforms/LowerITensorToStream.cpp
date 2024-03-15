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
struct LowerITensorToStream
    : public LowerITensorToStreamBase<LowerITensorToStream> {
  void runOnOperation() override {
    auto op = getOperation();

    // Fold all stream view ops.
    op.walk([&](hls::ITensorViewLikeInterface streamView) {
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

std::unique_ptr<Pass> scalehls::hls::createLowerITensorToStreamPass() {
  return std::make_unique<LowerITensorToStream>();
}