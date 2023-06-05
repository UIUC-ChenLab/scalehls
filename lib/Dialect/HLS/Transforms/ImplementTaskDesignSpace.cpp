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
      return op.removeSpaceAttr(), failure();

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
        return op.removeSpaceAttr(), failure();

      // Get the tile size value store as an attribute of the ParamOp.
      tileSizes.push_back(paramOp.getValue()->cast<IntegerAttr>().getInt());
    }

    // Tile the linalg op with the collected tile sizes.
    linalg::LinalgTilingOptions options;
    options.setTileSizes(tileSizes);
    auto tiledLinalgOp = linalg::tileLinalgOp(rewriter, linalgOp, options);
    if (failed(tiledLinalgOp))
      return op.removeSpaceAttr(), failure();

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
    auto implParamOp =
        implSelect.getArg().getDefiningOp<hls::ParamLikeInterface>();
    assert(implParamOp && implParamOp.getKind() == ParamKind::TASK_IMPL &&
           "invalid task implementation parameter");

    // Again, if the param hasn't been assigned a value, return failure.
    if (!implParamOp.getValue().has_value())
      return op.removeSpaceAttr(), failure();

    // Find the space corresponding to the selected task implementation.
    for (auto [candidate, space] :
         llvm::zip(implSelect.getConditionsAttr(), implSelect.getSpaces()))
      if (candidate == implParamOp.getValue()) {
        implSpace = space;
        break;
      }
    auto implSpaceOp = implSpace.getDefiningOp<SpaceOp>();
    assert(implSpaceOp && "invalid task implementation candidates");


//==========================================================================================
    // if (0 == 1) {
    //   auto symbol = implParamOp.getValue()->cast<TaskImplAttr>().getSymbolRef();
    if (auto symbol =
            implParamOp.getValue()->cast<TaskImplAttr>().getSymbolRef()) {

      // If the task will be implemented with an IP, we substitute the original
      // linalg operation with an IP instance.
      auto ipDeclare = SymbolTable::lookupNearestSymbolFrom<DeclareOp>(
          op->getParentOfType<ModuleOp>(), symbol);
      assert(ipDeclare && "invalid IP declaration");

      auto matchingResult = IPMatcher(linalgOp, ipDeclare).match();
      if (failed(matchingResult))
        return op.removeSpaceAttr(), failure();

      // Collect the result types of the IP instance.
      SmallVector<Type> instResultTypes;
      for (unsigned i = 0; i < linalgOp.getNumDpsInits(); ++i) {
        auto resIndex = matchingResult->mapIpResIndexToPayload(i);
        instResultTypes.push_back(linalgOp->getResult(resIndex).getType());
      }

      // Collect the instance ports.
      rewriter.setInsertionPoint(linalgOp);
      SmallVector<Value> instPorts;
      for (auto port : matchingResult->instPorts) {
        if (port.is<Value>())
          instPorts.push_back(port.get<Value>());
        else if (auto portAttr = port.get<Attribute>())
          instPorts.push_back(rewriter.create<arith::ConstantOp>(
              linalgOp.getLoc(), TypedAttr(portAttr)));
      }

      // Collect the instance templates.
      SmallVector<Attribute> instTemplates;
      for (auto [tempOperand, tempAttr] :
           llvm::zip(ipDeclare.getSemanticsOp().getTemplates(),
                     matchingResult->instTemplates)) {
        if (tempAttr) {
          instTemplates.push_back(tempAttr);
          continue;
        }
        auto tempParam = implSpaceOp.getSpacePackOp().findOperand(
            tempOperand.getDefiningOp<ParamOp>().getNameAttr());
        assert(tempParam && "invalid template parameter");

        auto tempParamOp = tempParam.getDefiningOp<hls::ParamLikeInterface>();
        assert(tempParamOp && tempParamOp.getKind() == ParamKind::IP_TEMPLATE &&
               "invalid template parameter");

        // Again, if the param hasn't been assigned a value, return failure.
        if (!tempParamOp.getValue().has_value())
          return op.removeSpaceAttr(), failure();
        instTemplates.push_back(*tempParamOp.getValue());
      }

      // Finally, we can create the instance op.
      auto instance = rewriter.create<InstanceOp>(
          linalgOp.getLoc(), instResultTypes, instPorts,
          rewriter.getArrayAttr(instTemplates), symbol);

      // Replace the original linalg op results with the instance op.
      for (unsigned i = 0; i < instance.getNumResults(); ++i) {
        auto resIndex = matchingResult->mapIpResIndexToPayload(i);
        linalgOp->getResult(resIndex).replaceAllUsesWith(instance.getResult(i));
      }
      rewriter.eraseOp(linalgOp);
    } else {

      //TRY
      // auto symbol = implParamOp.getValue()->cast<TaskImplAttr>().getSymbolRef()
      // auto default_space = SymbolTable::lookupNearestSymbolFrom<SpaceOp>(
      //   op->getParentOfType<ModuleOp>(), symbol);

      auto default_spaceOp = implSelect.getSpaces()[0].getDefiningOp<SpaceOp>();

      SmallVector<int64_t> parallel_para;

      for (auto param : default_spaceOp.getSpacePackOp().getArgs()) {
        // The tile size parameter must be TILE_SIZE kind and have an index type.
        auto paramOp = param.getDefiningOp<hls::ParamLikeInterface>();
        assert(paramOp.getKind() == ParamKind::PARALLEL_SIZE &&
              "invalid parallel parameter");

        if (!paramOp.getValue().has_value())
          return op.removeSpaceAttr(), failure();

        // Get the tile size value store as an attribute of the ParamOp.
        parallel_para.push_back(paramOp.getValue()->cast<IntegerAttr>().getInt());
      }

      linalg::LinalgTilingOptions options;
      options.setTileSizes(parallel_para);
      auto parallelLinalgOp = linalg::tileLinalgOp(rewriter, linalgOp, options);
      if (failed(parallelLinalgOp))
        return op.removeSpaceAttr(), failure();

      // Replace the original linalg op with the tiled one.
      rewriter.replaceOp(linalgOp, parallelLinalgOp->tensorResults);
      linalgOp = parallelLinalgOp->op;

      // TODO: Otherwise, we parallelize the linalg op with the explored

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
