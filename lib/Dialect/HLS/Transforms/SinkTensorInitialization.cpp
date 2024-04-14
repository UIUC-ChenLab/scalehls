//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Utils.h"
#include "mlir/Dialect/Linalg/Utils/Utils.h"
#include "mlir/IR/AffineMap.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_SINKTENSORINITIALIZATION
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace {
struct SinkLinalgInitOperands : public OpRewritePattern<linalg::GenericOp> {
  using OpRewritePattern<linalg::GenericOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(linalg::GenericOp linalgOp,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    for (auto [initOperand, outputArg] : llvm::zip(
             linalgOp.getDpsInitsMutable(), linalgOp.getRegionOutputArgs())) {
      auto tensorInit = initOperand.get().getDefiningOp<hls::TensorInitOp>();
      if (!tensorInit || !tensorInit.getInitValue())
        continue;

      auto loc = linalgOp.getLoc();
      rewriter.setInsertionPointToStart(linalgOp.getBody());
      auto constantZeroOp = rewriter.create<arith::ConstantIndexOp>(loc, 0);
      Value condition;
      for (auto [dim, iteratorType] :
           llvm::enumerate(linalgOp.getIteratorTypesArray())) {
        if (linalg::isParallelIterator(iteratorType))
          continue;
        auto indexOp = rewriter.create<linalg::IndexOp>(loc, dim);
        auto eqOp = rewriter.create<arith::CmpIOp>(
            loc, arith::CmpIPredicate::eq, indexOp, constantZeroOp);
        if (!condition)
          condition = eqOp;
        else
          condition = rewriter.create<arith::AndIOp>(loc, condition, eqOp);
      }

      auto initConstant = rewriter.create<arith::ConstantOp>(
          loc, tensorInit.getInitValueAttr());
      auto selectOp = rewriter.create<arith::SelectOp>(
          loc, outputArg.getType(), condition, initConstant, outputArg);
      rewriter.replaceAllUsesExcept(outputArg, selectOp, selectOp);

      rewriter.setInsertionPoint(tensorInit);
      auto newTensorInit =
          rewriter.create<hls::TensorInitOp>(loc, tensorInit.getType());
      rewriter.startOpModification(linalgOp);
      initOperand.set(newTensorInit.getResult());
      rewriter.finalizeOpModification(linalgOp);
      hasChanged = true;
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct SinkTensorInitialization
    : public hls::impl::SinkTensorInitializationBase<SinkTensorInitialization> {
  void runOnOperation() override {
    auto context = &getContext();
    mlir::RewritePatternSet patterns(context);
    patterns.add<SinkLinalgInitOperands>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));
  }
};
} // namespace
