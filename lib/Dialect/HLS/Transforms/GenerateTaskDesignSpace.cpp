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
#include "scalehls/Dialect/HLS/Utils/Matchers.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"

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
    // TODO: We also need to generate vectorization factors here.
    SmallVector<Value> tileParams;
    for (auto loopSize : llvm::enumerate(linalgOp.computeStaticLoopSizes())) {
      auto tileBounds = {rewriter.getAffineConstantExpr(0),
                         rewriter.getAffineConstantExpr(loopSize.value())};
      auto tileParamOp = rewriter.create<ParamOp>(
          loc, rewriter.getIndexType(), ValueRange(),
          AffineMap::get(0, 0, tileBounds, rewriter.getContext()),
          ParamKind::TILE_SIZE, "tile" + std::to_string(loopSize.index()));
      tileParams.push_back(tileParamOp);
    }

    // We start to collect implementation candidates. We  always push the
    // default implementatoin without using IPs as the first candidate.
    SmallVector<Attribute> implCandidates;
    SmallVector<Value> implSpaces;
    implCandidates.push_back(TaskImplAttr::get(rewriter.getContext(), "", ""));

    // Generate a sub-space for holding default implementation parameters, which
    // are a list of parallel factors. The sub-space should take the tile
    // factors as hyper parameters for constraining the parallel factors.
    auto defaultSpace = rewriter.create<SpaceOp>(loc, tileParams, "default");
    auto defaultBlock = rewriter.createBlock(
        &defaultSpace.getBody(), Region::iterator(), ValueRange(tileParams),
        SmallVector<Location>(tileParams.size(), loc));

    SmallVector<Value> parallelParams;
    for (auto tileSize : llvm::enumerate(defaultBlock->getArguments())) {
      auto parallelBounds = {rewriter.getAffineConstantExpr(0),
                             rewriter.getAffineSymbolExpr(0)};
      auto parallelParamOp = rewriter.create<ParamOp>(
          loc, rewriter.getIndexType(), tileSize.value(),
          AffineMap::get(0, 1, parallelBounds, rewriter.getContext()),
          ParamKind::PARALLEL_SIZE,
          "parallel" + std::to_string(tileSize.index()));
      parallelParams.push_back(parallelParamOp);
    }
    rewriter.create<SpacePackOp>(loc, parallelParams);
    implSpaces.push_back(defaultSpace);

    // Now, we start to match exsting IP declares and generate sub-spaces for
    // holding matched IP parameters. Note that we assume the linalg op is in
    // canonicalized format to avoid unnecessary complexity in matching.
    for (auto declare : ipDeclares) {
      auto libraryName = declare.getLibraryOp().getName();
      auto ipName = declare.getName();
      auto ipLinalgOp = declare.getSemanticsOp().getSemanticsLinalgOp();

      // If the number of inputs, outputs, or loops are different, we skip the
      // matching process.
      if (linalgOp.getNumDpsInputs() != ipLinalgOp.getNumDpsInputs() ||
          linalgOp.getNumDpsInits() != ipLinalgOp.getNumDpsInits() ||
          linalgOp.getNumLoops() != ipLinalgOp.getNumLoops())
        continue;

      // Otherwise, match the two linalg ops with LinalgMatcher.
      if (succeeded(IPMatcher(linalgOp, declare).match())) {
        implCandidates.push_back(
            TaskImplAttr::get(rewriter.getContext(), libraryName, ipName));

        // Generate a separate sub-space for holding the parameters of each IP.
        // TODO: We don't know how to handle the parameter type yet.
        rewriter.setInsertionPointToEnd(taskSpaceBlock);
        auto ipSpace = rewriter.create<SpaceOp>(loc, libraryName.str() + "_" +
                                                         ipName.str());
        rewriter.createBlock(&ipSpace.getBody());
        SmallVector<Value> ipParams;
        SmallVector<StringRef> ipParamNames;
        for (auto ipParamOp : declare.getOps<ParamOp>())
          if (!ipParamOp.getType().isa<TypeType>()) {
            ipParams.push_back(rewriter.clone(*ipParamOp)->getResult(0));
            ipParamNames.push_back(ipParamOp.getName());
          }

        rewriter.create<SpacePackOp>(loc, ipParams,
                                     rewriter.getStrArrayAttr(ipParamNames));
        implSpaces.push_back(ipSpace);
      }
    }

    // Now we can generate an implementation candidates parameter in the task
    // design space, which will be used to select the implementation of the
    // current task.
    rewriter.setInsertionPointToEnd(taskSpaceBlock);
    auto candidatesParamOp =
        rewriter.create<ParamOp>(loc, TaskImplType::get(rewriter.getContext()),
                                 rewriter.getArrayAttr(implCandidates),
                                 ParamKind::TASK_IMPL, "candidates");
    auto select = rewriter.create<SpaceSelectOp>(
        loc, SpaceType::get(rewriter.getContext()), candidatesParamOp,
        implSpaces, rewriter.getArrayAttr(implCandidates));

    // Finally, pack the whole task design space and update the current task
    // with the space symbolic name.
    auto packParams = tileParams;
    packParams.push_back(select);
    rewriter.create<SpacePackOp>(loc, packParams);

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
