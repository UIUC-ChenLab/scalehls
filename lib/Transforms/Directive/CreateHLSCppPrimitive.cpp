//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

static IntegerType getIntDataType(Type type) {
  auto dataType = type.dyn_cast<IntegerType>();
  if (auto vectorType = type.dyn_cast<VectorType>())
    dataType = vectorType.getElementType().dyn_cast<IntegerType>();
  return dataType;
}

namespace {
struct AddOpRewritePattern : public OpRewritePattern<arith::AddIOp> {
  using OpRewritePattern<arith::AddIOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(arith::AddIOp add,
                                PatternRewriter &rewriter) const override {
    // Figure out whether the add op can be rewritten.
    auto dataType = getIntDataType(add.getType());
    if (!dataType || dataType.getWidth() == 32 || dataType.isSigned())
      return failure();

    // Generate new type.
    Type newType = rewriter.getI32Type();
    if (auto vectorType = add.getType().dyn_cast<VectorType>())
      newType = VectorType::get(vectorType.getShape(), rewriter.getI32Type());

    // Cast add op operand from the new type.
    auto loc = add.getLoc();
    rewriter.setInsertionPoint(add);
    auto newLhs = rewriter.create<CastPrimOp>(loc, newType, add.getLhs());
    auto newRhs = rewriter.create<CastPrimOp>(loc, newType, add.getRhs());
    add.getLhsMutable().assign(newLhs);
    add.getRhsMutable().assign(newRhs);

    // Cast add op result to the new type.
    rewriter.setInsertionPointAfter(add);
    auto cast =
        rewriter.create<CastPrimOp>(loc, add.getType(), add.getResult());
    add.getResult().replaceAllUsesExcept(cast.getResult(), cast);
    add.getResult().setType(newType);

    return success();
  }
};
} // namespace

namespace {
struct MulOpRewritePattern : public OpRewritePattern<arith::MulIOp> {
  using OpRewritePattern<arith::MulIOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(arith::MulIOp mul,
                                PatternRewriter &rewriter) const override {
    // Figure out whether the mul op can be rewritten.
    auto dataType = getIntDataType(mul.getType());
    if (!dataType || dataType.getWidth() != 8 || dataType.isSigned())
      return failure();

    // Generate new type.
    Type newType = IntegerType::get(rewriter.getContext(), 16);
    if (auto vectorType = mul.getType().dyn_cast<VectorType>()) {
      if (vectorType.getNumElements() != 2)
        return failure();
      newType = VectorType::get(vectorType.getShape(),
                                IntegerType::get(rewriter.getContext(), 16));
    }

    auto lhs = mul.getLhs();
    if (auto broadcast = lhs.getDefiningOp<vector::BroadcastOp>())
      lhs = broadcast.source();

    auto rhs = mul.getRhs();
    if (auto broadcast = rhs.getDefiningOp<vector::BroadcastOp>())
      rhs = broadcast.source();

    // Replace the original op with multiplication primitive op.
    auto loc = mul.getLoc();
    rewriter.setInsertionPoint(mul);
    auto mulResult = rewriter.create<MulPrimOp>(loc, newType, lhs, rhs);
    auto cast = rewriter.create<CastPrimOp>(loc, mul.getType(), mulResult);
    rewriter.replaceOp(mul, cast.getResult());

    return success();
  }
};
} // namespace

namespace {
struct CreateHLSCppPrimitive
    : public CreateHLSCppPrimitiveBase<CreateHLSCppPrimitive> {
  void runOnOperation() override {
    auto func = getOperation();

    mlir::RewritePatternSet patterns(func.getContext());
    patterns.add<AddOpRewritePattern>(func.getContext());
    patterns.add<MulOpRewritePattern>(func.getContext());
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreateHLSCppPrimitivePass() {
  return std::make_unique<CreateHLSCppPrimitive>();
}
