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

// TODO: For now, we use a heuristic to determine the buffer location.
static MemRefType getPlacedType(MemRefType type) {
  auto kind =
      type.getNumElements() < 1024 ? MemoryKind::BRAM_S2P : MemoryKind::DRAM;
  auto newType =
      MemRefType::get(type.getShape(), type.getElementType(),
                      type.getLayout().getAffineMap(), (unsigned)kind);
  return newType;
}

static MemRefType getPlacedOnDramType(MemRefType type) {
  auto newType = MemRefType::get(type.getShape(), type.getElementType(),
                                 type.getLayout().getAffineMap(),
                                 (unsigned)MemoryKind::DRAM);
  return newType;
}

namespace {
struct PlaceBuffer : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    for (auto arg : func.getArguments())
      if (auto type = arg.getType().dyn_cast<MemRefType>())
        arg.setType(getPlacedOnDramType(type));

    func.walk([](hls::BufferLikeInterface buffer) {
      buffer.getMemref().setType(getPlacedType(buffer.getMemrefType()));
    });

    func.walk([](YieldOp yield) {
      for (auto t : llvm::zip(yield->getParentOp()->getResults(),
                              yield.getOperandTypes()))
        std::get<0>(t).setType(std::get<1>(t));
    });

    func.setType(
        FunctionType::get(func.getContext(), func.front().getArgumentTypes(),
                          func.front().getTerminator()->getOperandTypes()));
    return success();
  }
};
} // namespace

namespace {
struct PlaceDataflowBuffer
    : public PlaceDataflowBufferBase<PlaceDataflowBuffer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<PlaceBuffer>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createPlaceDataflowBufferPass() {
  return std::make_unique<PlaceDataflowBuffer>();
}
