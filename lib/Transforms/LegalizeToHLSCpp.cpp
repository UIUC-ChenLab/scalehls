//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Vector/VectorOps.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct TransferReadConversionPattern
    : public OpConversionPattern<vector::TransferReadOp> {
  using OpConversionPattern<vector::TransferReadOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(vector::TransferReadOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    if (!op.permutation_map().isMinorIdentity() ||
        !op.source().getType().isa<MemRefType>())
      return failure();
    rewriter.replaceOpWithNewOp<AffineVectorLoadOp>(op, op.getType(),
                                                    op.source(), op.indices());
    return success();
  }
};
} // namespace

namespace {
struct TransferWriteConversionPattern
    : public OpConversionPattern<vector::TransferWriteOp> {
  using OpConversionPattern<vector::TransferWriteOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(vector::TransferWriteOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    if (!op.permutation_map().isMinorIdentity() ||
        !op.source().getType().isa<MemRefType>())
      return failure();
    rewriter.replaceOpWithNewOp<AffineVectorStoreOp>(op, op.vector(),
                                                     op.source(), op.indices());
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
  if (auto fd = getFuncDirective(func))
    setFuncDirective(func, fd.getPipeline(), fd.getTargetInterval(),
                     fd.getDataflow(), isTopFunc);
  else
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

  RewritePatternSet patterns(func.getContext());
  ConversionTarget target(*func.getContext());

  // TODO: Make sure the lowering is safe and thorough.
  // patterns.add<TransferReadConversionPattern>(patterns.getContext());
  // patterns.add<TransferWriteConversionPattern>(patterns.getContext());
  // target.addLegalOp<AffineVectorLoadOp>();
  // target.addLegalOp<AffineVectorStoreOp>();
  // (void)applyPartialConversion(func, target, std::move(patterns));

  // patterns.clear();
  // vector::populateVectorTransferLoweringPatterns(patterns);
  // (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

  return true;
}

namespace {
struct LegalizeToHLSCpp : public LegalizeToHLSCppBase<LegalizeToHLSCpp> {
  LegalizeToHLSCpp() = default;
  LegalizeToHLSCpp(const ScaleHLSOptions &opts) {
    topFunc = opts.hlscppTopFunc;
  }

  void runOnOperation() override {
    auto func = getOperation();
    applyLegalizeToHLSCpp(func, func.getName() == topFunc);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeToHLSCppPass() {
  return std::make_unique<LegalizeToHLSCpp>();
}
std::unique_ptr<Pass>
scalehls::createLegalizeToHLSCppPass(const ScaleHLSOptions &opts) {
  return std::make_unique<LegalizeToHLSCpp>(opts);
}
