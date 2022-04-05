//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
/// Simple memref load to affine load raising.
struct MemrefLoadRaisePattern : public OpRewritePattern<memref::LoadOp> {
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
struct MemrefStoreRaisePattern : public OpRewritePattern<memref::StoreOp> {
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

namespace {
struct AffineStoreUndefFoldPattern
    : public OpRewritePattern<mlir::AffineStoreOp> {
  using OpRewritePattern<mlir::AffineStoreOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(mlir::AffineStoreOp store,
                                PatternRewriter &rewriter) const override {
    if (store.getValueToStore().getDefiningOp<LLVM::UndefOp>()) {
      store.emitWarning("undef memory store is folded");
      rewriter.eraseOp(store);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct AllocaDemotePattern : public OpRewritePattern<memref::AllocaOp> {
  using OpRewritePattern<memref::AllocaOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(memref::AllocaOp alloca,
                                PatternRewriter &rewriter) const override {
    rewriter.setInsertionPoint(alloca);
    rewriter.replaceOpWithNewOp<memref::AllocOp>(alloca, alloca.getType());
    return success();
  }
};
} // namespace

bool scalehls::applyFuncPreprocess(FuncOp func, bool isTopFunc) {
  auto builder = OpBuilder(func);
  auto context = func.getContext();

  // We constrain functions to only contain one block.
  if (!llvm::hasSingleElement(func))
    func.emitError("has more than one basic blocks.");

  // Set top function attribute.
  if (isTopFunc)
    setTopFuncAttr(func);

  // Set parallel attribute to each loop that is applicable.
  func.walk([&](AffineForOp loop) {
    if (isLoopParallel(loop))
      setParallelAttr(loop);
  });

  // We always don't return results in HLS. Instead, we convert results to
  // function parameters. Therefore, we insert BufferOp when an arguments or
  // result of ConstantOp are directly connected to ReturnOp.
  // TODO: We should introduce pointer types here.
  auto returnOp = func.front().getTerminator();
  for (auto &use : llvm::make_early_inc_range(returnOp->getOpOperands()))
    if (use.get().dyn_cast<BlockArgument>() ||
        isa<arith::ConstantOp>(use.get().getDefiningOp())) {
      builder.setInsertionPoint(returnOp);
      auto value = builder.create<DataflowBufferOp>(
          returnOp->getLoc(), use.get().getType(), use.get(), /*depth=*/1);
      use.set(value);
    }

  mlir::RewritePatternSet patterns(context);
  patterns.add<MemrefLoadRaisePattern>(context);
  patterns.add<MemrefStoreRaisePattern>(context);
  vector::populateVectorTransferLoweringPatterns(patterns);
  patterns.add<AffineStoreUndefFoldPattern>(context);
  patterns.add<AllocaDemotePattern>(context);
  (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

  // We don't support any scf or memref load/store operations.
  if (WalkResult::interrupt() == func.walk([&](Operation *op) {
        if (isa<scf::SCFDialect>(op->getDialect()) ||
            isa<memref::LoadOp, memref::StoreOp>(op))
          return WalkResult::interrupt();
        return WalkResult::advance();
      }))
    return false;

  return true;
}

namespace {
struct FuncPreprocess : public FuncPreprocessBase<FuncPreprocess> {
  FuncPreprocess() = default;
  FuncPreprocess(std::string hlsTopFunc) { topFunc = hlsTopFunc; }

  void runOnOperation() override {
    auto func = getOperation();
    auto isTop = func.getName() == topFunc;
    applyFuncPreprocess(func, isTop);
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createFuncPreprocessPass(std::string hlsTopFunc) {
  return std::make_unique<FuncPreprocess>(hlsTopFunc);
}
