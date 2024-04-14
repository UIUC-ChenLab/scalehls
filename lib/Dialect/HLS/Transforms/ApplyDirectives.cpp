//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/LoopUtils.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_APPLYDIRECTIVES
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

static SmallVector<affine::AffineForOp>
getLoopBandFromInnermostLoop(affine::AffineForOp loop) {
  SmallVector<affine::AffineForOp> band({loop});
  auto currentLoop = loop;
  while (auto parentLoop =
             currentLoop->getParentOfType<affine::AffineForOp>()) {
    if (llvm::hasSingleElement(parentLoop.getOps<affine::AffineForOp>()))
      currentLoop = parentLoop;
    else
      break;
    band.push_back(parentLoop);
  }
  return {band.rbegin(), band.rend()};
}

namespace {
struct ApplyDirectives
    : public hls::impl::ApplyDirectivesBase<ApplyDirectives> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    SmallVector<affine::AffineForOp> loopsToPipeline;
    SmallVector<affine::AffineForOp> loopsToDataflow;
    func.walk([&](affine::AffineForOp loop) {
      if (loop->hasAttr(kPipelineAttrName))
        loopsToPipeline.push_back(loop);
      else if (loop->hasAttr(kDataflowAttrName))
        loopsToDataflow.push_back(loop);
    });

    // Unroll all subloops of the loops to be pipelined.
    for (auto loop : loopsToPipeline)
      loop.walk([&](affine::AffineForOp subLoop) {
        if (loop != subLoop)
          (void)affine::loopUnrollFull(subLoop);
      });

    // Coalesce all perfectly nested loops to be dataflowed.
    for (auto loop : loopsToDataflow) {
      auto band = getLoopBandFromInnermostLoop(loop);
      if (affine::isPerfectlyNested(band) &&
          succeeded(affine::coalesceLoops(band)))
        band.front()->setAttr(kDataflowAttrName, builder.getUnitAttr());
    }

    // Apply partition layout to all buffers.
    func.walk([](hls::BufferOp buffer) {
      if (auto layoutAttr =
              buffer->getAttrOfType<PartitionLayoutAttr>(kPartitionAttrName)) {
        buffer.getResult().setType(
            MemRefType::get(buffer.getType().getShape(),
                            buffer.getType().getElementType(), layoutAttr));
        buffer->removeAttr(kPartitionAttrName);
      }
    });
  }
};
} // namespace
