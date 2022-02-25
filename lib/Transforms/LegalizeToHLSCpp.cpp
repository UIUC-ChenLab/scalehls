//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
/// Simple memref load to affine load raising.
struct MemrefLoadRewritePattern : public OpRewritePattern<memref::LoadOp> {
  using OpRewritePattern<memref::LoadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::LoadOp load,
                                PatternRewriter &rewriter) const override {
    if (llvm::all_of(load.getIndices(), [&](Value operand) {
          return isValidDim(operand) || isValidSymbol(operand);
        })) {
      rewriter.replaceOpWithNewOp<AffineLoadOp>(load, load.memref(),
                                                load.getIndices());
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
/// Simple memref store to affine store raising.
struct MemrefStoreRewritePattern : public OpRewritePattern<memref::StoreOp> {
  using OpRewritePattern<memref::StoreOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::StoreOp store,
                                PatternRewriter &rewriter) const override {
    if (llvm::all_of(store.getIndices(), [&](Value operand) {
          return isValidDim(operand) || isValidSymbol(operand);
        })) {
      rewriter.replaceOpWithNewOp<AffineStoreOp>(
          store, store.value(), store.memref(), store.getIndices());
      return success();
    }
    return failure();
  }
};
} // namespace

bool scalehls::applyLegalizeToHLSCpp(FuncOp func, bool isTopFunc) {
  auto builder = OpBuilder(func);

  // We constrain functions to only contain one block.
  if (!llvm::hasSingleElement(func))
    func.emitError("has zero or more than one basic blocks.");

  // TODO: Make sure there's no memref store/load or scf operations?

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

      // FIXME: This is a very very bad practice...
      // TODO: How to represent different memory resource?
      if (auto getGlobal = memref.getDefiningOp<memref::GetGlobalOp>()) {
        auto module = getGlobal->getParentOfType<ModuleOp>();
        auto global =
            module.lookupSymbol<memref::GlobalOp>(getGlobal.nameAttr());
        global->setAttr(global.typeAttrName(), TypeAttr::get(newType));
      }
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
  patterns.add<MemrefLoadRewritePattern>(func.getContext());
  patterns.add<MemrefStoreRewritePattern>(func.getContext());
  vector::populateVectorTransferLoweringPatterns(patterns);
  (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

  return true;
}

namespace {
struct LegalizeToHLSCpp : public LegalizeToHLSCppBase<LegalizeToHLSCpp> {
  LegalizeToHLSCpp() = default;
  LegalizeToHLSCpp(const ScaleHLSPyTorchPipelineOptions &opts) {
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
std::unique_ptr<Pass> scalehls::createLegalizeToHLSCppPass(
    const ScaleHLSPyTorchPipelineOptions &opts) {
  return std::make_unique<LegalizeToHLSCpp>(opts);
}
