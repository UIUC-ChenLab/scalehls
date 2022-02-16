//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Conversion/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

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
    if (!dataType || dataType.getWidth() == 32)
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
    if (!dataType || dataType.getWidth() != 8)
      return failure();

    // Generate new type.
    Type newType = IntegerType::get(rewriter.getContext(), 16);
    if (auto vectorType = mul.getType().dyn_cast<VectorType>()) {
      if (vectorType.getNumElements() != 2)
        return failure();
      newType = VectorType::get(vectorType.getShape(),
                                IntegerType::get(rewriter.getContext(), 16));
    }

    // Replace the original op with multiplication primitive op.
    auto loc = mul.getLoc();
    rewriter.setInsertionPoint(mul);
    auto mulResult =
        rewriter.create<MulPrimOp>(loc, newType, mul.getLhs(), mul.getRhs());
    auto cast = rewriter.create<CastPrimOp>(loc, mul.getType(), mulResult);
    rewriter.replaceOp(mul, cast.getResult());

    return success();
  }
};
} // namespace

bool scalehls::applyLegalizeToHLSCpp(FuncOp func, bool isTopFunc) {
  auto builder = OpBuilder(func);

  // We constain functions to only contain one block.
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  // Set function pragma attributes.
  if (!getFuncDirective(func))
    setFuncDirective(func, false, 1, false, isTopFunc);

  // Walk through all operations in the function.
  SmallPtrSet<Value, 16> memrefs;
  func.walk([&](Operation *op) {
    // Collect all memrefs.
    for (auto operand : op->getOperands())
      if (operand.getType().isa<MemRefType>())
        memrefs.insert(operand);

    // Set loop directive attributes.
    if (auto forOp = dyn_cast<AffineForOp>(op)) {
      if (!getLoopDirective(forOp))
        setLoopDirective(forOp, false, 1, false, false, isLoopParallel(forOp));
    }
  });

  // Set array directives.
  for (auto memref : memrefs) {
    auto type = memref.getType().cast<MemRefType>();

    if (type.getMemorySpace() == 0) {
      // TODO: determine memory kind according to data type.
      MemoryKind kind = MemoryKind::BRAM_S2P;

      auto newType =
          MemRefType::get(type.getShape(), type.getElementType(),
                          type.getLayout().getAffineMap(), (unsigned)kind);
      memref.setType(newType);
    }
  }

  // Align function type with entry block argument types.
  auto resultTypes = func.front().getTerminator()->getOperandTypes();
  auto inputTypes = func.front().getArgumentTypes();
  func.setType(builder.getFunctionType(inputTypes, resultTypes));

  // Insert AssignOp when an arguments or result of ConstantOp are directly
  // connected to ReturnOp.
  auto returnOp = func.front().getTerminator();
  builder.setInsertionPoint(returnOp);
  unsigned idx = 0;
  for (auto operand : returnOp->getOperands()) {
    if (operand.dyn_cast<BlockArgument>()) {
      auto value = builder.create<AssignOp>(returnOp->getLoc(),
                                            operand.getType(), operand);
      returnOp->setOperand(idx, value);
    } else if (isa<arith::ConstantOp>(operand.getDefiningOp())) {
      auto value = builder.create<AssignOp>(returnOp->getLoc(),
                                            operand.getType(), operand);
      returnOp->setOperand(idx, value);
    }
    ++idx;
  }

  mlir::RewritePatternSet patterns(func.getContext());
  patterns.add<AddOpRewritePattern>(func.getContext());
  patterns.add<MulOpRewritePattern>(func.getContext());
  (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  return true;
}

namespace {
struct LegalizeToHLSCpp : public LegalizeToHLSCppBase<LegalizeToHLSCpp> {
public:
  void runOnOperation() override {
    auto func = getOperation();
    applyLegalizeToHLSCpp(func, func.getName() == topFunc);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeToHLSCppPass() {
  return std::make_unique<LegalizeToHLSCpp>();
}
