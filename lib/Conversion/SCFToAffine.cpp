//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/AffineExpr.h"
#include "mlir/IR/AffineMap.h"
#include "mlir/IR/BlockAndValueMapping.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/Passes.h"
#include "mlir/Transforms/Utils.h"
#include "scalehls/Conversion/Passes.h"

using namespace mlir;
using namespace mlir::scf;
using namespace scalehls;
using namespace memref;

// Raise scf.for and scf.yield to affine.for and affine.yield
// to enable analysis on dimensions and symbols
namespace {
// Conversion Target
class SCFForRaisingTarget : public ConversionTarget {
public:
  explicit SCFForRaisingTarget(MLIRContext &context)
      : ConversionTarget(context) {}

  bool isDynamicallyLegal(Operation *op) const override {
    if (auto forOp = dyn_cast<scf::ForOp>(op)) {
      if (auto cst = forOp.step().getDefiningOp<ConstantIndexOp>())
        // step > 0 already verified in SCF dialect
        return false;
    }
    return true;
  }
};

// Rewriting Pass
struct SCFForRaisingPass : public SCFForRaisingBase<SCFForRaisingPass> {
  void runOnOperation() override;
};

// Raise scf.for to affine.for & replace scf.yield with affine.yield
struct SCFForRaising : public OpRewritePattern<ForOp> {
  using OpRewritePattern<ForOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ForOp forOp,
                                PatternRewriter &rewriter) const override;
};
} // namespace

// Raise scf.for to affine.for & replace scf.yield with affine.yield
// Conversion:
// Raise scf.for to affine.for:
// scf.for step -> affine.for step
// scf.for lb -> affine.for lb
// scf.for ub -> affine.for ub
// scf.for iter_ags -> affine.for iter_args
// scf.yield -> affine.yield
// scf.for body -> affine.for body
// create a map for both lb, ub: #map1 = affine_map<()[s0] -> (s0)>
LogicalResult SCFForRaising::matchAndRewrite(ForOp forOp,
                                             PatternRewriter &rewriter) const {
  Location loc = forOp.getLoc();
  // map scf.for operands to affine.for
  auto step = forOp.step();
  auto lb = forOp.lowerBound();
  auto ub = forOp.upperBound();
  // auto iterArgs = forOp.getRegionIterArgs();
  // affine.for only accepts a step as a literal
  int stepNum = dyn_cast<ConstantOp>(step.getDefiningOp())
                    .getValue()
                    .cast<IntegerAttr>()
                    .getInt();

  auto symbolExpr = getAffineSymbolExpr(0, rewriter.getContext());
  auto dimExpr = getAffineDimExpr(0, rewriter.getContext());

  // the loop bounds are both valid symbols or dims.
  AffineMap lbAffineMap = AffineMap::get(0, 1, symbolExpr);
  if (!lb.getDefiningOp())
    lbAffineMap = AffineMap::get(1, 0, dimExpr);

  AffineMap ubAffineMap = AffineMap::get(0, 1, symbolExpr);
  if (!ub.getDefiningOp())
    ubAffineMap = AffineMap::get(1, 0, dimExpr);

  auto f = rewriter.create<mlir::AffineForOp>(loc, lb, lbAffineMap, ub,
                                              ubAffineMap, stepNum);
  rewriter.eraseBlock(f.getBody());
  Operation *loopTerminator = forOp.region().back().getTerminator();
  ValueRange terminatorOperands = loopTerminator->getOperands();
  rewriter.setInsertionPointToEnd(&forOp.region().back());
  rewriter.create<AffineYieldOp>(loc, terminatorOperands);
  rewriter.inlineRegionBefore(forOp.region(), f.region(), f.region().end());
  rewriter.eraseOp(loopTerminator);
  rewriter.eraseOp(forOp);
  return success();
}

void mlir::scalehls::SCFForRaisingPatterns(RewritePatternSet &patterns) {
  patterns.add<SCFForRaising>(patterns.getContext());
}

void SCFForRaisingPass::runOnOperation() {
  RewritePatternSet patterns(&getContext());
  SCFForRaisingPatterns(patterns);
  SCFForRaisingTarget target(getContext());
  target.addLegalDialect<SCFDialect, AffineDialect>();
  target.addDynamicallyLegalOp<scf::ForOp>();
  target.markUnknownOpDynamicallyLegal([](Operation *) { return true; });
  if (failed(
          applyPartialConversion(getOperation(), target, std::move(patterns))))
    signalPassFailure();
}

std::unique_ptr<Pass> scalehls::createRaiseSCFForPass() {
  return std::make_unique<SCFForRaisingPass>();
}

// Raise std.load and std.store to affine.load and affine.store
// after the affineScope is constructed by raising the scf.for loops
namespace {
// Conversion Target
class LoadStoreRaisingTarget : public ConversionTarget {
public:
  explicit LoadStoreRaisingTarget(MLIRContext &context)
      : ConversionTarget(context) {}

  // return whether the index is in affine expression
  bool isAffineType(Value value) const {
    if (isValidDim(value) || isValidSymbol(value))
      return true;
    else if (auto op = value.getDefiningOp()) {
      if (isa<MulIOp>(op)) { // cannot recognise the pattern s0*(d1+s2) so far
        if (isValidSymbol(op->getOperand(0)))
          return isValidDim(op->getOperand(1));
        else if (isValidSymbol(op->getOperand(1)))
          return isValidDim(op->getOperand(0));
        else
          return false;
      } else if (isa<AddIOp>(op)) // affine + affine is affine
        return (isAffineType(op->getOperand(0)) &&
                isAffineType(op->getOperand(1)));
      else
        return false;
    } else
      return false;
  }

