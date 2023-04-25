//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct RaiseAffineToCopy : public RaiseAffineToCopyBase<RaiseAffineToCopy> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands);

    for (auto &band : targetBands) {
      // Make sure we only have a pair of load and store in the loop body.
      auto &bodyOps = band.back().getBody()->getOperations();
      if (!isPerfectlyNested(band) || bodyOps.size() != 3)
        continue;

      // Check the copy semantic and make sure the load and store have the same
      // memory access.
      auto load = dyn_cast<AffineLoadOp>(*bodyOps.begin());
      auto store = dyn_cast<AffineStoreOp>(*std::next(bodyOps.begin()));
      if (!load || !store || load.getResult() != store.getValue() ||
          load.getMemref().getType().getShape() !=
              store.getMemref().getType().getShape() ||
          store.getMapOperands() != load.getMapOperands() ||
          store.getAffineMap() != load.getAffineMap())
        continue;

      // Make sure the all loops in the band have constant trip count.
      llvm::SmallDenseMap<Value, unsigned, 4> shapeMap;
      if (llvm::any_of(band, [&](AffineForOp loop) {
            auto maybeTripCount = getConstantTripCount(loop);
            if (!maybeTripCount.has_value())
              return true;
            shapeMap[loop.getInductionVar()] = maybeTripCount.value();
            return false;
          }))
        continue;

      // Make sure the loop nest accesses each element in the memory once.
      auto exprAndShapeRange = llvm::zip(load.getAffineMap().getResults(),
                                         load.getMemRefType().getShape());
      if (llvm::any_of(exprAndShapeRange, [&](auto exprAndShape) {
            AffineExpr expr = std::get<0>(exprAndShape);
            unsigned shape = std::get<1>(exprAndShape);

            if (auto constExpr = expr.dyn_cast<AffineConstantExpr>())
              return constExpr.getValue() != 0 || shape != 1;
            else if (auto dimExpr = expr.dyn_cast<AffineDimExpr>()) {
              auto index = load.getMapOperands()[dimExpr.getPosition()];
              return shapeMap.lookup(index) != shape;
            } else
              return true;
          }))
        continue;

      // Replace the loop nest with a copy op.
      builder.setInsertionPoint(band.front());
      builder.create<memref::CopyOp>(band.front().getLoc(), load.getMemref(),
                                     store.getMemref());
      band.front().erase();
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createRaiseAffineToCopyPass() {
  return std::make_unique<RaiseAffineToCopy>();
}
