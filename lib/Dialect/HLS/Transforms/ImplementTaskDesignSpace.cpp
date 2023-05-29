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
struct ImplementTaskDesignSpacePattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp op,
                                PatternRewriter &rewriter) const override {
    // If the task is not attached to a space, return failure.
    if (!op.getSpace().has_value())
      return failure();

    // If the design space or payload linalg op is not found, return failure.
    auto space = SymbolTable::lookupNearestSymbolFrom<SpaceOp>(
        op->getParentOfType<ModuleOp>(), op.getSpaceAttr());
    auto linalgOp = op.getPayloadLinalgOp();
    if (!space || !linalgOp)
      return failure();

    // Collect tile sizes. All operands of the terminator SpacePackOp except the
    // last one are the tile size parameters.
    SmallVector<int64_t> tileSizes;
    for (auto param : llvm::drop_end(space.getSpacePackOp().getOperands())) {
      // The tile size parameter must be TILE_SIZE kind and have an index type.
      auto paramOp = param.getDefiningOp<hls::ParamLikeInterface>();
      assert(paramOp && paramOp.getKind() == ParamKind::TILE_SIZE &&
             "invalid tile parameter");

      // If the param hasn't been assigned a value, return failure. This pass is
      // expected to run after design space exploration of each param.
      if (!paramOp.getValue().has_value())
        return failure();

      // Get the tile size value store as an attribute of the ParamOp.
      tileSizes.push_back(paramOp.getValue()->cast<IntegerAttr>().getInt());
    }

    // Tile the linalg op with the collected tile sizes.
    linalg::LinalgTilingOptions options;
    options.setTileSizes(tileSizes);
    auto tiledLinalgOp = linalg::tileLinalgOp(rewriter, linalgOp, options);
    if (failed(tiledLinalgOp))
      return failure();

    // Replace the original linalg op with the tiled one.
    rewriter.replaceOp(linalgOp, tiledLinalgOp->tensorResults);
    linalgOp = tiledLinalgOp->op;

    // Then, we start to handle the implementation design space, which must be
    // defined by a SpaceSelectOp for now.
    auto implSpace = space.getSpacePackOp().getOperands().back();
    auto implSelect = implSpace.getDefiningOp<SpaceSelectOp>();
    assert(implSelect && "invalid task implementation design space");

    // Similarly, the task implementation parameter must be TASK_IMPL kind and
    // has a TaskImplType.
    auto paramOp = implSelect.getArg().getDefiningOp<hls::ParamLikeInterface>();
    assert(paramOp && paramOp.getKind() == ParamKind::TASK_IMPL &&
           "invalid task implementation parameter");

    // Again, if the param hasn't been assigned a value, return failure. This
    // pass is expected to run after design space exploration of each param.
    if (!paramOp.getValue().has_value())
      return failure();

    // Find the space corresponding to the selected task implementation.
    for (auto [candidate, space] :
         llvm::zip(implSelect.getConditionsAttr(), implSelect.getSpaces()))
      if (candidate == paramOp.getValue()) {
        implSpace = space;
        break;
      }
    auto implSpaceOp = implSpace.getDefiningOp<SpaceOp>();
    assert(implSpaceOp && "invalid task implementation candidates");

    if (auto symbol = paramOp.getValue()->cast<TaskImplAttr>().getSymbolRef()) {
      // If the task will be implemented with an IP, we substitute the original
      // linalg operation with an IP instance.
      auto ipDeclare = SymbolTable::lookupNearestSymbolFrom<DeclareOp>(
          op->getParentOfType<ModuleOp>(), symbol);
      assert(ipDeclare && "invalid IP declaration");

      // TODO: We actually have a LOT of works to do here. But to demonstrate
      // the idea, we start from simply replacing the linalg op.
      rewriter.setInsertionPoint(linalgOp);
      SmallVector<Value> ports;
      for (auto operand : linalgOp.getDpsInputOperands())
        ports.push_back(operand->get());
      for (auto operand : linalgOp.getDpsInitOperands())
        ports.push_back(operand->get());
      rewriter.replaceOpWithNewOp<InstanceOp>(
          linalgOp, linalgOp->getResultTypes(), ports,
          rewriter.getArrayAttr({}), symbol);
    } else {
      // TODO: Otherwise, we parallelize the linalg op with the explored
      // parallel sizes.
    }

    // Finally, we remove the space attribute from the task op.
    op.removeSpaceAttr();
    return success();
  }
};
} // namespace

namespace {
struct ImplementTaskDesignSpace
    : public ImplementTaskDesignSpaceBase<ImplementTaskDesignSpace> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ImplementTaskDesignSpacePattern>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createImplementTaskDesignSpacePass() {
  return std::make_unique<ImplementTaskDesignSpace>();
}
