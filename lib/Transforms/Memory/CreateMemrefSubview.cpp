//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/AffineExprVisitor.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct CreateMemrefSubview
    : public scalehls::CreateMemrefSubviewBase<CreateMemrefSubview> {
  CreateMemrefSubview() = default;
  CreateMemrefSubview(CreateSubviewMode argCreateSubviewMode) {
    createSubviewMode = argCreateSubviewMode;
  }

  void runOnOperation() override;
};
} // namespace

static void createSubviewBeforeLoopBand(AffineLoopBand band,
                                        bool tileLayout = false) {
  assert(!band.empty() && "loop band must not be empty");
  auto b = OpBuilder(band.front());
  auto loc = b.getUnknownLoc();
  b.setInsertionPoint(band.front());

  band.back().walk([&](Operation *op) {
    // We only consider affine read/write for now.
    SmallVector<Value, 4> operands;
    AffineMap map;
    Value memref;
    if (auto loadOp = dyn_cast<mlir::AffineReadOpInterface>(op)) {
      operands = SmallVector<Value, 4>(loadOp.getMapOperands());
      map = loadOp.getAffineMap();
      memref = loadOp.getMemRef();
    } else if (auto storeOp = dyn_cast<mlir::AffineWriteOpInterface>(op)) {
      operands = SmallVector<Value, 4>(storeOp.getMapOperands());
      map = storeOp.getAffineMap();
      memref = storeOp.getMemRef();
    } else
      return WalkResult::advance();

    // Construct the dimensions set whose corresponding operand is point loop
    // induction variable.
    llvm::SmallDenseSet<unsigned, 8> pointDims;
    unsigned dim = 0;
    for (auto operand : operands) {
      auto loop = getForInductionVarOwner(operand);

      // We only need to consider point loops here and We assume all point
      // loops are normalized and have constant bounds.
      if (loop && llvm::find(band, loop) != band.end()) {
        if (!loop.hasConstantLowerBound() || !loop.hasConstantUpperBound() ||
            loop.getConstantLowerBound() != 0 ||
            loop.getConstantUpperBound() <= 0 || loop.getStep() != 1)
          return WalkResult::advance();
        pointDims.insert(dim);
      }
      ++dim;
    }

    auto numDims = map.getNumDims();
    auto numSymbols = map.getNumSymbols();
    SmallVector<AffineExpr, 4> accessExprs;
    SmallVector<OpFoldResult, 4> bufOffsets;
    SmallVector<OpFoldResult, 4> bufSizes;
    SmallVector<OpFoldResult, 4> bufStrides;

    bool hasStaticOffset = false;
    SmallVector<int64_t> tileShape;

    // Traverse the memory access index of each dimension to construct the
    // sizes, offsets, and strids of the memref subview. Also, construct the
    // new memory access indices.
    for (auto expr : map.getResults()) {
      if (!expr.isPureAffine())
        return WalkResult::advance();

      // Get the flattened form of the expr, which is a sum of products in an
      // order of [dims, symbols, locals, constant].
      SimpleAffineExprFlattener flattener(numDims, numSymbols);
      flattener.walkPostOrder(expr);
      auto flattenedExpr = flattener.operandExprStack.back();

      // The last coefficient is the constant offset.
      if (flattenedExpr.back() != 0)
        hasStaticOffset = true;

      // Construct the size-expr and offset-expr. For the dims and symbols, as
      // long as an id is found in "pointDims", it is added to the size-expr.
      // Otherwise, it is added to th offset-expr.
      auto offsetExpr = b.getAffineConstantExpr(flattenedExpr.back());
      auto sizeExpr = b.getAffineConstantExpr(0);
      for (unsigned i = 0, e = numDims + numSymbols; i < e; ++i) {
        auto factor = flattenedExpr[i];
        auto id = i < numDims ? b.getAffineDimExpr(i)
                              : b.getAffineSymbolExpr(i - numDims);
        if (pointDims.count(i))
          sizeExpr = sizeExpr + id * factor;
        else
          offsetExpr = offsetExpr + id * factor;
      }

      // For local exprs, if the expr is constructed by pure point loop
      // induction variables or dynamic variables, it is added to the
      // size-expr or offset-expr, respectively. Otherwise, the size of the
      // local buffer will be dynamically shaped, which is not supported by
      // HLS thus is skipped.
      for (unsigned i = numDims + numSymbols, e = flattenedExpr.size() - 1;
           i < e; ++i) {
        auto localExpr = flattener.localExprs[i - numDims - numSymbols];

        bool hasPointLoopVar = false;
        bool hasDynamicVar = false;
        localExpr.walk([&](AffineExpr id) {
          if (auto dim = id.dyn_cast<AffineDimExpr>()) {
            if (pointDims.count(dim.getPosition()))
              hasPointLoopVar = true;
            else
              hasDynamicVar = true;
          } else if (id.isa<AffineSymbolExpr>())
            hasDynamicVar = true;
        });

        auto factor = flattenedExpr[i];
        if (hasPointLoopVar && !hasDynamicVar)
          sizeExpr = sizeExpr + localExpr * factor;
        else if (!hasPointLoopVar && hasDynamicVar)
          offsetExpr = offsetExpr + localExpr * factor;
        else if (hasPointLoopVar && hasDynamicVar)
          return WalkResult::advance();
        else
          llvm_unreachable("unexpected local expression");
      }

      // The stride is simply the largest divisor of the size-expr.
      auto divisor = std::max((int64_t)1, sizeExpr.getLargestKnownDivisor());
      bufStrides.push_back(b.getI64IntegerAttr(divisor));

      // Now we need to determine the size of the resulting memref.
      sizeExpr = sizeExpr.floorDiv(divisor);
      accessExprs.push_back(sizeExpr);
      AffineValueMap sizeMap(AffineMap::get(numDims, numSymbols, sizeExpr),
                             operands);
      (void)sizeMap.canonicalize();

      // Take the upper bound as the size of the current dimension.
      auto bounds = getBoundOfAffineMap(sizeMap.getAffineMap(),
                                        ValueRange(sizeMap.getOperands()));
      if (!bounds.has_value() || bounds.value().first != 0)
        return WalkResult::advance();
      bufSizes.push_back(b.getI64IntegerAttr(bounds.value().second + 1));

      // Record the tile shape.
      tileShape.push_back(divisor * (bounds.value().second + 1));

      // Now we can construct the affine apply for the offset of the current
      // memory dimension.
      AffineValueMap offsetMap(AffineMap::get(numDims, numSymbols, offsetExpr),
                               operands);
      (void)offsetMap.canonicalize();
      auto offsetOp = b.create<AffineApplyOp>(loc, offsetMap.getAffineMap(),
                                              offsetMap.getOperands());
      bufOffsets.push_back(offsetOp.getResult());
    }

    // Finally, create the subview op with the constructed offsets (values
    // generated by affine apply ops), sizes, and strides. Note that this
    // subview only serves the current op and we will canonicalize away
    // redundant subviews later.
    auto subview = b.create<memref::SubViewOp>(loc, memref, bufOffsets,
                                               bufSizes, bufStrides);
    memref.replaceUsesWithIf(subview.getResult(), [&](OpOperand &use) {
      return use.getOwner() == op;
    });

    // Update memory access maps of the current op.
    auto accessMap =
        AffineMap::get(numDims, numSymbols, accessExprs, map.getContext());
    op->setAttr("map", AffineMapAttr::get(accessMap));

    // If necessary, annotate the memref with tile layout attribute.
    // TODO: For now, we only support tile layout without static offset.
    if (tileLayout) {
      if (hasStaticOffset)
        return WalkResult::advance();
      setTileLayout(memref, tileShape);
    }
    return WalkResult::advance();
  });
}

