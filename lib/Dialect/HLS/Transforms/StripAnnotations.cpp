//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_STRIPANNOTATIONS
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
struct StripAnnotations
    : public hls::impl::StripAnnotationsBase<StripAnnotations> {
  using Base::Base;

  void runOnOperation() override {
    getOperation().walk(
        [&](Operation *op) { op->removeAttr(annotationName.getValue()); });
  }
};
} // namespace
