//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Dialect/SCF/Transforms/Transforms.h"
#include "mlir/Dialect/SCF/Utils/Utils.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"
#include "scalehls/Utils/Matchers.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct GenerateTaskDesignSpacePattern : public OpRewritePattern<TaskOp> {
  GenerateTaskDesignSpacePattern(MLIRContext *context, Block *globalSpaceBlock,
                                 StringRef globalSpaceName, unsigned &taskIdx,
                                 const SmallVector<DeclareOp> &ipDeclares)
      : OpRewritePattern<TaskOp>(context), globalSpaceBlock(globalSpaceBlock),
        globalSpaceName(globalSpaceName), taskIdx(taskIdx),
        ipDeclares(ipDeclares) {}

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    auto linalgOp = task.getPayloadLinalgOp();
    if (!linalgOp || task.getSpace().has_value())
      return failure();
    auto loc = task.getLoc();

    // Generate a sub-space for the current task.
    rewriter.setInsertionPoint(globalSpaceBlock->getTerminator());
    auto taskSpace =
        rewriter.create<SpaceOp>(loc, "task" + std::to_string(taskIdx++));
    auto taskSpaceBlock = rewriter.createBlock(&taskSpace.getBody());

    // Generate tile factors of the current task.
    SmallVector<Value> tileParams;
    for (auto loopSize : llvm::enumerate(linalgOp.computeStaticLoopSizes())) {
      auto tileBounds = {rewriter.getAffineConstantExpr(0),
                         rewriter.getAffineConstantExpr(loopSize.value())};
      auto tileParamOp = rewriter.create<ParamOp>(
          loc, rewriter.getIndexType(), ValueRange(),
          AffineMap::get(0, 0, tileBounds, rewriter.getContext()),
          "tile" + std::to_string(loopSize.index()));
      tileParams.push_back(tileParamOp);
    }

    // Now we generate a sub-space for the implementation of the current task.
    // The implementation should take the tile factors as hyper parameters for
    // constraining the parallel factors.
    auto implSpace = rewriter.create<SpaceOp>(loc, tileParams, "impl");
    auto implEntryBlock = rewriter.createBlock(&implSpace.getBody());
    auto tileParamArgs = implEntryBlock->addArguments(
        ValueRange(tileParams), SmallVector<Location>(tileParams.size(), loc));

    // We start to collect implementation candidates as an array attribute. We
    // always push the default implementatoin as the first candidate.
    SmallVector<Attribute> implCandidates;
    SmallVector<Block *> implBlocks;
    implCandidates.push_back(
        IPIdentifierAttr::get(rewriter.getContext(), "", ""));

    // Generate a block for holding default implementation parameters, which are
    // a list of parallel factors.
    auto implDefaultBlock = rewriter.createBlock(&implSpace.getBody());
    SmallVector<Value> parallelParams;
    for (auto tileSize : llvm::enumerate(tileParamArgs)) {
      auto parallelBounds = {rewriter.getAffineConstantExpr(0),
                             rewriter.getAffineSymbolExpr(0)};
      auto parallelParamOp = rewriter.create<ParamOp>(
          loc, rewriter.getIndexType(), tileSize.value(),
          AffineMap::get(0, 1, parallelBounds, rewriter.getContext()),
          "parallel" + std::to_string(tileSize.index()));
      parallelParams.push_back(parallelParamOp);
    }
    rewriter.create<SpacePackOp>(loc, parallelParams);
    implBlocks.push_back(implDefaultBlock);

    // Now, we start to match exsting IP declares and generate blocks for
    // holding matched IP parameters. Note that we assume the linalg op is in
    // canonicalized format to avoid unnecessary complexity in matching.
    for (auto declare : ipDeclares) {
      auto ipLinalgOp = declare.getSemanticsOp().getSemanticsLinalgOp();

      // If the number of inputs, outputs, or loops are different, we skip the
      // matching process.
      if (linalgOp.getNumDpsInputs() != ipLinalgOp.getNumDpsInputs() ||
          linalgOp.getNumDpsInits() != ipLinalgOp.getNumDpsInits() ||
          linalgOp.getNumLoops() != ipLinalgOp.getNumLoops())
        continue;

      // Otherwise, match the two linalg ops with LinalgMatcher.
      if (succeeded(LinalgMatcher(linalgOp, ipLinalgOp).match())) {
        implCandidates.push_back(IPIdentifierAttr::get(
            rewriter.getContext(), declare.getLibraryOp().getName(),
            declare.getName()));

        // Generate a separate block for holding the parameters of each IP.
        // TODO: We don't know how to handle the parameter type yet.
        auto implIpBlock = rewriter.createBlock(&implSpace.getBody());
        SmallVector<Value> ipParams;
        for (auto staticParam : declare.getOps<ValueParamOp>())
          if (staticParam.getKind() == ValueParamKind::STATIC) {
            auto ipParamOp = rewriter.create<ParamOp>(
                loc, staticParam.getResult().getType(),
                staticParam.getCandidatesAttr(), staticParam.getName());
            ipParams.push_back(ipParamOp);
          }
        rewriter.create<SpacePackOp>(loc, ipParams);
        implBlocks.push_back(implIpBlock);
      }
    }

    // Now we can go back ang generate a implementation candidates parameter in
    // the entry block, which will be used to select the implementation of the
    // current task.
    rewriter.setInsertionPointToStart(implEntryBlock);
    auto candidatesParamOp = rewriter.create<ParamOp>(
        loc, IPIdentifierType::get(rewriter.getContext()),
        rewriter.getArrayAttr(implCandidates), "candidates");
    rewriter.create<SpaceBranchOp>(loc, candidatesParamOp,
                                   rewriter.getArrayAttr(implCandidates),
                                   implBlocks);

    // Finally, pack the whole task design space and update the current task
    // with the space symbolic name.
    rewriter.setInsertionPointToEnd(taskSpaceBlock);
    tileParams.push_back(implSpace.getResult());
    rewriter.create<SpacePackOp>(loc, tileParams);

    task.setSpaceAttr(SymbolRefAttr::get(
        rewriter.getStringAttr(globalSpaceName),
        {FlatSymbolRefAttr::get(taskSpace.getSymNameAttr())}));
    return success();
  }

private:
  Block *globalSpaceBlock;
  StringRef globalSpaceName;
  unsigned &taskIdx;
  const SmallVector<DeclareOp> &ipDeclares;
};
} // namespace

namespace {
struct GenerateTaskDesignSpace
    : public GenerateTaskDesignSpaceBase<GenerateTaskDesignSpace> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    // Get or create the global design space.
    auto space = getOrCreateGlobalSpaceOp(module);
    if (!space)
      return module.emitOpError("failed to get space op"), signalPassFailure();

    // Collect available IP declares.
    auto ipDeclares = getIPDeclares(module);

    // Generate design space for each dataflow task in the module.
    unsigned taskIdx = 0;
    mlir::RewritePatternSet patterns(context);
    patterns.add<GenerateTaskDesignSpacePattern>(
        context, &space.getBody().front(), space.getName(), taskIdx,
        ipDeclares);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createGenerateTaskDesignSpacePass(
    unsigned defaultTileFactor, unsigned defaultParallelFactor) {
  return std::make_unique<GenerateTaskDesignSpace>();
}