/// This pass reduces the sizes of memrefs passed to each function: (1) conduct
/// loop analysis to determine which tile of a memref is accessed in a function,
/// (2) create a corresponding SubViewOp to load the tile out from the original
/// memref and replace all uses.
void CreateMemrefSubview::runOnOperation() {
  auto func = getOperation();

  // Collect all target loop bands.
  AffineLoopBands targetBands;
  getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);

  for (auto &band : targetBands) {
    if (createSubviewMode == CreateSubviewMode::Point) {
      AffineLoopBand tileBand;
      AffineLoopBand pointBand;
      if (!getTileAndPointLoopBand(band, tileBand, pointBand) ||
          pointBand.empty())
        continue;
      createSubviewBeforeLoopBand(pointBand, /*tileLayout=*/true);
    } else if (createSubviewMode == CreateSubviewMode::Reduction) {
      AffineLoopBand parallelBand;
      AffineLoopBand reductionBand;
      if (!getParallelAndReductionLoopBand(band, parallelBand, reductionBand) ||
          reductionBand.empty())
        continue;
      createSubviewBeforeLoopBand(reductionBand);
    }
  }
}

std::unique_ptr<Pass>
scalehls::createCreateMemrefSubviewPass(CreateSubviewMode createSubviewMode) {
  return std::make_unique<CreateMemrefSubview>(createSubviewMode);
}