  bool isDynamicallyLegal(Operation *op) const override {
    if (auto loadOp = dyn_cast<LoadOp>(op)) {
      for (auto index : loadOp.getIndices()) {
        if (!isAffineType(index))
          return true;
      }
      return false;
    } else if (auto storeOp = dyn_cast<StoreOp>(op)) {
      for (auto index : storeOp.getIndices()) {
        if (!isAffineType(index))
          return true;
      }
      return false;
    } else
      return true;
  }
};

// Rewriting Pass
struct LoadStoreRaisingPass
    : public LoadStoreRaisingBase<LoadStoreRaisingPass> {
  void runOnOperation() override;
};

// Raise std.load to affine.load
struct LoadRaising : public OpRewritePattern<LoadOp> {
  using OpRewritePattern<LoadOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(LoadOp loadOp,
                                PatternRewriter &rewriter) const override;
};

// Raise std.store to affine.store
struct StoreRaising : public OpRewritePattern<StoreOp> {
  using OpRewritePattern<StoreOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(StoreOp storeOp,
                                PatternRewriter &rewriter) const override;
};
} // namespace

// Extract the affine expression from a number of std operations
AffineExpr getAffineExpr(Value value, PatternRewriter &rewriter,
                         std::vector<Value> *dims,
                         std::vector<Value> *symbols) {
  auto op = value.getDefiningOp();
  assert(op != NULL || isValidDim(value));
  if (isValidSymbol(value)) {
    int symbolIdx;
    auto symbolIter = std::find(symbols->begin(), symbols->end(), value);
    if (symbolIter == symbols->end()) {
      symbolIdx = symbols->size();
      symbols->push_back(value);
    } else
      symbolIdx = std::distance(symbols->begin(), symbolIter);
    return getAffineSymbolExpr(symbolIdx, rewriter.getContext());
  } else if (isValidDim(value)) {
    int dimIdx;
    auto dimIter = std::find(dims->begin(), dims->end(), value);
    if (dimIter == dims->end()) {
      dimIdx = dims->size();
      dims->push_back(value);
    } else
      dimIdx = std::distance(dims->begin(), dimIter);
    return getAffineDimExpr(dimIdx, rewriter.getContext());
  } else if (isa<AddIOp>(op))
    return getAffineExpr(op->getOperand(0), rewriter, dims, symbols) +
           getAffineExpr(op->getOperand(1), rewriter, dims, symbols);
  else if (isa<MulIOp>(op))
    return getAffineExpr(op->getOperand(0), rewriter, dims, symbols) *
           getAffineExpr(op->getOperand(1), rewriter, dims, symbols);
  else
    return nullptr;
}

// Raise std.load to affine.load
// for each index of the loadOp, extract its affine expression
// construct a map with the dim and symbol count for the affine.load
// replace the loadOp with the newly constructed affine.load
LogicalResult LoadRaising::matchAndRewrite(memref::LoadOp loadOp,
                                           PatternRewriter &rewriter) const {
  std::vector<Value> indices, dims, symbols;
  std::vector<AffineExpr> exprs;

  for (auto index : loadOp.getIndices()) {
    indices.push_back(index);
    auto affineExpr = getAffineExpr(index, rewriter, &dims, &symbols);
    if (!affineExpr)
      return failure();
    exprs.push_back(affineExpr);
  }
  ArrayRef<AffineExpr> results(exprs);
  AffineMap affineMap = AffineMap::get(dims.size(), symbols.size(), results,
                                       rewriter.getContext());
  dims.insert(dims.end(), symbols.begin(), symbols.end());
  rewriter.replaceOpWithNewOp<AffineLoadOp>(loadOp, loadOp.getMemRef(),
                                            affineMap, dims);
  return success();
}

// Raise std.store to affine.store
LogicalResult StoreRaising::matchAndRewrite(memref::StoreOp storeOp,
                                            PatternRewriter &rewriter) const {

  std::vector<Value> indices, dims, symbols;
  std::vector<AffineExpr> exprs;

  for (auto index : storeOp.getIndices()) {
    indices.push_back(index);
    auto affineExpr = getAffineExpr(index, rewriter, &dims, &symbols);
    if (!affineExpr)
      return failure();
    exprs.push_back(affineExpr);
  }
  ArrayRef<AffineExpr> results(exprs);
  AffineMap affineMap = AffineMap::get(dims.size(), symbols.size(), results,
                                       rewriter.getContext());
  dims.insert(dims.end(), symbols.begin(), symbols.end());
  rewriter.replaceOpWithNewOp<AffineStoreOp>(
      storeOp, storeOp.getValueToStore(), storeOp.getMemRef(), affineMap, dims);
  return success();
}

void scalehls::LoadStoreRaisingPatterns(RewritePatternSet &patterns) {
  patterns.add<LoadRaising, StoreRaising>(patterns.getContext());
}

void LoadStoreRaisingPass::runOnOperation() {
  RewritePatternSet patterns(&getContext());
  LoadStoreRaisingPatterns(patterns);
  LoadStoreRaisingTarget target(getContext());
  target.addLegalDialect<SCFDialect, AffineDialect, MemRefDialect>();
  target.addDynamicallyLegalOp<memref::LoadOp, memref::StoreOp>();
  target.markUnknownOpDynamicallyLegal([](Operation *) { return true; });
  if (failed(
          applyPartialConversion(getOperation(), target, std::move(patterns))))
    signalPassFailure();
}

std::unique_ptr<Pass> scalehls::createRaiseLoadStorePass() {
  return std::make_unique<LoadStoreRaisingPass>();
}
