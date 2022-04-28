//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/HLS.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct LowerCastAndSubview
    : public LowerCastAndSubviewBase<LowerCastAndSubview> {
  void runOnOperation() override {
    auto module = getOperation();
    auto builder = OpBuilder(module);

    for (auto cast : module.getOps<memref::CastOp>()) {
      auto loc = cast.getLoc();
      builder.setInsertionPointAfter(cast);
      auto buffer = builder.create<memref::AllocOp>(
          loc, cast.dest().getType().dyn_cast<MemRefType>());
      builder.setInsertionPointAfter(buffer);
      auto copy = builder.create<memref::CopyOp>(loc, cast.source(), buffer);
      cast.replaceAllUsesWith(copy.target());
      cast->erase();
    }

    for (auto subview : module.getOps<memref::SubViewOp>()) {
      auto loc = subview.getLoc();
      builder.setInsertionPointAfter(subview);
      auto buffer = builder.create<memref::AllocOp>(
          loc, subview.result().getType().dyn_cast<MemRefType>());
      builder.setInsertionPointAfter(buffer);
      auto copy = builder.create<memref::CopyOp>(loc, subview.result(), buffer);
      subview.replaceAllUsesWith(copy.target());
      copy.sourceMutable().assign(subview.result());
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLowerCastAndSubviewPass() {
  return std::make_unique<LowerCastAndSubview>();
}
