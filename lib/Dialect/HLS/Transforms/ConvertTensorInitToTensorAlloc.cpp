//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_CONVERTTENSORINITTOTENSORALLOC
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
struct ConvertTensorInitToTensorAlloc
    : public hls::impl::ConvertTensorInitToTensorAllocBase<
          ConvertTensorInitToTensorAlloc> {
  void runOnOperation() override { auto module = getOperation(); }
};
} // namespace
