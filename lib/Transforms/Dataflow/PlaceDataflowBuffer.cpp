//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct PlaceBuffer : public OpRewritePattern<func::FuncOp> {
  PlaceBuffer(MLIRContext *context, unsigned threshold,
              bool placeExternalBuffer)
      : OpRewritePattern<func::FuncOp>(context), threshold(threshold),
        placeExternalBuffer(placeExternalBuffer) {}

  // TODO: For now, we use a heuristic to determine the buffer location.
  MemRefType getPlacedType(MemRefType type, bool isConstBuffer) const {
    auto kind = MemoryKind::BRAM_T2P;
    if (placeExternalBuffer)
      kind = type.getNumElements() >= threshold ? MemoryKind::DRAM
                                                : MemoryKind::BRAM_T2P;
    auto newType = MemRefType::get(
        type.getShape(), type.getElementType(), type.getLayout().getAffineMap(),
        MemoryKindAttr::get(type.getContext(), kind));
    return newType;
  }

  MemRefType getPlacedOnDramType(MemRefType type) const {
    auto newType = MemRefType::get(
        type.getShape(), type.getElementType(), type.getLayout().getAffineMap(),
        MemoryKindAttr::get(type.getContext(), MemoryKind::DRAM));
    return newType;
  }

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;

    for (auto arg : func.getArguments())
      if (auto type = arg.getType().dyn_cast<MemRefType>())
        arg.setType(getPlacedType(type, false));

    func.walk([&](hls::BufferLikeInterface buffer) {
      auto type = buffer.getMemref().getType().cast<MemRefType>();
      if (auto attr = type.getMemorySpace())
        if (attr.isa<MemoryKindAttr>())
          return WalkResult::advance();

      auto kind = MemoryKind::BRAM_T2P;
      if (placeExternalBuffer || isa<ConstBufferOp>(buffer.getOperation()))
        kind = type.getNumElements() >= threshold ? MemoryKind::DRAM
                                                  : MemoryKind::BRAM_T2P;
      auto newType =
          MemRefType::get(type.getShape(), type.getElementType(),
                          type.getLayout().getAffineMap(),
                          MemoryKindAttr::get(type.getContext(), kind));
      buffer.getMemref().setType(newType);
      hasChanged = true;
      return WalkResult::advance();
    });

    func.walk([](YieldOp yield) {
      for (auto t : llvm::zip(yield->getParentOp()->getResults(),
                              yield.getOperandTypes()))
        std::get<0>(t).setType(std::get<1>(t));
    });

    func.setType(rewriter.getFunctionType(
        func.front().getArgumentTypes(),
        func.front().getTerminator()->getOperandTypes()));
    return success(hasChanged);
  }

private:
  unsigned threshold;
  bool placeExternalBuffer;
};
} // namespace

namespace {
/// FIXME: This is super hacky for hoisting all buffers placed in dram to the
/// top level dispatch.
struct HoistDramBuffer
    : public OpInterfaceRewritePattern<hls::BufferLikeInterface> {
  using OpInterfaceRewritePattern<
      hls::BufferLikeInterface>::OpInterfaceRewritePattern;

  LogicalResult matchAndRewrite(hls::BufferLikeInterface buffer,
                                PatternRewriter &rewriter) const override {
    if (!isExtBuffer(buffer.getMemref()))
      return failure();
    // Alwasy move external buffer out of task.
    if (auto task = buffer->getParentOfType<TaskOp>()) {
      buffer->moveBefore(task);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct PlaceDataflowBuffer
    : public PlaceDataflowBufferBase<PlaceDataflowBuffer> {
  PlaceDataflowBuffer() = default;
  explicit PlaceDataflowBuffer(unsigned argThreshold,
                               bool argPlaceExternalBuffer) {
    threshold = argThreshold;
    placeExternalBuffer = argPlaceExternalBuffer;
  }

  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    llvm::outs() << "1\n";

    mlir::RewritePatternSet patterns(context);
    patterns.add<PlaceBuffer>(context, threshold, placeExternalBuffer);
    (void)applyOpPatternsAndFold(func, std::move(patterns));

    llvm::outs() << "2\n";

    patterns.clear();
    patterns.add<HoistDramBuffer>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createPlaceDataflowBufferPass(unsigned threshold,
                                        bool placeExternalBuffer) {
  return std::make_unique<PlaceDataflowBuffer>(threshold, placeExternalBuffer);
}
