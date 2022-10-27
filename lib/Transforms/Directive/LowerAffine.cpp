//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/AffineToStandard/AffineToStandard.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Utils.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

class LowerAffineFor : public OpRewritePattern<AffineForOp> {
public:
  using OpRewritePattern<AffineForOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineForOp op,
                                PatternRewriter &rewriter) const override {
    Location loc = op.getLoc();
    Value lowerBound = lowerAffineLowerBound(op, rewriter);
    Value upperBound = lowerAffineUpperBound(op, rewriter);
    Value step = rewriter.create<arith::ConstantIndexOp>(loc, op.getStep());
    auto scfForOp = rewriter.create<scf::ForOp>(loc, lowerBound, upperBound,
                                                step, op.getIterOperands());

    // Pass loop directive and info to the generated SCF loop.
    if (auto attr = getLoopDirective(op))
      setLoopDirective(scfForOp, attr);
    if (auto attr = getLoopInfo(op))
      setLoopInfo(scfForOp, attr);

    rewriter.eraseBlock(scfForOp.getBody());
    rewriter.inlineRegionBefore(op.getRegion(), scfForOp.getRegion(),
                                scfForOp.getRegion().end());
    rewriter.replaceOp(op, scfForOp.getResults());
    return success();
  }
};

class LowerAffineSelect : public OpRewritePattern<AffineSelectOp> {
  using OpRewritePattern<AffineSelectOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineSelectOp op,
                                PatternRewriter &rewriter) const override {
    auto loc = op.getLoc();

    // Now we just have to handle the condition logic.
    auto integerSet = op.getIntegerSet();
    Value zeroConstant = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    SmallVector<Value, 8> operands(op.getOperands());
    auto operandsRef = llvm::makeArrayRef(operands);

    // Calculate cond as a conjunction without short-circuiting.
    Value cond = nullptr;
    for (unsigned i = 0, e = integerSet.getNumConstraints(); i < e; ++i) {
      AffineExpr constraintExpr = integerSet.getConstraint(i);
      bool isEquality = integerSet.isEq(i);

      // Build and apply an affine expression
      auto numDims = integerSet.getNumDims();
      Value affResult = expandAffineExpr(rewriter, loc, constraintExpr,
                                         operandsRef.take_front(numDims),
                                         operandsRef.drop_front(numDims));
      if (!affResult)
        return failure();
      auto pred =
          isEquality ? arith::CmpIPredicate::eq : arith::CmpIPredicate::sge;
      Value cmpVal =
          rewriter.create<arith::CmpIOp>(loc, pred, affResult, zeroConstant);
      cond = cond ? rewriter.create<arith::AndIOp>(loc, cond, cmpVal) : cmpVal;
    }
    cond = cond ? cond : rewriter.create<arith::ConstantIntOp>(loc, 1, 1);

    // Replace the Affine IfOp finally.
    rewriter.replaceOpWithNewOp<arith::SelectOp>(
        op, op.getType(), cond, op.getTrueValue(), op.getFalseValue());
    return success();
  }
};

namespace {
struct LowerAffine : public LowerAffineBase<LowerAffine> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    populateAffineToStdConversionPatterns(patterns);
    populateAffineToVectorConversionPatterns(patterns);
    patterns.add<LowerAffineSelect>(context);
    patterns.add<LowerAffineFor>(context, /*benefit=*/1);

    ConversionTarget target(*context);
    target.addIllegalDialect<mlir::AffineDialect>();
    target.addLegalDialect<arith::ArithmeticDialect, memref::MemRefDialect,
                           scf::SCFDialect, vector::VectorDialect>();
    if (failed(applyPartialConversion(func, target, std::move(patterns))))
      return signalPassFailure();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLowerAffinePass() {
  return std::make_unique<LowerAffine>();
}
