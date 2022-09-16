//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/IR/IntegerSet.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

/// Apply remove variable bound to all inner loops of the input loop.
bool scalehls::applyRemoveVariableBound(AffineLoopBand &band) {
  assert(!band.empty() && "no loops provided");

  auto innermostLoop = band.back();
  auto builder = OpBuilder(innermostLoop);

  // Remove all vairable loop bound if possible.
  for (auto loop : band) {
    if (!loop.hasConstantUpperBound()) {
      // TODO: support variable upper bound with more than one result in the
      // getBoundOfAffineValueMap() method.
      if (auto bound = getBoundOfAffineMap(loop.getUpperBoundMap(),
                                           loop.getUpperBoundOperands())) {
        // Collect all components for creating AffineIf operation.
        auto upperMap = loop.getUpperBoundMap();
        auto ifExpr = upperMap.getResult(0) -
                      builder.getAffineDimExpr(upperMap.getNumDims()) - 1;
        auto ifCondition = IntegerSet::get(upperMap.getNumDims() + 1, 0, ifExpr,
                                           /*eqFlags=*/false);
        auto ifOperands = SmallVector<Value, 4>(loop.getUpperBoundOperands());
        ifOperands.push_back(loop.getInductionVar());

        // Create if operation in the front of the innermost perfect loop.
        builder.setInsertionPointToStart(innermostLoop.getBody());
        auto ifOp =
            builder.create<AffineIfOp>(loop.getLoc(), ifCondition, ifOperands,
                                       /*withElseRegion=*/false);

        // Move all operations in the innermost perfect loop into the new
        // created AffineIf region.
        auto &ifBlock = ifOp.getThenBlock()->getOperations();
        auto &loopBlock = innermostLoop.getBody()->getOperations();
        ifBlock.splice(ifBlock.begin(), loopBlock, std::next(loopBlock.begin()),
                       std::prev(loopBlock.end(), 1));

        // Set constant variable bound.
        auto maximum = bound.value().second;
        loop.setConstantUpperBound(maximum);
      } else
        return false;
    }

    if (!loop.hasConstantLowerBound()) {
      // TODO: support variable lower bound with more than one result in the
      // getBoundOfAffineValueMap() method.
      if (auto bound = getBoundOfAffineMap(loop.getLowerBoundMap(),
                                           loop.getLowerBoundOperands())) {
        // Collect all components for creating AffineIf operation.
        auto lowerMap = loop.getLowerBoundMap();
        auto ifExpr = builder.getAffineDimExpr(lowerMap.getNumDims()) -
                      lowerMap.getResult(0);
        auto ifCondition = IntegerSet::get(lowerMap.getNumDims() + 1, 0, ifExpr,
                                           /*eqFlags=*/false);
        auto ifOperands = SmallVector<Value, 4>(loop.getLowerBoundOperands());
        ifOperands.push_back(loop.getInductionVar());

        // Create if operation in the front of the innermost perfect loop.
        builder.setInsertionPointToStart(innermostLoop.getBody());
        auto ifOp =
            builder.create<AffineIfOp>(loop.getLoc(), ifCondition, ifOperands,
                                       /*withElseRegion=*/false);

        // Move all operations in the innermost perfect loop into the new
        // created AffineIf region.
        auto &ifBlock = ifOp.getThenBlock()->getOperations();
        auto &loopBlock = innermostLoop.getBody()->getOperations();
        ifBlock.splice(ifBlock.begin(), loopBlock, std::next(loopBlock.begin()),
                       std::prev(loopBlock.end(), 1));

        // Set constant variable bound.
        auto minimum = bound.value().first;
        loop.setConstantLowerBound(minimum);
      } else
        return false;
    }
  }
  return true;
}

namespace {
struct RemoveVariableBound
    : public RemoveVariableBoundBase<RemoveVariableBound> {
  void runOnOperation() override {
    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(getOperation().front(), targetBands);

    // Apply loop order optimization to each loop band.
    for (auto &band : targetBands)
      applyRemoveVariableBound(band);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createRemoveVariableBoundPass() {
  return std::make_unique<RemoveVariableBound>();
}
