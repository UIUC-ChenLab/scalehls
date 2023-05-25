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

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ParameterizeTileParallelFactorPattern : public OpRewritePattern<TaskOp> {
  ParameterizeTileParallelFactorPattern(MLIRContext *context, Block *spaceBlock,
                                        StringRef spaceName, unsigned &taskIdx)
      : OpRewritePattern<TaskOp>(context), spaceBlock(spaceBlock),
        spaceName(spaceName), taskIdx(taskIdx) {}

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    auto linalgOp = task.getPayloadLinalgOp();
    if (!linalgOp)
      return failure();

    // TODO: We should introduce a more systematic way to generate unique symbol
    // names for parameters.
    auto paramPrefix = "task" + std::to_string(taskIdx++);
    auto loc = task.getLoc();

    // Generate tile and parallel factors of the task.
    SmallVector<Value, 4> tileFactors;
    SmallVector<Value, 4> parallelFactors;
    for (auto size : llvm::enumerate(linalgOp.computeStaticLoopSizes())) {
      rewriter.setInsertionPointToEnd(spaceBlock);

      auto tileName = paramPrefix + "_t" + std::to_string(size.index());
      auto tileBounds = {rewriter.getAffineConstantExpr(0),
                         rewriter.getAffineConstantExpr(size.value())};
      auto tileParamOp = rewriter.create<ParamOp>(
          loc, rewriter.getIndexType(), ValueRange(),
          AffineMap::get(0, 0, tileBounds, rewriter.getContext()),
          ParamKind::TILE_FACTOR, tileName);

      auto parallelName = paramPrefix + "_p" + std::to_string(size.index());
      auto parallelBounds = {rewriter.getAffineConstantExpr(0),
                             rewriter.getAffineDimExpr(0)};
      auto parallelParamOp = rewriter.create<ParamOp>(
          loc, rewriter.getIndexType(), tileParamOp.getResult(),
          AffineMap::get(1, 0, parallelBounds, rewriter.getContext()),
          ParamKind::PARALLEL_FACTOR, parallelName);

      rewriter.setInsertionPoint(task);
      tileFactors.push_back(rewriter.create<GetParamOp>(
          loc, tileParamOp.getType(), spaceName.str(), tileName));
      parallelFactors.push_back(rewriter.create<GetParamOp>(
          loc, parallelParamOp.getType(), spaceName.str(), parallelName));
    }

    // Update the current task op with the generated tile and parallel factors.
    task.getTileFactorsMutable().assign(tileFactors);
    task.getParallelFactorsMutable().assign(parallelFactors);
    return success();
  }

private:
  Block *spaceBlock;
  StringRef spaceName;
  unsigned &taskIdx;
};
} // namespace

namespace {
struct ParameterizeTileParallelFactor
    : public ParameterizeTileParallelFactorBase<
          ParameterizeTileParallelFactor> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    // Get the design space for holding parameters.
    auto space = getOrCreateGlobalSpaceOp(module);
    if (!space)
      return module.emitOpError("cannot find or create space op"),
             signalPassFailure();

    // Collect all tasks to be tiled.
    SmallVector<TaskOp, 32> tasks;
    module.walk([&](TaskOp op) { tasks.push_back(op); });

    // Parameterize each dataflow task in the module. Note we don't use the
    // greedy pattern driver here because the tiling will generated hierarchy,
    // which we don't want to recursively delve into.
    unsigned taskIdx = 0;
    mlir::RewritePatternSet patterns(context);
    patterns.add<ParameterizeTileParallelFactorPattern>(
        context, &space.getBody().front(), space.getName(), taskIdx);
    FrozenRewritePatternSet frozenPatterns(std::move(patterns));
    for (auto task : tasks)
      if (failed(applyOpPatternsAndFold({task}, frozenPatterns)))
        return signalPassFailure();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createParameterizeTileParallelFactorPass(
    unsigned defaultTileFactor, unsigned defaultParallelFactor) {
  return std::make_unique<ParameterizeTileParallelFactor>();
}
